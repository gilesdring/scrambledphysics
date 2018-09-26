class Hooke extends Law {
  Hooke() {
    super("Hooke");
  }
  void apply(Universe u) {
    Connector con;
    for ( Thing t: u.getThings() ) {
      if ( t instanceof Connector ) {
        con = (Connector)t;
        con.applyForces();
      }
    }
  }
}
