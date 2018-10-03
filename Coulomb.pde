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
