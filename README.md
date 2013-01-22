# ScrambledPhysics

ScrambledPhysics is a simple physics engine written in 100% native [Processing][PROCESSING].
The aim of the project is to create a portable (within Processing) which is good enough for basic physics simulations.

[PROCESSING]: http://processing.org/ "Link to Processing website"

# Key Concepts

## Universe

Every simulation has a universe. Universes have [laws][Laws] and [things][Things] added to them.

## Laws

Laws affect the universe simulation. Some examples include:

* Gravity - apply a force to every [particle][Particle] in the universe in proportion
  to its mass, and in the direction Gravity is pointing.
* Coulomb - apply a force to every [particle][Particle] based on its charge, and the
  charges of every other particle in the system.

## Things

### Particle
