# CS 5010: Problem Set 9

You have taken a job in a toy factory. You job is to simulate the following marvelous toy:

- The toy consists of a canvas that is 600 pixels high and 500 pixels wide.
- On the canvas, the system displays a circle of radius 10 in outline mode. The circle initially appears in the center of the canvas. We call this circle the "target."
- The child interacts with the toy by dragging the target (using smooth drag, as usual) and by typing characters into the system. Each of the characters listed below causes a new toy to be created with its center located at the center of the target. Toys are also moveable using smooth drag.
- When the child types "s", a new square-shaped toy pops up. It is represented as a 40x40 pixel outline square. When a square-shaped toy appears, it begins travelling rightward at a constant rate. When its edge reaches the edge of the canvas, it executes a Perfect Bounce.
- When the child types "t", a new throbber appears. A throbber starts as a solid green circle of radius 5. At every tick, it expands gradually until it reaches a radius of 20. Once it reaches a radius of 20, it contracts gradually until it reaches a radius of 5, and then resumes its cycle.
- When the child types "w", a clock appears. This clock displays the number of ticks since it was created. Otherwise the appearance of the clock is unspecified.
- When the child types "f", a Official Tom Brady Deflatable Football(TM) [*] appears. Go out on the net and find an image of a football. The TBDF initially appears as an image of a football, but it gets smaller with every tick until it reaches size 0.
- As usual, you are not responsible for anything that happens after the mouse leaves the canvas.
- There are many unspecified parameters in the description above. Choose parameters (like speed, the exact way in which items grow and shrink, etc.) so that the result is visually satisfying.

I believe this problem is easier than the last one, so have some fun with it.

Your solution should be a file named toys.rkt and should provide the following interfaces and functions:

    make-world : PosInt -> PlaygroundState<%>
    RETURNS: a world with a target, but no toys, and in which any
    square toys created in the future will travel at the given speed (in
    pixels/tick). 

    run : PosNum PosInt -> PlaygroundState<%> 
    GIVEN: a frame rate (in seconds/tick) and a square-speed (in pixels/tick),
    creates and runs a world in which square toys travel at the given
    speed.  Returns the final state of the world.

    make-square-toy : PosInt PosInt PosInt -> Toy<%>
    GIVEN: an x and a y position, and a speed
    RETURNS: an object representing a square toy at the given position,
    travelling right at the given speed.

    make-throbber: PosInt PosInt -> Toy<%>
    GIVEN: an x and a y position
    RETURNS: an object representing a throbber at the given position.

    make-clock : PosInt PostInt -> Toy<%>
    GIVEN: an x and a y position
    RETURNS: an object representing a clock at the given position.

    make-football : PosInt PostInt -> Toy<%>
    GIVEN: an x and a y position
    RETURNS: an object representing a football at the given position.

Interfaces:

      (define PlaygroundState<%>
          (interface (WorldState<%>) ;; this means: include all the methods in
                                     ;; WorldState<%>. 
    
      ;; -> Integer
      ;; RETURN: the x and y coordinates of the target
      target-x
      target-y

      ;; -> Boolean
      ;; Is the target selected?
      target-selected?

      ;; -> ListOfToy<%>
      get-toys
      
        ))

     (define Toy<%> 
          (interface (Widget<%>)  ;; this means: include all the methods in
                                  ;;  Widget<%>. 
      ;; -> Int
      ;; RETURNS: the x or y position of the center of the toy
      toy-x
      toy-y

      ;; -> Int
      ;; RETURNS: some data related to the toy.  The interpretation of
      ;; this data depends on the class of the toy.
      ;; for a square, it is the velocity of the square (rightward is
      ;; positive)
      ;; for a throbber, it is the current radius of the throbber
      ;; for the clock, it is the current value of the clock
      ;; for a football, it is the current size of the football (in
      ;; arbitrary units; bigger is more)
      toy-data
    
      ))
When you do this problem, remember the principle of Iterative Development: get something simple working, and then add features as necessary.