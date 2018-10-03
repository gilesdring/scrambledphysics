/**
 * ScrambledPhysics
 * A rewrite of some earlier hacking.
 * The aim is to create a simple, portable physics library
 */
class BHTree {
  Particle body;   // body or aggregate body stored in this node
  PVector origin;
  float dimension;
  BHTree[] subs;    // tree representing quadrants

  BHTree( float x, float y, float s ) {
    origin = new PVector( x, y );
    dimension = s;
    subs = null;
    body = null;
  }

  void insert( Particle a ) {
    if ( ! contains ( a ) ) {
      return;
    }
    if ( body == null ) {                            // This is an empty BHTree
      body = a;
    } else {
      if ( subs == null ) {                       // This is an external BHTree
        subs = new BHTree[4];
        float halfSize = dimension / 2;
        subs[0] = new BHTree( origin.x, origin.y, halfSize );
        subs[1] = new BHTree( origin.x, origin.y + halfSize, halfSize );
        subs[2] = new BHTree( origin.x + halfSize, origin.y, halfSize );
        subs[3] = new BHTree( origin.x + halfSize, origin.y + halfSize, halfSize );
        Particle oldbody = body;
        body = new Particle( oldbody.getPosition() );
        body.setCharge(oldbody.charge);
        body.setMass(oldbody.mass);
        for ( BHTree subTree: subs ) {
          subTree.insert(oldbody);
          subTree.insert(a);
        };
      } else {
        for ( BHTree subTree: subs ) subTree.insert(a);
      }
      update_body( a );
    }
  }

  void update_body( Particle a ) {
    // This is an aggregate attractor if it's an internal node
    /// HMMMMMMM!!! Centre of mass and centre of charge will have different locations... Focus on charge to start with...
    float newMass = body.mass + a.mass;
    body = calculateCentreOfCharge(body, a);
    body.setMass(newMass);
  }

  Particle calculateCentreOfCharge(Particle a, Particle b) {
    // TODO this isn't quite right at the moment. But it's righter.
    float mag = abs(a.charge) + abs(b.charge);
    float aScale = abs(a.charge)/mag;
    float bScale = abs(b.charge)/mag;
    Particle result = new Particle(
      new PVector(
          a.position.x * aScale + b.position.x * bScale,
          a.position.y * aScale + b.position.y * bScale,
          a.position.z * aScale + b.position.z * bScale
      )
    );
    result.setCharge(a.charge + b.charge);
    return result;
  }

  boolean contains( Particle a ) {
    PVector pos = a.getPosition();
    return ( ( pos.x >= origin.x ) && ( pos.x < origin.x + dimension ) && ( pos.y >= origin.y ) && ( pos.y < origin.y + dimension ) );
  }

  void paint() {
    pushMatrix();
    pushStyle();
    stroke( 50 );
    noFill();
    translate( origin.x, origin.y );
    rect( 0,0,dimension,dimension );
    popMatrix();
    if ( body != null ) {
      pushMatrix();
      translate(body.position.x-10, body.position.y-10);
      line(0,10,20,10);
      line(10,0,10,20);
      popMatrix();
    }
    popStyle();
    if ( subs != null ) {
      subs[0].paint();
      subs[1].paint();
      subs[2].paint();
      subs[3].paint();
    }
  }
}
class BounceEdge extends EdgeLaw {
  BounceEdge() { super(); }
  BounceEdge(float x, float y, float w, float h) { super(x,y,w,h); }

  boolean DEBUG = false;
  void apply(Universe u) {
    PVector pos;
    for ( Thing t: u.getThings() ) {
      if ( ! ( t instanceof Particle ) ) continue;
      Particle p = (Particle)t;
      int b = bounce( p );
      if ( b > 0 && DEBUG ) println( b + " bounces to get into universe" );
    }
  }
  float getOffset(float val, float min, float max) {
    float o = val;
    if ( val < min ) {
      o = ( 2 * min ) - val;
    } else if ( val > max ) {
      o = ( 2 * max ) - val;
    }
    return o;
  }
  int bounce( Particle p ) {
    float new_x = getOffset( p.position.x, minX, maxX );
    if ( new_x != p.position.x ) {
      p.velocity.x *= -1;
      p.position.x = new_x;
      return bounce(p) + 1;
    }
    float new_y = getOffset( p.position.y, minY, maxY );
    if ( new_y != p.position.y ) {
      p.velocity.y *= -1;
      p.position.y = new_y;
      return bounce(p) + 1;
    }
    return 0;
  }
}
class Connector implements Thing {
  Particle p1, p2;
  boolean firm;
  float springRate;
  float length;

