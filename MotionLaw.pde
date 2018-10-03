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
      PVector acceleration = p.force.copy();
      acceleration.x /= p.mass;
      acceleration.y /= p.mass;
      acceleration.z /= p.mass;
      if ( p.mass != 0 ) p.accelerate(acceleration);
    }
  }
}
