/**
 * ScrambledPhysics
 * A rewrite of some earlier hacking.
 * The aim is to create a simple, portable physics library
 */

/**
 * The <code>Things</code> interface must be implemented for anything
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
  float max_x, min_x, max_y, min_y;
  /**
   * A <code>HashMap</code> of the laws that apply to the universe.
   */
  HashMap<String, Law> laws;

  /**
   * Default constructor, initialises the <code>things</code> ArrayList and
   * <code>laws</code> HashMap, and sets the bounds of the universe to the
   * size of the current sketch.
   */
  Universe() {
    things = new ArrayList<Thing>();
    laws = new HashMap<String, Law>();
    setBounds();
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
    Law edge = null, drag = null;
    Law law;
    // Iterate through the laws applied to the universe
    for (String name : laws.keySet()) {
      law = laws.get(name);
      if (law instanceof DragLaw) {
        /*
         * We want to handle DragLaw laws last, as they are affected
         * by EdgeLaws laws.
         */
        drag = law;
        continue;
      } else if (law instanceof EdgeLaw ) {
        /*
         * We want to handle EdgeLaw laws second-to-last, as they affect
         * by DragLaw laws.
         */
        edge = law;
        continue;
      } else {
        /*
         * Apply the law to the universe. This will typically alter the state of the
         * members in the universe (e.g. applying forces, changing position, etc)
         * although it could do absolutely anything!
         */
        law.apply(this);
      }
    }
    /*
     * Iterate through all the things in the universe and update them. Typically
     * this will calculate the acceleration, velocity and position, but could do 
     * anything...
     */
    for (Thing t: things) t.update();
    // Apply any saved edge law
    if ( edge != null ) edge.apply(this);
    // Apply any saved drag law
    // TODO Ref issue #1 - may want to update the things in the universe again having done this
    if ( drag != null ) drag.apply(this);
  }
  /**
   * Paint the universe by calling the paint method of everything in the universe.
   * Things do not need to paint themselves using this method - in which case a separate way of 
   * painting them needs to be implemented.
   */
  void paint() {
    for (Thing t: things) { t.paint(); }
  /**
   * Set the bounds of the universe to between x_min, y_min and x_max, y_max
   */
  }
  void setBounds(float x_min, float y_min, float x_max, float y_max) {
    min_x = x_min;
    min_y = y_min;
    max_x = x_max;
    max_y = y_max;
  }
  /**
   * Set the bounds of the universe to the current screen size
   */
  void setBounds() { setBounds(0, 0, width, height); }
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
      if ( ! p.hasProperty("Mass") ) continue;
      // Set the force to the constant, then multiply by the mass
      force = G.get();
      force.mult(p.getProperty("Mass"));
      // Add the force to the particle
      p.addForce(force);
    }
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
      force.mult(-mu);
      p.addForce( force );
    }
  }
}