  Connector(Particle _p1, Particle _p2) {
    super();
    p1 = _p1;
    p2 = _p2;
    firm = false;
    length = 0;
    springRate = 0;
  }

  void setSpringRate(float r) { springRate = r; }
  void setLength(float l) { length = l; }
  void applyForces() {
    if ( springRate == 0 ) return;

    PVector diff = PVector.sub(p1.position, p2.position);
    float mag = firm ? max( diff.mag() - length, 0) : diff.mag() - length;
    mag = mag * springRate;
    p1.addForce( PVector.mult(diff, -mag ) );
    p2.addForce( PVector.mult(diff, mag ) );
  }

  void update() {}
  void paint() { line(p1.position.x,p1.position.y, p2.position.x,p2.position.y); }
  void removed(Universe u) {}
}
class Coulomb extends Law {
  //  http://en.wikipedia.org/wiki/Coulomb's_law
  float k;
  Coulomb() {
    this(8.987);
  }
  Coulomb(float v) {
    super("Coulomb");
    k = v;
  }

  void apply(Universe u) {
    for ( int i1 = 0; i1 < u.countThings(); i1++ ) {
      Thing t1 = u.getThing(i1);
      // Only valid for subclasses of Particle...
      if (! (t1 instanceof Particle) ) continue;
      Particle p1 = (Particle)t1;

      BHTree root = u.getBhTree();
      if ( root != null ) {
        p1.addForce(bhTreeForces(p1, root));
      } else {
        for ( int i2 = i1 + 1; i2 < u.countThings(); i2++ ) {
          /*
           * Now iterate through all other particles
           * This is an optimisation, as the force applied on each pair of particles
           * is symmetrical (per Newton's Third Law), so we only need to calculate this
           * once, and apply it twice.
           */
          Particle p2 = getParticle(u.getThing(i2));
          // Only valid for subclasses of Particle...
          if ( ! (p2 instanceof Particle) ) continue;
          // ...with a charge
          if ( p2.charge == 0 ) continue;
          PVector force = calculateForce(p1, p2);
          // Add this force to the first particle...
          p1.addForce(force);
          // ...calcualte the inverse...
          force.mult(-1);
          // ...and apply this to the other particle
          p2.addForce(force);
        }
      }
    }
  }
  private Particle getParticle( Thing t ) {
    if ( ! (t instanceof Particle) ) {
      return null;        // Only valid for subclasses of Particle
    } else {
      return ((Particle)t);
    }
  }
  private PVector calculateForce(Particle p1, Particle p2) {
    // Calcualte the charge product
    float qq = p1.charge * p2.charge;
    if (qq == 0) return new PVector(0, 0, 0);

    // Calculate the vector between the two particles...
    PVector force = new PVector(
      p1.position.x - p2.position.x,
      p1.position.y - p2.position.y,
      p1.position.z - p2.position.z
      );
    // ...and the radius (squared)...
    float rr = force.x * force.x + force.y * force.y + force.z * force.z;
    // ...if that's zero, the particles are in the same place, so we can't calculate a force
    if ( rr == 0 ) return new PVector(0, 0, 0);
    // Normalise the force vector to unit length
    force.normalize();
    // Calculate the magnitude of the force (according to Coulomb's law)
    float m = k * qq / rr;
    // Multiply the normalised force vector by he magnitude
    force.mult(m);
    return force;
  }

  private PVector bhTreeForces(Particle p, BHTree t) {
    float theta = 0.5;
    if ( t.body == null || t.body == p ) { // Empty BH Node or body is p
      return new PVector( 0,0,0 );
    }
    if ( t.subs != null ) {
      // Descend into each tree
      // calculate the ratio s / d (dimension of BHTree area / distance between body and a )
      float distance = sqrt(
        sq( p.position.x - t.body.position.x ) +
        sq( p.position.y - t.body.position.y ) +
        sq( p.position.z - t.body.position.z )
      );
      float ratio = t.dimension / distance;
      if ( ratio < theta ) { // if s/d < theta (0.5, typically)
        // treat this as a single body and calculate forces based on body
        return calculateForce( p, t.body );
      } else { // else
        // recurse into children, capturing and aggregating the forces
        PVector forces = new PVector( 0,0,0 );
        for ( int i = 0; i < t.subs.length; i++ ) {
          PVector vec = bhTreeForces( p, t.subs[i] );
          forces.x += vec.x;
          forces.y += vec.y;
          forces.z += vec.z;
        }
        // return force
        return forces;
      }
    }
    // This is an external node and body != p
    return calculateForce(p, t.body);
  }
}
/**
 * Base class for all Drag laws added to the universe
 */
