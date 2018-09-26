class KillEdge extends EdgeLaw {
  void apply(Universe u) {
    for (int i = 0; i < u.things.size(); i++ ) {
      Thing t = u.things.get(i);
      if ( ! ( t instanceof Particle ) ) continue;
      Particle p = (Particle)t;
      if ( ! inUniverse( p, u ) ) {
        u.things.remove(i);
        p.removed(u);
      }
    }
  }
}
