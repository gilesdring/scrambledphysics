/**
 * The <code>Thing</code> interface must be implemented for anything
 * that could be added to a universe. It defines the api which the
 * universe depends upon.
 */
interface Thing {
  /**
   * The <code>update</code> method will be called once per update
   * of the universe.
   */
  void update();
  /**
   * The <code>paint</code> method should draw the Thing, and will be
   * called when the universe is painted.
   */
  void paint();
  /**
   * The <code>removed</code> method is called if the particle is removed
   * from the universe, and can be overridden to perform some useful
   * behaviour like re-adding the particle to the universe, or cleaning up
   * other references
   *
   * @param u Universe from which the particle has been removed.
   */
  void removed(Universe u);
}
