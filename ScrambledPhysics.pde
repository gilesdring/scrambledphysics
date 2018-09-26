/**
 * ScrambledPhysics
 * A rewrite of some earlier hacking.
 * The aim is to create a simple, portable physics library
 */

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

class SpringRate extends Property {
  SpringRate(float v) { super(v, "Spring Rate"); }
}
class Length extends Property {
  Length(float v) { super(v, "Length"); }
}

class Connector extends ScrambledObject implements Thing {
  Particle p1, p2;
  boolean firm;
  Connector(Particle _p1, Particle _p2) {
    super();
    p1 = _p1;
    p2 = _p2;
    firm = false;
  }
  void applyForces() {
    if ( hasProperty("Spring Rate" ) ) {
      PVector diff = PVector.sub(p1.position, p2.position);
      float springLength = hasProperty("Length") ? getProperty("Length") : 0;
      float mag = firm ? max( diff.mag() - springLength, 0) : diff.mag() - springLength;
      mag = mag * getProperty("Spring Rate");
      p1.addForce( PVector.mult(diff, -mag ) );
      p2.addForce( PVector.mult(diff, mag ) );
    }
  }
  void update() {}
  void paint() { line(p1.position.x,p1.position.y, p2.position.x,p2.position.y); }
  void removed(Universe u) {}
}
