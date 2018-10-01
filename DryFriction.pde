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
