
Universe u;
Emitter e;

void setup() {
  size(640,100);
  u = new Universe();
  u.addLaw(new KillEdge());
  u.addLaw(new Coulomb());
  u.setBounds(0,0,width-10,height);
  e = new Emitter(new PVector(10,height/2), new PVector(100,0), u); 
}

void draw() {
  background(20);
  stroke(200);
  e.update();
  u.update();
  u.paint();
}

class Emitter {
  PVector position;
  PVector velocity;
  Universe u;
  private static float boundary;
  Emitter(PVector p, PVector v, Universe u) {
    position = p;
    velocity = v;
    boundary = 0.2;
    universe = u;
  }
  PVector smudge(PVector i, PVector min, PVector max) {
    PVector smudge = new PVector( random(min.x, max.x), random(min.y, max.y), random(min.z, max.z));
    smudge.add(i);
    return smudge; 
  }
  void update() {
    if ( random(1.0) < boundary ) {
      BigParticle p = new BigParticle(
        position.get(),
        smudge(velocity, new PVector(-50,-1), new PVector(0,1))
        );
      p.addProperty(new Mass(1));
      p.addProperty(new Charge(0.1));
      universe.addThing(p);
    }
  }
}

class BigParticle extends Particle {
  private final int size;
  private final color fillColour;
  BigParticle(PVector p, PVector v) {
    super(p, v);
    fillColour = color(50, 200, 50, 128);
    size = 5;
  }
  void paint() {
    pushMatrix();
    fill(fillColour);
    smooth();
    noStroke();
    translate(position.x, position.y);
    ellipse(0,0,size,size);
    popMatrix(); 
  }
}
