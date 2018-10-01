/**
 * ScrambledPhysics
 * A rewrite of some earlier hacking.
 * The aim is to create a simple, portable physics library
 */

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

class Connector implements Thing {
  Particle p1, p2;
  boolean firm;

  Connector(Particle _p1, Particle _p2) {
    super();
    p1 = _p1;
    p2 = _p2;
    firm = false;
  }
  void applyForces() {}
  void update() {}
  void paint() { line(p1.position.x,p1.position.y, p2.position.x,p2.position.y); }
  void removed(Universe u) {}
}