abstract class DragLaw extends Law {
  /**
   * Default constructor initialises all DragLaw subclasses with the name 'Drag'
   */
  DragLaw() { super("Drag"); }
}
/**
 * DryFriction Drag laws, applies a constant force opposing the velocity
 */
class DryFriction extends DragLaw {
  /**
   * Coefficient of friction
   */
  float mu;
  /**
   * Constructor calls the default constructor of the DragLaw class
   *
   * @param v Coefficient of friction to set
   */
  DryFriction(float v) {
    super();
    mu = v;
  }
  /**
   * Iterate through all particles and apply a force of size mu opposing the
   * velocity
   */
  void apply(Universe u) {
    PVector force;
    for ( Thing t: u.getThings() ) {
      if ( ! ( t instanceof Particle ) ) continue;
      Particle p = (Particle)t;
      force = p.velocity.get();
      force.normalize();
      force.x *= -mu;
      force.y *= -mu;
      force.z *= -mu;
      p.addForce( force );
    }
  }
}
abstract class EdgeLaw extends Law {
  float minX, minY, maxX, maxY;
  EdgeLaw(float x, float y, float w, float h) {
    super("Edge");
    minX = min(x, x+w); maxX = max(x, x+w);
    minY = min(y, y+h); maxY = max(y, y+h);
  }
  EdgeLaw() { this(0,0,width,height); }
}
/**
 * Simple local Gravity, which applies a constant force proportional to the mass of the object
 */
class Gravity extends Law {
  /**
   * Constant of acceleration in vector form i.e. can apply in any direction
   */
  PVector G;
  /**
   * Default constructor sets the gravity to a downwards value roughly equivalent to gravity on earth
   */
  Gravity() { this(9.8); }
  /**
   * Single float constructor - assumes that gravity applies downwards
   *
   * @param v Value of gravity
   */
  Gravity(float v) { this(new PVector(0,v,0)); }
  /**
   * Uber constructor, called by all others. Sets the name to "Gravity" and the constant to the PVector passed in
   *
   * @param g Vector representation of Gravity
   */
  Gravity(PVector g) {
    super("Gravity");
    G = g.get();
  }
  /**
   * Calculate and apply the force to each particle in the universe
   *
   * @param u Universe to apply gravity to
   */
  void apply(Universe u) {
    PVector force;
    for ( Thing t: u.getThings() ) {
      // Only applies to Particles (or subtypes)
      if ( ! ( t instanceof Particle ) ) continue;
      // Cast t to a particle
      Particle p = (Particle)t;
      // Doesn't apply to things with no mass
      if ( p.mass == 0 ) continue;
      // Set the force to the constant, then multiply by the mass
      force = G.get();
      force.mult(p.mass);
      // Add the force to the particle
      p.addForce(force);
    }
  }
}
class Hooke extends Law {
  Hooke() {
    super("Hooke");
  }
  void apply(Universe u) {
    Connector con;
    for ( Thing t: u.getThings() ) {
      if ( t instanceof Connector ) {
        con = (Connector)t;
        con.applyForces();
      }
    }
  }
}
class KillEdge extends EdgeLaw {
  KillEdge() { super(); }
  KillEdge(float x, float y, float w, float h) { super(x,y,w,h); }

  void apply(Universe u) {
    for (int i = 0; i < u.things.size(); i++ ) {
      Thing t = u.things.get(i);
      if ( ! ( t instanceof Particle ) ) continue;
      Particle p = (Particle)t;
      if ( ! inUniverse( p ) ) {
        u.things.remove(i);
        p.removed(u);
      }
    }
  }

  boolean inUniverse(Particle p) {
    return ( p.position.x > minX ) && ( p.position.x < maxX ) && ( p.position.y > minY ) && ( p.position.y < maxY );
  }
}
/**
 * Base class for all Laws subsequently added to the universe
 */
abstract class Law {
  /**
   * Name of the law - each Law which extends this abstract class must set this
   */
  final String name;

  /**
   * Default constructor
   *
   * @param n Name to set for the class
   */
  Law(String n) {
    name = n;
  }

