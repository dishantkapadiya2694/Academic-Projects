# CS 5010: Problem Set 10

1. Your boss at the toy factory has been taking PDP, and he has been persuaded to buy a "framework" from WidgetWorks International. The framework was delivered as a file called WidgetWorks.rkt that provides three interfaces and one function, as follows:


          (define StatefulWorld<%>
          (interface ()

          ; Widget<%> -> Void
          ; GIVEN: A widget
          ; EFFECT: add the given widget to the world
          add-widget

          ; SWidget -> Void
          ; GIVEN: A stateful widget
          ; EFFECT: add the given widget to the world
          add-stateful-widget

          ; PosReal -> Void
          ; GIVEN: a framerate, in secs/tick
          ; EFFECT: runs this world at the given framerate
            run

        ))

		;; Every functional object that lives in the world must implement the
		;; Widget<%> interface.
		(define Widget<%>
			(interface ()
			    ; -> Widget<%>
    			; GIVEN: no arguments
    			; RETURNS: the state of this object that should follow at the next tick.
			    after-tick          

			    ; Integer Integer -> Widget<%>
			    ; GIVEN: a location
			    ; RETURNS: the state of this object that should follow the
			    ; specified mouse event at the given location.
			    after-button-down
			    after-button-up
			    after-drag

			    ; KeyEvent : KeyEvent -> Widget
			    ; GIVEN: a key event
			    ; RETURNS: the state of this object that should follow the
			    ; given key event
			    after-key-event     

			    ; Scene -> Scene
			    ; GIVEN: a scene
			    ; RETURNS: a scene like the given one, but with this object
			    ; painted on it.
			    add-to-scene
	    ))

		;; Every stable (stateful) object that lives in the world must implement the
		;; SWidget<%> interface.

		(define SWidget<%>
			(interface ()

			    ; -> Void
			    ; GIVEN: no arguments
			    ; EFFECT: updates this widget to the state it should have
    			; following a tick.
    			after-tick          

    			; Integer Integer -> Void
    			; GIVEN: an x and a y coordinate
    			; EFFECT: updates this widget to the state it should have
    			; following the specified mouse event at the given location.
    			after-button-down
    			after-button-up
    			after-drag

    			; KeyEvent : KeyEvent -> Void
    			; GIVEN: a key event
    			; EFFECT: updates this widget to the state it should have
    			; following the given key event
    			after-key-event     

    			; Scene -> Scene
    			; GIVEN: a scene
    			; RETURNS: a scene like the given one, but with this object
    			; painted on it.
    			add-to-scene
    	))

    	;; make-world : NonNegInt NonNegInt -> StatefulWorld<%>
    	;; GIVEN: the width and height of a canvas
    	;; RETURNS: a StatefulWorld object that will run on a canvas of the
    	;; given width and height.

You are relieved to see that these interfaces are much like the ones you've been working with. The difference is that you will run the objects by creating a StatefulWorld, adding your widgets to it, and then calling the run method on your world. You no longer need to call big-bang yourself.

Your job is to reimplement the toy from problem set 9, but using the WidgetWorks framework and stateful objects. The specifications are exactly the same, except that:

 - PlaygroundState<%> inherits from SWidget<%> instead of WorldState<%>
 - Toy<%> inherits from SWidget<%> instead of Widget<%>.
 - Since WidgetWorks has comandeered the make-world function, you should provide a function called make-playground instead.
 - Also, the contract for the run function should be run : PosNum PosInt -> Void. Note that this change relaxes the previous contract,   since now any value is acceptable as a return value from run.

Turn in your solution as a file named "toys.rkt". Put a copy of WidgetWorks.rkt in the directory with your solution. YOU MAY NOT MODIFY WidgetWorks.rkt IN ANY WAY. WE MAY TEST YOUR SOLUTION WITH OUR OWN IMPLEMENTATION OF StatefulWorld<%>.

2.&nbsp;Your boss at the toy factory asks you to produce a new toy inspired by Cubelets, which are square blocks that stick together. The new toy has the following specification:

 - The toy consists of a canvas that is 600 pixels high and 500 pixels wide.
 - When the child types "b", a new block pops up on the screen at the location of the last button-down or button-up. The block appears   as a 20x20 outline square. The square is initially green. If the child types a "b" before the first button-down or button-up event,   then the first block appears in an unspecified but fixed place on the canvas.
 - A block does not move by itself, but the child can move it around using Smooth Drag. When the block is selected, it appears as red   rather than green.
 - If a block is dragged so that it contacts or overlaps another block, the two blocks become connected. We say that the blocks are   
   teammates.. The property of being a teammate is symmetric and transitive. So if block A is moved to touch block B, then a new team is formed consisting of A and all its teammates, and B and all its teammates.
 - Two blocks overlap if they intersect at any point. For this purpose, the edges of the block are considered part of the block.
 - Once two blocks become teammates, they remain teammates forever.
 - When a block is moved, all its teammates move along with it. If A and B are teammates, and A is dragged in some direction, then B    moves the same way.
 - Only the selected block accumulates teammates. If A is being dragged, and B is a teammate of A, and A's motion causes B to come   
   into contact with C, C does not become a teammate of A and B. In the video below, we call the selected block the "leader." But you can drag a team by selecting any block in the team, so the leader may be different on different drags.

Your solution should be a file named cubelets.rkt that provides the following functions:

    make-playground : -> PlaygroundState
    GIVEN: no arguments
    RETURNS: a PlaygroundState

    make-block : NonNegInt NonNegInt ListOfBlock<%> -> Block<%>
    GIVEN: an x and y position, and a list of blocks
    WHERE: the list of blocks is the list of blocks already on the playground.
    RETURNS: a new block, at the given position, with no teammates
    NOTE: it is up to you as to whether you use the third argument or
    not.  Some implementations may use the third argument; others may not.

The Block<%> interface extends the SWidget<%> interface with AT LEAST
the following methods:

    get-team : -> ListOfBlock<%>
    RETURNS: the teammates of this block

    add-teammate: Block<%> -> Void
    EFFECT: adds the given block to this block's team

    block-x : -> Integer
    block-y : -> Integer
    RETURNS: the x or y coordinates of this block
    You may put more methods in the Block<%> interface if you so desire. Remember that a method must appear in the interface if and only if it is called from outside this object.

There are several places where information must be disseminated in this problem, either by pushing or pulling. Be prepared to identify these and to discuss your design decisions about each of them.


As in the problem above, you must use WidgetWorks.rkt .  


DELIVERING YOUR SOLUTION IN MULTIPLE FILES: As you've no doubt noticed, your programs have become longer, and it is awkward to navigate to a particular definition. So effective with this problem set, you may split your solution over multiple files if you so desire. Here are some ground rules:
 - All of the files for both questions must live in the same directory, as usual.
 - Your directory must include a copy of WidgetWorks.rkt and extras.rkt .
 - Running the file toys.rkt or cubelets.rkt should run the solution to each question.
 - You may organize your files in any way that is coherent. You will need to defend your organization at codewalk. However, we    recommend an organization like the following:
 - A file named something like interfaces.rkt that contains your interfaces, constants, and other data that is needed by multiple classes.
 - A file for each class, incuding the unit tests for that class.
 - A top-level file, named toys.rkt or cubelets.rkt, that requires the other files and provides the deliverable functions and classes listed with each question.