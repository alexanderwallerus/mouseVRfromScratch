# mouse VR test

This is just a quick proof of concept put together in a few hours to look into the doability of putting together a simple VR system for mice from scratch.

Turning of a rotary encoder moves the mouse forward or backwards in its environment.
2 environments are implemented, a traversable 3d corridor and a right/left movable 2D ellipse.
The environment is shown along multiple surrounding computer screens.

Once the animal achieves its goal (reaches the end of the corridor or the right end of the 2D environment) the environment is temporarily blacked out, a reward-stand-in LED is turned on, and the position in the environment gets reset.

![usage](/gitReadmeFiles/corridor0.png)