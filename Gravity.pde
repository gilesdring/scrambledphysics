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
