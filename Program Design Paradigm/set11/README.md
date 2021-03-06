<h1>CS 5010: Problem Set 11</h1>

<hr>

<p>Your task is to simulate a dimensionless particle bouncing in a
150x100 rectangle.  For this system, you will produce 5
viewer-controllers:</p>

<ol>
  
  <li>A position controller, similar to the one in the Examples, but
  using the arrow keys to move the particle in the x or y direction.</li>

  <li>A velocity controller, similar to the one in the Examples, but
  using the arrow keys to alter the velocity of the particle in the x
  or y direction.</li>

  <li>Both the position and velocity controllers display both the
  position and velocity of the particle, as in the demo.</li>

  <li>An XY controller, which shows a representation of the particle
  bouncing in the rectangle.  With this controller, the user can drag
  the particle using the mouse.   Dragging the mouse causes the
  particle to follow the mouse pointer via a Smooth Drag.</li>

  <li>An X controller, which is like the XY controller, except that it
  displays only the x coordinate of the particle's motion.  Dragging
  the mouse in the X controller alters the particle's position in the
  x direction.</li>

  <li>A Y controller, which is like the X controller except that it
  works in the y direction.</li>

</ol>

  <p>Here's a <a href="http://www.ccs.neu.edu/course/cs5010f15/Problem%20Sets/Videos/11-mvc.mp4">demonstration:</a></p>

<p>Note that the first time I hit button-down inside the canvas of
the XY controller, I accidently did so _at_ the particle location.
That was a mousing error.  The particle obeys smooth drag, not
snap-to-mouse-location.  You can also drag the mouse in the X and Y
controllers, not demonstrated here.</p>

<p>Here are some more detailed specifications:</p>

<ol>

  <li>The entire system works on a 600 x 500 canvas.  </li>

  <li>You must use the world from <a href="ParticleWorld.rkt"
  >ParticleWorld.rkt</a></li> 

  <li>I don't want you spending time on the geometry of the Perfect
  Bounce.  I've provided a file called <a href="PerfectBounce.rkt"
  >PerfectBounce.rkt</a> that calculates this for you.</li>

  <li>You must use inheritance to factor out the common parts of the
  various controllers.</li>

  <li>Hitting one of the following keys causes a new controller to
  appear in the center of the canvas:<p></p>

  <ul>
    <li>"p" : Position controller</li>
    <li>"v" : velocity controller</li>
    <li>"x" : X controller</li>
    <li>"y" : Y controller</li>
    <li>"z" : XY controller</li>
  </ul>

</li>

  <li>Each controller has a 10x10 handle.  Dragging on the handle
  moves the controller around the canvas. </li>

  <li>A button-down inside a controller selects the controller for
  input.</li>

  <li>In the position or velocity controller, the arrow keys are used
  for input.  The arrow keys alter the position or velocity of the
  particle in the indicated direction.  Each press of an arrow key
  alters the appropriate quantity by 5.</li>

  <li>In the X, Y, or XY controller, the mouse drags the particle via
  smooth drag.  The mouse need not be in the representation of the
  particle; it need only be in the controller.</li>

  <!-- <li>The model must report every change in the particle's position or -->
  <!-- velocity to its registered listeners, using the Signal data -->
  <!-- definition, given in interfaces.rkt .  It must also report its -->
  <!-- current position and velocity to each newly registered listener.</li> -->

  <li>Deliver your solution as a set of files, including
  ParticleWorld.rkt and PerfectBounce.rkt, and a file mvc.rkt that
  provides a function

  <pre>
run : PosReal -> Void
GIVEN: a frame rate, in sec/tick
EFFECT: Creates and runs the MVC simulation with the given frame rate.
</pre>

</li>

</ol>





<hr>
<address></address>
<font size=-1>
<p align=right>
<!-- hhmts start -->
Last modified: Sat Nov 28 09:39:31 Eastern Standard Time 2015 <!-- hhmts end -->
</body> </html>
