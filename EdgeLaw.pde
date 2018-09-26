abstract class EdgeLaw extends Law {
  EdgeLaw() { super("Edge"); }
  boolean inUniverse(Particle p, Universe u) {
    return ( p.position.x > u.min_x ) && ( p.position.x < u.max_x ) && ( p.position.y > u.min_y ) && ( p.position.y < u.max_y );
  }
}
