Universe u;
Particle mouse;

void setup() {
  size(640,480);
  u = new Universe();
  u.addLaw(new Hooke());
  u.addLaw(new Coulomb());
  u.addLaw(new StokesDrag());
  Particle root = new Particle(new PVector(width/2,height/2));
  root.lock();
  u.addThing(root);
  Charge chr = new Charge(10.0);
  for (int i = 0; i< 100; i++ ) {
    Blob p2 = new Blob(new PVector(random(0,width),random(0,height)));
    p2.addProperty(new Mass(1.0));
    p2.addProperty(chr);
    Connector c = new Connector(root, p2);
    c.addProperty(new SpringRate(0.001));
    c.addProperty(new Length(100));
    u.addThing(p2);
    u.addThing(c);
  }
  mouse = new Particle(new PVector(mouseX, mouseY));
  mouse.addProperty(new Charge(100.0));
  mouse.lock();
  u.addThing(mouse);
  
  
}

void draw() {
  noCursor();
  background(20);
  mouse.setPosition(new PVector(mouseX, mouseY));
  u.update();
  u.paint();
}


class Blob extends Particle {
  Blob(PVector p) {
    super(p);
  }
 void paint() {
   pushMatrix();
   fill(color(20,200,100));
   noStroke();
   ellipse(position.x,position.y,2,2);
   popMatrix();
 } 
}