class StokesDrag extends DragLaw {
  float coeff;
  StokesDrag() { this(0.1); }
  StokesDrag(float v) {
    super();
    coeff = v;
  }
  void apply(Universe u) {
    PVector force;
    for ( Thing t: u.getThings() ) {
      if ( ! ( t instanceof Particle ) ) continue;
      Particle p = (Particle)t;
      force = p.velocity.get();
      force.mult(-coeff);
      p.addForce( force );
    }
  }
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
    Particle p1, p2;
    PVector force;
    for ( int i1 = 0; i1 < u.countThings(); i1++ ) {
      p1 = getParticle(u.getThing(i1));
      // Only valid for subclasses of Particle...
      if ( p1 == null ) continue;
      // ...with a charge
      if (! p1.hasProperty("Charge") ) continue;
      // Store the charge of p1
      float p1_q = p1.getProperty("Charge");
      /*
       * Now iterate through all other particles
       * This is an optimisation, as the force applied on each pair of particles
       * is symmetrical (per Newton's Third Law), so we only need to calculate this 
       * once, and apply it twice.
       */            
      for ( int i2 = i1 + 1; i2 < u.countThings(); i2++ ) {
        p2 = getParticle(u.getThing(i2));
        // Only valid for subclasses of Particle...
        if ( p2 == null ) continue;
        // ...with a charge
        if (! p2.hasProperty("Charge") ) continue;
        // Store the charge of p2
        float p2_q = p2.getProperty("Charge");
        // Calculate the vector between the two particles...
        force = PVector.sub( p1.getPosition(), p2.getPosition() );
        // ...and the radius...
        float r = force.mag();
        // ...if that's zero, the particles are in the same place, so we can't calculate a force
        if ( r == 0 ) continue;
        // Normalise the force vector to unit length
        force.normalize();
        // Calculate the magnitude of the force (according to Coulomb's law)
        float m = k * p1_q * p2_q / (r*r);
        // Multiply the normalised force vector by he magnitude 
        force.mult(m);
        // Add this force to the first particle...
        p1.addForce(force);
        // ...calcualte the inverse...
        force.mult(-1);
        // ...and apply this to the other particle
        p2.addForce(force);
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
}

abstract class EdgeLaw extends Law {
  EdgeLaw() { super("Edge"); }
  boolean inUniverse(Particle p, Universe u) {
    return ( p.position.x > u.min_x ) && ( p.position.x < u.max_x ) && ( p.position.y > u.min_y ) && ( p.position.y < u.max_y ); 
  }
}

class WrapEdge extends EdgeLaw {
  void apply(Universe u) {
    PVector pos;
    for ( Thing t: u.getThings() ) {
      if ( ! ( t instanceof Particle ) ) continue;
      Particle p = (Particle)t;
      if ( p.position.x < u.min_x || p.position.x > u.max_x ) {
        p.position.x = reMap( p.position.x, u.min_x, u.max_x );
      }
      if ( p.position.y < u.min_y || p.position.y > u.max_y ) {
        p.position.y = reMap( p.position.y, u.min_y, u.max_y );
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

class KillEdge extends EdgeLaw {
  void apply(Universe u) {
    for (int i = 0; i < u.things.size(); i++ ) {
      Thing t = u.things.get(i); 
      if ( ! ( t instanceof Particle ) ) continue;
      Particle p = (Particle)t;
      if ( ! inUniverse( p, u ) ) {
        u.things.remove(i);
        p.removed(u);
      }
    }
  }
}

class BounceEdge extends EdgeLaw {
  boolean DEBUG = false;
  void apply(Universe u) {
    PVector pos;
    for ( Thing t: u.getThings() ) {
      if ( ! ( t instanceof Particle ) ) continue;
      Particle p = (Particle)t;
      int b = bounce( p, u );
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
  int bounce( Particle p, Universe u ) {
    float new_x = getOffset( p.position.x, u.min_x, u.max_x );
    if ( new_x != p.position.x ) {
      p.velocity.mult(new PVector(-1,1,1));
      p.position.x = new_x;
      return bounce(p, u) + 1;
    }
    float new_y = getOffset( p.position.y, u.min_y, u.max_y );
    if ( new_y != p.position.y ) {
      p.velocity.mult(new PVector(1,-1,1));
      p.position.y = new_y;
      return bounce(p, u) + 1;
    }
    return 0;
  }
}

abstract class ScrambledObject {
  HashMap<String, Property> properties;
  
  ScrambledObject() {
    properties = new HashMap<String, Property>();
  }

  void addProperty(Property p) {
    properties.put(p.getName(), p);
  }
  boolean hasProperty(String n) {
    return properties.containsKey(n);
  }
  float getProperty(String n) {
    return properties.get(n).getValue();
  }
}

class Particle extends ScrambledObject implements Thing {
  PVector position;
  PVector velocity;
  PVector acceleration;
  PVector force;
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
  
  void update() {
    if (!locked) {
      if ( hasProperty("Mass") ) acceleration = PVector.mult( force, 1/getProperty("Mass"));
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

/**
 * Properties - these apply to ScrambledObject classes
 */
abstract class Property {
  float value;
  final String name;
  
  Property(float v, String n) {
    value = v;
    name = n;
  }

  float getValue() {
    return value;
  }
  String getName() {
    return name;
  }
}

class Mass extends Property {
  Mass(float v) { super(v, "Mass"); }
}

class Charge extends Property {
  Charge(float v) { super(v, "Charge"); }
}

class Connector implements Thing {
  void update() {}
  void paint() {}
  void removed(Universe u) {}
}
