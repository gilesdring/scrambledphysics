/*
 * Define a universe
 */
Universe u;
int population = 1000;

class ExampleParticle extends Particle {
  ExampleParticle(PVector pos) { super(pos); }

  void paint() {
    if ( hidden ) return;
    int particleSize = 10;
    pushMatrix();
    pushStyle();
    translate( position.x, position.y );
    ellipseMode(CENTER);
    noStroke();
    fill(lerpColor(#fc2020, #2045fc, (charge+20.0)/40.0));
    ellipse(0, 0, particleSize, particleSize);
    popStyle();
    popMatrix();
  }
}

void settings() {
  size(800,600);
  smooth();
}

void setup() {
  settings();
  background(50);

  float minX = 50;
  float minY = 50;
  float maxX = width - minX;
  float maxY = height - minY;

  /*
   * In the standard Processing setup function,
   * initialise the universe and populate it with
   * particles
   */
  u = new Universe();

  /*
   * Add laws to the universe
   * Available laws are:
   *   Gravity, Coulomb, StokesDrag
   * Special laws are also defined to deal with particles
   * that reach the edge of the universe
   *   BounceEdge, WrapEdge, KillEdge
   * The edge of the universe defaults to the edge of the
   * screen at the time the universe was initialised.
   */
  // Makes particles with charge act accordingly
  u.addLaw(new Coulomb());
  // Applies drag proportional to the velocity of the particle
  u.addLaw(new StokesDrag(0.1));
  // Makes particles wrap at the edges
  u.addLaw(new WrapEdge(minX, minY, maxX - minX, maxY - minY));
  // Add Newtonian Mechanics
  u.addLaw(new NewtonsLaws());

  for (int i = 0; i < population; i++) {
    // Initialise a series of particles at random positions
    PVector position = new PVector(
      random(minX, maxX),
      random(minY, maxY)
    );
    Particle p = new ExampleParticle(position);
    // Give each particle a mass...
    p.setMass(random(10,20));
    // ...and a charge of +10 or -10
    p.setCharge(random(100) < 50 ? -10 : +10);

    // Add the particle to the universe
    u.addThing(p);
  }
}

void draw() {
  /*
   * Blank the screen with transparency set to fade out older
   */
  noStroke();
  fill(20,10);
  rect(0,0,width,height);
  /*
   * Update the universe (which applies all laws
   * and updates the particles
   */
  u.update();

  /*
   * Paint the universe, which calls the paint method
   * of the particles in the universe.
   * NB - because the default paint behaviour of the
   * Particle class is a bit boring, we'd typically want
   * to subclass and override the paint method to do something
   * more interesting. Here we're just using the default, which
   * means we also need to set the stroke colour.
   */
  stroke(180);
  u.paint();

  /*
   * Add a label
   */
  label("ScrambledPhysics Example sketch", 5, height-5);

  /*
   * Print frame rate
   */
  label(
    "Pop: " + population
    + " | Rate: " + round(frameRate*10)/10.0 + " ["
    + (u.barnesHut ? "B" : "")
    + (u.DEBUG ? "D" : "")
    + "]",
    width-205, height-5);
}

void label(String message, float x, float y) {
  pushMatrix(); pushStyle();
  translate(x, y);
  noStroke();
  fill(180);
  rect(0, 0, 205, -18, 5);
  fill(20);
  text(message, 5, -5);
  popStyle(); popMatrix();
}

void keyReleased() {
  if ( key == 'b' || key == 'B' ) {
    u.barnesHut = ! u.barnesHut;
    return;
  }
  if ( key == 'd' || key == 'D' ) {
    u.DEBUG = ! u.DEBUG;
  }
}
