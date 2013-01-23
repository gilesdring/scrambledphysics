# ScrambledPhysics

ScrambledPhysics is a simple physics engine written in 100% native [Processing][PROCESSING].
The aim of the project is to create a portable (within Processing) which is good enough for basic physics simulations.

[PROCESSING]: http://processing.org/ "Link to Processing website"

# Installation

1. Get the code by either
   * Cloning the git repository to a directory
   * Downloading the zip file
2. Open Processing and create a new project (called anything
   *EXCEPT* `ScrambledPhysics`
3. From the command line, Finder, Explorer or whatever, copy / link
   the file `ScrambledPhysics.pde` into the new Processing directory.
4. Build your universe...

# Key Concepts

## Universe

Every simulation has a universe. Universes have laws and things added to them.

## Laws

Laws affect the universe simulation. Some examples include:

* Gravity - apply a force to every particle in the universe in proportion
  to its mass, and in the direction Gravity is pointing.
* Coulomb - apply a force to every particle based on its charge, and the
  charges of every other particle in the system.

## Things

### Particle
