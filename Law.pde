/**
 * Base class for all Laws subsequently added to the universe
 */
abstract class Law {
  /**
   * Name of the law - each Law which extends this abstract class must set this
   */
  final String name;

  /**
   * Default constructor
   *
   * @param n Name to set for the class
   */
  Law(String n) {
    name = n;
  }

  /**
   * Apply the law to a given universe
   *
   * @param u Universe to which this law should be applied
   */
  abstract void apply(Universe u);

  /**
   * Get the name of the law
   *
   * @return the name of the law as set by the construtor
   */
  String getName() { return name; }
}
