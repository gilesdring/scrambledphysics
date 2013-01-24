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
   * behaviour like readding the particle to the universe, or cleaning up
   * other references 
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
    max_x = width;
    min_x = 0;
    max_y = height;
    min_y = 0;
  }
  /**
   * Add a thing to the universe
   */
  void addThing(Thing t) {
    things.add(t);
  }
  /**
   * Add a law to the universe
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
        /**
         * We want to handle <code>DragLaw</code> laws last, as they are affected
         * by <code>EdgeLaws</code> laws.
         */
        drag = law;
        continue;
      } else if (law instanceof EdgeLaw ) { // Save edge laws until the end...
        /**
         * We want to handle <code>EdgeLaw</code> laws second-to-last, as they are affected
         * by <code>DragLaw</code> laws.
         */
        edge = law;
        continue;
      } else {
        /**
         * Apply the law to the universe. This will typically alter the state of the
         * members in the universe (e.g. applying forces, changing position, etc)
         * although it could do absolutely anything!
         */
        law.apply(this);
      }
    }
    for (Thing t: things) t.update();
    if ( edge != null ) edge.apply(this);
    if ( drag != null ) drag.apply(this);
  }
  void paint() {
    for (Thing t: things) { t.paint(); }
  }
  ArrayList<Thing> getMembers() {
    return things;
  }
  Thing getMember(int i) {
    return things.get(i);
  }
  int countMembers() {
    return things.size();
  }
  void setBounds(float x1, float y1, float x2, float y2) {
    min_x = x1;
    min_y = y1;
    max_x = x2;
    max_y = y2;
  }
}


abstract class Law {
  final String name;
  
  Law(String n) {
    name = n;
  }

  abstract void apply(Universe u);
  String getName() {
    return name;
  }
}

class Gravity extends Law {
  PVector G;
  Gravity() {
      this(9.8);
  }
  Gravity(float v) {
    this(new PVector(0,v,0));
  }
  Gravity(PVector g) {
    super("Gravity");
    G = g.get();
  }
  void apply(Universe u) {
    PVector force;
    for ( Thing t: u.getMembers() ) {
      if ( ! ( t instanceof Particle ) ) continue;
      Particle p = (Particle)t;
      if ( ! p.hasProperty("Mass") ) continue;
      force = G.get();
      force.mult(p.getProperty("Mass"));
      p.addForce(force);
    }
  }
}

abstract class DragLaw extends Law {
  DragLaw() { super("Drag"); }
}


class DryFriction extends DragLaw {
  float mu;
  DryFriction(float v) {
    super();
    mu = v;
  }
  void apply(Universe u) {
    PVector force;
    for ( Thing t: u.getMembers() ) {
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
  StokesDrag(float v) {
    super();
    coeff = v;
  }
  void apply(Universe u) {
    PVector force;
    for ( Thing t: u.getMembers() ) {
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
    for ( int i1 = 0; i1 < u.countMembers(); i1++ ) {
      p1 = getParticle(u.getMember(i1));
      if ( p1 == null ) continue;                        // Only valid for subclasses of Particle
      if (! p1.hasProperty("Charge") ) continue;         // ...with a charge
      float p1_q = p1.getProperty("Charge");
      for ( int i2 = i1 + 1; i2 < u.countMembers(); i2++ ) {
        p2 = getParticle(u.getMember(i2));
        if ( p2 == null ) continue;                        // Only valid for subclasses of Particle
        if (! p2.hasProperty("Charge") ) continue;
        float p2_q = p2.getProperty("Charge");
        force = p1.getPosition();
        force.sub(p2.getPosition());
        float r = force.mag();
        force.normalize();
        if ( r == 0 ) continue;
        float m = k * p1_q * p2_q / (r*r);
        force.mult(m);
        p1.addForce(force);
        force.mult(-1);
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
    for ( Thing t: u.getMembers() ) {
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
    for ( Thing t: u.getMembers() ) {
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

class Particle implements Thing {
  PVector position;
  PVector velocity;
  PVector acceleration;
  PVector force;
  boolean locked;
  boolean hidden;
  HashMap<String, Property> properties;
  
  Particle(PVector p) {
    this(p,new PVector(0,0,0));
  }

  Particle(PVector p, PVector v) {
    position = p.get();
    velocity = v.get();
    acceleration = new PVector();
    force = new PVector();
    properties = new HashMap<String, Property>();
    locked = false;
  }
  
  PVector getPosition() {
    return position.get();
  }
  
  void setPosition(PVector p) {
    position = p;
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
 * Properties - these apply to Thing Particles
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
