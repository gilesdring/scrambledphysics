class BHTree {
  Particle body;   // body or aggregate body stored in this node
  PVector origin;
  float dimension;
  BHTree[] subs;    // tree representing quadrants

  BHTree( float x, float y, float s ) {
    origin = new PVector( x, y );
    dimension = s;
    subs = null;
    body = null;
  }

  void insert( Particle a ) {
    if ( ! contains ( a ) ) {
      return;
    }
    if ( body == null ) {                            // This is an empty BHTree
      body = a;
    } else {
      if ( subs == null ) {                       // This is an external BHTree
        subs = new BHTree[4];
        float halfSize = dimension / 2;
        subs[0] = new BHTree( origin.x, origin.y, halfSize );
        subs[1] = new BHTree( origin.x, origin.y + halfSize, halfSize );
        subs[2] = new BHTree( origin.x + halfSize, origin.y, halfSize );
        subs[3] = new BHTree( origin.x + halfSize, origin.y + halfSize, halfSize );
        Particle oldbody = body;
        body = new Particle( oldbody.getPosition() );
        body.setCharge(oldbody.charge);
        body.setMass(oldbody.mass);
        for ( BHTree subTree: subs ) {
          subTree.insert(oldbody);
          subTree.insert(a);
        };
      } else {
        for ( BHTree subTree: subs ) subTree.insert(a);
      }
      update_body( a );
    }
  }

  void update_body( Particle a ) {
    // This is an aggregate attractor if it's an internal node
    /// HMMMMMMM!!! Centre of mass and centre of charge will have different locations... Focus on charge to start with...
    float newMass = body.mass + a.mass;
    body = calculateCentreOfCharge(body, a);
    body.setMass(newMass);
  }

  Particle calculateCentreOfCharge(Particle a, Particle b) {
    // TODO this isn't quite right at the moment. But it's righter.
    float mag = abs(a.charge) + abs(b.charge);
    Particle result = new Particle(
      PVector.add(
        PVector.mult(a.position, abs(a.charge)/mag),
        PVector.mult(b.position, abs(b.charge)/mag)
      )
    );
    result.setCharge(a.charge + b.charge);
    return result;
  }

  boolean contains( Particle a ) {
    PVector pos = a.getPosition();
    return ( ( pos.x >= origin.x ) && ( pos.x < origin.x + dimension ) && ( pos.y >= origin.y ) && ( pos.y < origin.y + dimension ) );
  }

  void paint() {
    pushMatrix();
    pushStyle();
    stroke( 50 );
    noFill();
    translate( origin.x, origin.y );
    rect( 0,0,dimension,dimension );
    popMatrix();
    if ( body != null ) {
      pushMatrix();
      translate(body.position.x-10, body.position.y-10);
      line(0,10,20,10);
      line(10,0,10,20);
      popMatrix();
    }
    popStyle();
    if ( subs != null ) {
      subs[0].paint();
      subs[1].paint();
      subs[2].paint();
      subs[3].paint();
    }
  }
}
