#CS 5010: Problem Set 03: Iterative Design

The goal of this problem set is to help you design functions that deal with the Universe model, and to give you practice with the Iterative Design Recipe.

You will also get experience with the Perfect Bounce and Smooth Dragging, which we will be using in many of our exercises.

## 1. screensaver-1.rkt

(screensaver-1). Your boss has assigned you to a project to build a screensaver. The specifications for the screensaver are as follows:
- The screensaver is a universe program that displays two rectangles that move around a canvas.
- The rectangles bounce smoothly off the edge of the canvas. Bouncing is defined as follows: if the rectangle in its normal motion would hit or go past one side of the canvas at the next tick, then instead at the next tick it should appear tangent to the edge of the canvas, travelling at the same speed, but in the opposite direction. If the rectangle would go past a corner, then both the x- and y- velocities are reversed. We call this a perfect bounce.
- Each rectangle is displayed as an outline blue rectangle 60 pixels wide and 50 pixels high. In addition, the rectangle's current velocity is displayed as a string (vx, vy) in the center of the rectangle.
- The space bar pauses or unpauses the entire simulation. The simulation is initially paused.
- The canvas is 400 pixels wide and 300 pixels high.
- The two rectangles are initially centered at positions (200,100) and (200,200), and have velocities of (-12, 20) and (23, -14), respectively. Remember that we are using computer-graphics coordinates, in which y increases as you go down the page (south).

Here's a demo
[Click Here For Video Demo] (http://www.ccs.neu.edu/course/cs5010/Problem%20Sets/ps03-demo1.mp4)

You are to deliver a file named screensaver-1.rkt that provides the following functions:

     ;; screensaver : PosReal -> WorldState  
     ;; GIVEN: the speed of the simulation, in seconds/tick  
     ;; EFFECT: runs the simulation, starting with the initial state as  
     ;; specified in the problem set.  
     ;; RETURNS: the final state of the world  

     ;; initial-world : Any -> WorldState  
     ;; GIVEN: any value (ignored)  
     ;; RETURNS: the initial world specified in the problem set  

     ;; world-after-tick : WorldState -> WorldState  
     ;; RETURNS: the world state that should follow the given world state  
     ;; after a tick.  

     ;; world-after-key-event : WorldState KeyEvent -> WorldState  
     ;; RETURNS: the WorldState that should follow the given worldstate  
     ;; after the given keyevent  

     ;; world-rect1 : WorldState -> Rectangle  
     ;; world-rect2 : WorldState -> Rectangle  
     ;; world-paused? : WorldState -> Boolean  
     ;; RETURNS: the specified attribute of the WorldState  
     ;; NOTE: if these are part of the world struct, you don't need to  
     ;; write any deliverables for these functions.  

     ;; new-rectangle : NonNegInt NonNegInt Int Int -> Rectangle  
     ;; GIVEN: 2 non-negative integers x and y, and 2 integers vx and vy  
     ;; RETURNS: a rectangle centered at (x,y), which will travel with  
     ;; velocity (vx, vy).  

     ;; rect-x : Rectangle -> NonNegInt  
     ;; rect-y : Rectangle -> NonNegInt  
     ;; rect-vx : Rectangle -> Int  
     ;; rect-vy : Rectangle -> Int  
     ;; RETURNS: the coordinates of the center of the rectangle and its  
     ;; velocity in the x- and y- directions.  

## 2. screensaver-2.rkt

(screensaver-2). Your boss has now decided to build a better screensaver. This one is like the original, except for the following:
- The rectangle is selectable and draggable. Depressing the mouse button within the rectangle causes the rectangle to be "selected". When the rectangle is selected, it and its velocity are displayed in red instead of blue.
- The location where the mouse grabbed the rectangle should be indicated by an outline red circle of radius 5 pixels. Simply pressing the mouse button, without moving the mouse, should not cause the rectangle to move on the canvas.
- Once the rectangle has been selected, you should be able to drag it around the Universe canvas with the mouse. As you drag it, the position of the mouse within the rectangle (as indicated by the red circle), should not change. When the mouse button is released, the rectangle should go back to its unselected state (outline blue) in its new location.
- All of this works whether or not the simulation is paused.
- We refer to this behavior as "smooth dragging." We will be implementing other objects with this behavior in future problem sets.

Here's a demo [Click Here For Video Demo] (http://www.ccs.neu.edu/course/cs5010/Problem%20Sets/ps03-demo2.mp4)

You are to deliver a file named screensaver-2.rkt that provides all the functions above, plus the following:

     ;; world-after-mouse-event  
     ;;  : WorldState Int Int MouseEvent -> WorldState  
     ;;   
     ;; GIVEN: A World, the x- and y-coordinates of a mouse event, and the  
     ;; mouse event  
     ;; RETURNS: the world that should follow the given world after the given mouse  
     ;; event.  

     ;; rect-after-mouse-event :  Rectangle Int Int MouseEvent -> Rectangle  
     ;; GIVEN: A rectangle, the x- and y-coordinates of a mouse event, and the  
     ;; mouse event  
     ;; RETURNS: the rectangle that should follow the given rectangle after  
     ;; the given mouse event  

     ;; rect-selected? : Rectangle -> Boolean  
     ;; RETURNS: true iff the given rectangle is selected.  
  
     ;; new-rectangle  
     ;; as before, but now it returns an UNSELECTED rectangle.  