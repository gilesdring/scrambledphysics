class WrapEdge extends EdgeLaw {
  void apply(Universe u) {
    PVector pos;
    for ( Thing t: u.getThings() ) {
      if ( ! ( t instanceof Particle ) ) continue;
      Particle p = (Particle)t;
      if ( p.position.x < u.min_x || p.position.x > u.max_x ) {
        p.position.x = reMap( p.position.x, u.min_x, u.max_x );
      }
      if ( p.position.y < u.min_y || p.position.y > u.max_y ) {
        p.position.y = reMap( p.position.y, u.min_y, u.max_y );
      }
    }
  }
  float reMap(float v, float min, float max) {
    float w = max - min;
    float o = ( v - min ) / w;
    while ( o < 0 ) o++;
    return min + ( ( o - int(o) ) * w );
  }
}
