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
