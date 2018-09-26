class BounceEdge extends EdgeLaw {
  boolean DEBUG = false;
  void apply(Universe u) {
    PVector pos;
    for ( Thing t: u.getThings() ) {
      if ( ! ( t instanceof Particle ) ) continue;
      Particle p = (Particle)t;
      int b = bounce( p, u );
      if ( b > 0 && DEBUG ) println( b + " bounces to get into universe" );
    }
  }
  float getOffset(float val, float min, float max) {
    float o = val;
    if ( val < min ) {
      o = ( 2 * min ) - val;
    } else if ( val > max ) {
      o = ( 2 * max ) - val;
    }
    return o;
  }
  int bounce( Particle p, Universe u ) {
    float new_x = getOffset( p.position.x, u.min_x, u.max_x );
    if ( new_x != p.position.x ) {
      p.velocity.x *= -1;
      p.position.x = new_x;
      return bounce(p, u) + 1;
    }
    float new_y = getOffset( p.position.y, u.min_y, u.max_y );
    if ( new_y != p.position.y ) {
      p.velocity.y *= -1;
      p.position.y = new_y;
      return bounce(p, u) + 1;
    }
    return 0;
  }
}
