class KillEdge extends EdgeLaw {
  KillEdge() { super(); }
  KillEdge(float x, float y, float w, float h) { super(x,y,w,h); }

  void apply(Universe u) {
    for (int i = 0; i < u.things.size(); i++ ) {
      Thing t = u.things.get(i);
      if ( ! ( t instanceof Particle ) ) continue;
      Particle p = (Particle)t;
      if ( ! inUniverse( p ) ) {
        u.things.remove(i);
        p.removed(u);
      }
    }
  }

  boolean inUniverse(Particle p) {
    return ( p.position.x > minX ) && ( p.position.x < maxX ) && ( p.position.y > minY ) && ( p.position.y < maxY );
  }
}
