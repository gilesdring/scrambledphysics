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
      if ( p.hasProperty("Mass") ) p.accelerate(PVector.mult( p.force, 1/p.getProperty("Mass")));
    }
  }
}