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
    PVector force = new PVector();
    for ( int i1 = 0; i1 < u.countThings(); i1++ ) {
      p1 = getParticle(u.getThing(i1));
      // Only valid for subclasses of Particle...
      if ( p1 == null ) continue;
      // ...with a charge
      if ( p1.charge == 0 ) continue;
      // Store the charge of p1
      float p1_q = p1.charge;
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
        if ( p2.charge == 0 ) continue;
        // Store the charge of p2
        float p2_q = p2.charge;
        // Calculate the vector between the two particles...
        force.x = p1.position.x - p2.position.x;
        force.y = p1.position.y - p2.position.y;
        // ...and the radius (squared)...
        float rr = force.x * force.x + force.y * force.y;
        // ...if that's zero, the particles are in the same place, so we can't calculate a force
        if ( rr == 0 ) continue;
        // Normalise the force vector to unit length
        force.normalize();
        // Calculate the magnitude of the force (according to Coulomb's law)
        float m = k * p1_q * p2_q / rr;
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
