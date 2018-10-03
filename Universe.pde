/**
 * The <code>Universe</code> class is the core of the simulation. Each
 * Universe can have laws applied to it, and things added to it.
 */
class Universe {
  /**
   * An <code>ArrayList</code> containing all the things that have been
   * added to the universe
   */
  ArrayList<Thing> things;
  /**
   * A series of floats containing the bounds of the defined universe
   */
  float max_x, min_x, max_y, min_y;

  float footprintMaxX, footprintMaxY, footprintMinX, footprintMinY;
  /**
   * A <code>HashMap</code> of the laws that apply to the universe.
   */
  HashMap<String, Law> laws;

  BHTree bhTree;
  boolean barnesHut;
  boolean DEBUG = false;

  /**
   * Default constructor, initialises the <code>things</code> ArrayList and
   * <code>laws</code> HashMap, and sets the bounds of the universe to the
   * size of the current sketch.
   */
  Universe() {
    this(true); // Default Barnes Hut simulation
  }
  Universe(boolean optimised) {
    things = new ArrayList<Thing>();
    laws = new HashMap<String, Law>();
    barnesHut = optimised;
    setBounds();
    initBhTree();
  }
  /**
   * Add a thing to the universe
   *
   * @param t Thing to add to the universe
   */
  void addThing(Thing t) {
    things.add(t);
  }
  /**
   * Get the full ArrayList of things in the universe
   */
  ArrayList<Thing> getThings() {
    return things;
  }
  /**
   * Get a thing from the universe
   */
  Thing getThing(int i) {
    return things.get(i);
  }
  /**
   * Count the number of things in the universe
   */
  int countThings() {
    return things.size();
  }
  /**
   * Add a law to the universe
   * Each law has a name, which is used to ensure that only one law of any type
   * is added to the universe (e.g. EdgeLaws all have the name "Edge"). The laws
   * are stored in a HashMap to ensure uniqueness.
   */
  void addLaw(Law l) {
    laws.put(l.getName(), l);
  }
  /**
   * Update the state of the universe. This should be called whenever you want
   * the universe to be updated - typically whenever the sketch is drawn
   */
  void update() {
    // Set up Barnes Hut Tree
    initBhTree();

    try {
      laws.get("Edge").apply(this);
    } catch(NullPointerException e) {}

    // Set up Barnes Hut Tree
    initBhTree();

    // Iterate through the laws applied to the universe
    for (Law law : laws.values()) {
      if ( (law instanceof EdgeLaw) || (law instanceof MotionLaw) ) {
        /*
         * We want Edge laws to apply first and motionlaws to apply last
         */
        continue;
      }
      /*
       * Apply the law to the universe. This will typically alter the state of the
       * members in the universe (e.g. applying forces, changing position, etc)
       * although it could do absolutely anything!
       */
      law.apply(this);
    }

    try {
      laws.get("Motion").apply(this);
    }
    catch(NullPointerException e) {}

    /*
     * Iterate through all the things in the universe and update them. Typically
     * this will calculate the acceleration, velocity and position, but could do
     * anything...
     */
    for (Thing t: things) t.update();
  }
  /**
   * Paint the universe by calling the paint method of everything in the universe.
   * Things do not need to paint themselves using this method - in which case a separate way of
   * painting them needs to be implemented.
   */
  void paint() {
    if (DEBUG && bhTree != null) bhTree.paint();
    for (Thing t: things) { t.paint(); }
  }

  /**
   * Set the bounds of the universe to between x_min, y_min and x_max, y_max
   */
  void setBounds(float x_min, float y_min, float x_max, float y_max) {
    footprintMinX = MAX_FLOAT;
    footprintMinY = MAX_FLOAT;
    footprintMaxX = -MAX_FLOAT;
    footprintMaxY = -MAX_FLOAT;
    for (Thing t: things) {
      if (t instanceof Particle) {
        PVector pos = ((Particle)t).getPosition();
        footprintMinX = min( footprintMinX, pos.x );
        footprintMinY = min( footprintMinY, pos.y );
        footprintMaxX = max( footprintMaxX, pos.x );
        footprintMaxY = max( footprintMaxY, pos.y );
      }
    }
    min_x = x_min;
    min_y = y_min;
    max_x = x_max;
    max_y = y_max;
  }

  /**
   * Set the bounds of the universe to the current screen size
   */
  void setBounds() { setBounds(0, 0, width, height); }

  /**
   * Barnes Hut related functions
   */
  void initBhTree() {
    setBounds();
    if ( barnesHut ) {
      bhTree = new BHTree(footprintMinX - 10, footprintMinY - 10, max( footprintMaxX - footprintMinX, footprintMaxY - footprintMinY ) + 21);
      for (Thing t: things) {
        if (t instanceof Particle) {
          bhTree.insert((Particle)t);
        }
      }
    } else {
      bhTree = null;
    }
  }
  BHTree getBhTree() { return bhTree; }
}
