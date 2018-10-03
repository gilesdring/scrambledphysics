class WrapEdge extends EdgeLaw {
  WrapEdge() { super(); }
  WrapEdge(float x, float y, float w, float h) { super(x,y,w,h); }

  void apply(Universe u) {
    PVector pos;
    for ( Thing t: u.getThings() ) {
      if ( ! ( t instanceof Particle ) ) continue;
      Particle p = (Particle)t;
      if ( p.position.x < minX || p.position.x > maxX ) {
        p.position.x = reMap( p.position.x, minX, maxX );
      }
      if ( p.position.y < minY || p.position.y > maxY ) {
        p.position.y = reMap( p.position.y, minY, maxY );
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
