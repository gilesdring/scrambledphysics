class StokesDrag extends DragLaw {
  float coeff;
  StokesDrag() { this(0.1); }
  StokesDrag(float v) {
    super();
    coeff = v;
  }
  void apply(Universe u) {
    PVector force = new PVector();
    for ( Thing t: u.getThings() ) {
      if ( ! ( t instanceof Particle ) ) continue;
      Particle p = (Particle)t;
      force.x = p.velocity.x * -coeff;
      force.y = p.velocity.y * -coeff;
      p.addForce( force );
    }
  }
}