  /**
   * Apply the law to a given universe
   *
   * @param u Universe to which this law should be applied
   */
  abstract void apply(Universe u);

  /**
   * Get the name of the law
   *
   * @return the name of the law as set by the construtor
   */
  String getName() { return name; }
}
/**
 * Base class for all Motion laws added to the universe
 */
abstract class MotionLaw extends Law {
  /**
   * Default constructor initialises all MotionLaw subclasses with the name 'Motion'
   */
  MotionLaw() { super("Motion"); }
}

class NewtonsLaws extends MotionLaw {
  void apply(Universe u) {
    for ( Thing t: u.getThings() ) {
      if ( ! (t instanceof Particle) ) continue;
      Particle p = (Particle)t;
      PVector acceleration = new PVector();
      acceleration.x = p.force.x / p.mass;
      acceleration.y = p.force.y / p.mass;
      acceleration.z = p.force.z / p.mass;
      if ( p.mass != 0 ) p.accelerate(acceleration);
    }
  }
}


class Particle implements Thing {
  PVector position;
  PVector velocity;
  PVector acceleration;
  PVector force;

  float charge;
  float mass;

  boolean locked;
  boolean hidden;

  Particle(PVector p) {
    this(p,new PVector(0,0,0));
  }

  Particle(PVector p, PVector v) {
    super();
    position = p.get();
    velocity = v.get();
    acceleration = new PVector();
    force = new PVector();
    locked = false;
    charge = 0;
    mass = 0;
  }

  void setCharge(float c) {
    charge = c;
  }
  void setMass(float m) {
    mass = m;
  }

  PVector getPosition() {
    return position.get();
  }

  void setPosition(PVector p) {
    position = p;
  }

  void addForce(PVector a) {
    force.add(a);
  }

  PVector getForce() {
    return force;
  }

  void accelerate(PVector a) {
    acceleration = a;
  }

  void update() {
    if (!locked) {
      velocity.add(acceleration);
      position.add(PVector.mult( velocity, 1/frameRate) );
    }
    force.set(0,0,0);
  }

  void removed(Universe u) {
  }

  void paint() {
    if ( !hidden ) point(position.x, position.y);
  }

  void lock() { locked = true; }
  void unlock() { locked = false; }
  void hide() { hidden = true; }
  void show() { hidden = false; }
}
class StokesDrag extends DragLaw {
  float coeff;
  StokesDrag() { this(0.1); }
  StokesDrag(float v) {
    super();
    coeff = v;
  }
  void apply(Universe u) {
    PVector force = new PVector();
    for ( Thing t: u.getThings() ) {
      if ( ! ( t instanceof Particle ) ) continue;
      Particle p = (Particle)t;
      force.x = p.velocity.x * -coeff;
      force.y = p.velocity.y * -coeff;
      force.z = p.velocity.z * -coeff;
      p.addForce( force );
    }
  }
}
/**
 * The <code>Thing</code> interface must be implemented for anything
 * that could be added to a universe. It defines the api which the
 * universe depends upon.
 */
interface Thing {
  /**
   * The <code>update</code> method will be called once per update
   * of the universe.
   */
  void update();
  /**
   * The <code>paint</code> method should draw the Thing, and will be
   * called when the universe is painted.
   */
  void paint();
  /**
   * The <code>removed</code> method is called if the particle is removed
   * from the universe, and can be overridden to perform some useful
   * behaviour like re-adding the particle to the universe, or cleaning up
   * other references
   *
   * @param u Universe from which the particle has been removed.
   */
  void removed(Universe u);
}
/**
 * The <code>Universe</code> class is the core of the simulation. Each
 * Universe can have laws applied to it, and things added to it.
 */
class Universe {
  /**
   * An <code>ArrayList</code> containing all the things that have been
   * added to the universe
   */
  ArrayList<Thing> things;
  /**
   * A series of floats containing the bounds of the defined universe
   */
  float maxX, maxY, minX, minY;
  /**
   * A <code>HashMap</code> of the laws that apply to the universe.
   */
  HashMap<String, Law> laws;

  BHTree bhTree;
  boolean barnesHut;
  boolean DEBUG = false;

  /**
   * Default constructor, initialises the <code>things</code> ArrayList and
   * <code>laws</code> HashMap, and sets the bounds of the universe to the
   * size of the current sketch.
   */
  Universe() {
    this(true); // Default Barnes Hut simulation
  }
  Universe(boolean optimised) {
    things = new ArrayList<Thing>();
    laws = new HashMap<String, Law>();
    barnesHut = optimised;
    setBounds();
    initBhTree();
  }
  /**
   * Add a thing to the universe
   *
   * @param t Thing to add to the universe
   */
  void addThing(Thing t) {
    things.add(t);
  }
  /**
   * Get the full ArrayList of things in the universe
   */
  ArrayList<Thing> getThings() {
    return things;
  }
  /**
   * Get a thing from the universe
   */
  Thing getThing(int i) {
    return things.get(i);
  }
  /**
   * Count the number of things in the universe
   */
  int countThings() {
    return things.size();
  }
  /**
   * Add a law to the universe
   * Each law has a name, which is used to ensure that only one law of any type
   * is added to the universe (e.g. EdgeLaws all have the name "Edge"). The laws
   * are stored in a HashMap to ensure uniqueness.
   */
  void addLaw(Law l) {
    laws.put(l.getName(), l);
  }
  /**
   * Update the state of the universe. This should be called whenever you want
   * the universe to be updated - typically whenever the sketch is drawn
   */
  void update() {
    // Set up Barnes Hut Tree
    initBhTree();

    try {
      laws.get("Edge").apply(this);
    } catch(NullPointerException e) {}

    // Set up Barnes Hut Tree
    initBhTree();

    // Iterate through the laws applied to the universe
    for (Law law : laws.values()) {
      if ( (law instanceof EdgeLaw) || (law instanceof MotionLaw) ) {
        /*
         * We want Edge laws to apply first and motionlaws to apply last
         */
        continue;
      }
      /*
       * Apply the law to the universe. This will typically alter the state of the
       * members in the universe (e.g. applying forces, changing position, etc)
       * although it could do absolutely anything!
       */
      law.apply(this);
    }

    try {
      laws.get("Motion").apply(this);
    }
    catch(NullPointerException e) {}

    /*
     * Iterate through all the things in the universe and update them. Typically
     * this will calculate the acceleration, velocity and position, but could do
     * anything...
     */
    for (Thing t: things) t.update();
  }
  /**
   * Paint the universe by calling the paint method of everything in the universe.
   * Things do not need to paint themselves using this method - in which case a separate way of
   * painting them needs to be implemented.
   */
  void paint() {
    if (DEBUG && bhTree != null) bhTree.paint();
    for (Thing t: things) { t.paint(); }
  }

  /**
   * Set the bounds of the universe to between x_min, y_min and x_max, y_max
   */
  void setBounds() {
    if ( things.size() < 1 ) {
      minX = 0;
      minY = 0;
      maxX = width;
      maxY = height;
      return;
    }

    minX = MAX_FLOAT;
    minY = MAX_FLOAT;
    maxX = -MAX_FLOAT;
    maxY = -MAX_FLOAT;

    for (Thing t: things) {
      if (t instanceof Particle) {
        PVector pos = ((Particle)t).getPosition();
        minX = min( minX, pos.x );
        minY = min( minY, pos.y );
        maxX = max( maxX, pos.x );
        maxY = max( maxY, pos.y );
      }
    }
  }

  /**
   * Set the bounds of the universe to the current screen size
   */

  /**
   * Barnes Hut related functions
   */
  void initBhTree() {
    setBounds();
    if ( barnesHut ) {
      bhTree = new BHTree(minX - 10, minY - 10, max( maxX - minX, maxY - minY ) + 21);
      for (Thing t: things) {
        if (t instanceof Particle) {
          bhTree.insert((Particle)t);
        }
      }
    } else {
      bhTree = null;
    }
  }
  BHTree getBhTree() { return bhTree; }
}
class WrapEdge extends EdgeLaw {
  WrapEdge() { super(); }
  WrapEdge(float x, float y, float w, float h) { super(x,y,w,h); }

  void apply(Universe u) {
    PVector pos;
    for ( Thing t: u.getThings() ) {
      if ( ! ( t instanceof Particle ) ) continue;
      Particle p = (Particle)t;
      if ( p.position.x < minX || p.position.x > maxX ) {
        p.position.x = reMap( p.position.x, minX, maxX );
      }
      if ( p.position.y < minY || p.position.y > maxY ) {
        p.position.y = reMap( p.position.y, minY, maxY );
      }
    }
  }
  float reMap(float v, float min, float max) {
    float w = max - min;
    float o = ( v - min ) / w;
    while ( o < 0 ) o++;
    return min + ( ( o - int(o) ) * w );
  }
}
