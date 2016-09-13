;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-beginner-reader.ss" "lang")((modname screensaver-3) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f () #f)))
(require rackunit)
(require "extras.rkt")

(require 2htdp/image)
(require 2htdp/universe)

(check-location "04" "screensaver-3.rkt")

(provide screensaver
         rect-x
         rect-y
         rect-vx
         rect-vy
         rect-selected?
         rect-mx
         rect-my
         rect-ox
         rect-oy
         world-rects
         world-paused?
         initial-world
         new-rectangle
         new-coord
         new-vel
         place-rect
         update-rect
         new-rects
         world-after-tick
         world-after-key-event
         keys-update-rects
         rect-after-key-event
         update-velocity-x
         update-velocity-y
         position-x
         position-y
         string-velocity
         rect-with-text
         world-to-scene
         in-rect?
         place-rect
         rect-after-mouse-down
         rect-after-mouse-up
         rect-after-drag
         mouse-update-rects
         display-world
         rect-after-mouse-event
         world-after-mouse-event)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; SCREENSAVER FUNCTION

;;; screensaver : PosReal -> WorldState
;;; GIVEN: the speed of the simulation, in seconds/tick
;;; EFFECT: runs the simulation, starting with the initial state as
;;;         specified in the problem set.
;;; RETURNS: the final state of the world
;;; DESIGN STRATEGY: use templete for big bang
(define (screensaver speed)
  (big-bang (initial-world 35)
            (on-tick world-after-tick speed)
            (on-key world-after-key-event)
            (on-draw world-to-scene)
            (on-mouse world-after-mouse-event)
            ))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; CONSTANTS

;;; dimension of the canvas
(define CANVAS-WIDTH 400)
(define CANVAS-HEIGHT 300)

;;; empty canvas
(define EMPTY-CANVAS (empty-scene CANVAS-WIDTH CANVAS-HEIGHT))

;;; dimension of the rectangle
(define RECTANGLE-WIDTH 60)
(define RECTANGLE-HEIGHT 50)
(define RECTANGLE-WIDTH-HALF 30)
(define RECTANGLE-HEIGHT-HALF 25)

;;; image of circle
(define CIRCLE (circle 5 "outline" "red"))

;;; velocity of rectange
(define RECT-VEL-UNSEL (text "(0,0)" 11 "blue"))
(define RECT-VEL-SEL (text "(0,0)" 11 "red"))

;;; image of rectangle
(define RECT-IMAGE-UNSEL (rectangle RECTANGLE-WIDTH RECTANGLE-HEIGHT "outline" "blue"))
(define RECT-IMAGE-SEL (rectangle RECTANGLE-WIDTH RECTANGLE-HEIGHT "outline" "red"))
(define RECT-WITH-VEL-UNSEL (overlay/align "center" "center" RECT-IMAGE-UNSEL RECT-VEL-UNSEL))
(define RECT-WITH-VEL-SEL (overlay/align "center" "center" RECT-IMAGE-SEL RECT-VEL-SEL))

;;; boundary coordinates
(define RECT-BOUNDARY-X-MAX (- CANVAS-WIDTH RECTANGLE-WIDTH-HALF))
(define RECT-BOUNDARY-Y-MAX (- CANVAS-HEIGHT RECTANGLE-HEIGHT-HALF))
(define RECT-BOUNDARY-X-MIN (+ 0 RECTANGLE-WIDTH-HALF))
(define RECT-BOUNDARY-Y-MIN (+ 0 RECTANGLE-HEIGHT-HALF))

;;; initial speed of rectangle
(define INIT-RECT-SPEED-X 0)
(define INIT-RECT-SPEED-Y 0)

;;; coordinates of rectangle
(define INIT-RECT-X 200)
(define INIT-RECT-Y 150)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; DATA DEFINATIONS

(define-struct rect (x y vx vy selected? mx my ox oy))
;;; a rect is a (make-rect NonNegInt NonNegInt Integer Integer Boolean
;;;                        NonNegInt NonNegInt Integer Integer)
;;; Interpretation:
;;; x is the x-coordinates of the center of rectangle
;;; y is the y-coordinates of the center of rectangle 
;;; vx is the speed with which rectangle is moving on x-axis
;;;    (+ve -> moves to right & -ve -> moves to left)
;;; vy is the speed with which rectangle is moving on y-axis
;;;    (+ve -> moves to bottom & -ve -> moves to top)
;;; selected? true of rectangle is selected else false
;;; mx is the x-coordinates of the mouse on rectangle
;;; my is the y-coordinates of the mouse on rectangle
;;; ox is the x-offset of the mouse from center of rectangle
;;; oy is the y-offset of the mouse from center of rectangle
;;;
;;; templete:
;;; rect-fn : rect -> ??
#|
(define (rect-fn r)
  (...
   (rect-x r)
   (rect-y r)
   (rect-vx r)
   (rect-vy r)
   (rect-selected? r)
   (rect-mx r)
   (rect-my r)
   (rect-ox r)
   (rect-oy r)))
|#
;;; examples of rect, for testing
(define INIT-RECT (make-rect INIT-RECT-X INIT-RECT-Y INIT-RECT-SPEED-X
                             INIT-RECT-SPEED-Y false 0 0 0 0))
(define SEL-RECT (make-rect INIT-RECT-X INIT-RECT-Y INIT-RECT-SPEED-X
                            INIT-RECT-SPEED-Y true 0 0 0 0))
(define SEL-RECT1 (make-rect INIT-RECT-X INIT-RECT-Y INIT-RECT-SPEED-X
                             INIT-RECT-SPEED-Y true 190 140 0 0))
(define RECT-AFTER-UP (make-rect INIT-RECT-X INIT-RECT-Y INIT-RECT-SPEED-X
                                 (- INIT-RECT-SPEED-Y 2) #true 0 0 0 0))
(define RECT-AFTER-DOWN (make-rect INIT-RECT-X INIT-RECT-Y INIT-RECT-SPEED-X
                                   (+ INIT-RECT-SPEED-Y 2) #true 0 0 0 0))
(define RECT-AFTER-LEFT (make-rect INIT-RECT-X INIT-RECT-Y (- INIT-RECT-SPEED-X 2)
                                   INIT-RECT-SPEED-Y #true 0 0 0 0))
(define RECT-AFTER-RIGHT (make-rect INIT-RECT-X INIT-RECT-Y (+ INIT-RECT-SPEED-X 2)
                                    INIT-RECT-SPEED-Y #true 0 0 0 0))

;;; A ListofRectangle (LOR) is one of:
;;; -- empty
;;; -- (cons Rectangle LOR)
;;; list-fn : ListOfX -> ??
#|(define (list-fn lst)
  (cond
    [(empty? lst) ...]
    [else
     (...
      (first lst)
      (list-fn (rest lst)))]))
|#

(define-struct world (rects paused?))
;;; a WorldState is a (make-world ListOfRectangle Boolean)
;;; Interpretation:
;;; rects represents ListOfRectangle in scene
;;; paused? states wether the world is paused or not
;;;
;;; templete:
;;; world-fn : WorldState -> ??
#|
(define (world-fn w)
  (...
   (world-rects w)
   (world-paused? w)))
|#
;;; examples of World, for testing
(define unpaused-world (make-world empty false))
(define paused-world (make-world empty true))
(define unpaused-world-with-rect (make-world (cons INIT-RECT '()) #false))
(define unpaused-world-with-sel-rect (make-world (cons SEL-RECT '()) #false))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; initial-world : Any -> WorldState
;;; GIVEN: any value (ignored)
;;; RETURNS: the initial world specified in the problem set
;;; EXAMPLES: (initial-world 0) = (make-world (list INIT-RECT1 INIT-RECT2) #true)
;;; DESIGN STRATEGY: combine simpler function
(define (initial-world num)
  (make-world empty true))

;;;
;;;TESTS:
(begin-for-test
  (check-equal? (initial-world 0)
                (make-world empty #true)
                "make a default world and ignore the number"))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; helper functions to world-after-tick function

;;; new-rectangle : NonNegInt NonNegInt Int Int -> Rectangle
;;; GIVEN: 2 non-negative integers x and y, and 2 integers vx and vy
;;; RETURNS: a rectangle centered at (x,y), which will travel with
;;;          velocity (vx, vy).
;;; EXAMPLE: (new-rectangle 30 40 -10 30) = (make-rect 30 40 -10 30 #false 0 0 0 0)
;;;          (new-rectangle 60 50 -12 30) = (make-rect 60 50 -12 30 #false 0 0 0 0)
;;; DESIGN STRATEGY: combine simpler function
(define (new-rectangle x y vx vy)
  (make-rect x y vx vy false 0 0 0 0))

;;; TESTS:
(begin-for-test
  (check-equal? (new-rectangle 30 40 -10 30)
                (make-rect 30 40 -10 30 false 0 0 0 0)
                "create rectangle at specified position")
  (check-equal? (new-rectangle 60 50 -12 30)
                (make-rect 60 50 -12 30 false 0 0 0 0)
                "create rectangle at specified position"))

;;; new-coord : NonNegInt Integer -> Integer
;;; GIVEN: x/y coordinate of rectangle, x/y component of velocity
;;; RETURNS: a value of x/y which is always within the scene
;;; EXAMPLES: (new-coord 200 20) = 220
;;;           (new-coord 350 -10) = 340
;;;           (new-coord 470 24) = 370
;;;           (new-coord 40 -30) = 30
;;;           (new-coord 150 10) = 160
;;;           (new-coord 250 -15) = 235
;;;           (new-coord 260 25) = 275
;;;           (new-coord 30 -30) = 25
;;; DESIGN STRATEGY: dividing into cases based on wall rectangle can hit
(define (new-coord cur-coord cur-vel min max)
  (cond
    [(>= (+ cur-coord cur-vel) max) max]
    [(<= (+ cur-coord cur-vel) min) min]
    [else (+ cur-coord cur-vel)]))

;;;
;;; TESTS:
(begin-for-test
  (check-equal? (new-coord 200 20 RECT-BOUNDARY-X-MIN RECT-BOUNDARY-X-MAX) 220
                "returns new value based on boundaries")
  (check-equal? (new-coord 350 -10 RECT-BOUNDARY-X-MIN RECT-BOUNDARY-X-MAX) 340
                "returns new value based on boundaries")
  (check-equal? (new-coord 470 24 RECT-BOUNDARY-X-MIN RECT-BOUNDARY-X-MAX) 370
                "crosses the max limits so 370 is returned")
  (check-equal? (new-coord 40 -30 RECT-BOUNDARY-X-MIN RECT-BOUNDARY-X-MAX) 30
                "crosses the min limits so 30 is returned")
  (check-equal? (new-coord 150 10 RECT-BOUNDARY-Y-MIN RECT-BOUNDARY-Y-MAX) 160
                "returns new value based on boundaries")
  (check-equal? (new-coord 250 -15 RECT-BOUNDARY-Y-MIN RECT-BOUNDARY-Y-MAX) 235
                "returns new value based on boundaries")
  (check-equal? (new-coord 260 25 RECT-BOUNDARY-Y-MIN RECT-BOUNDARY-Y-MAX) 275
                "crosses the max limits so 275 is returned")
  (check-equal? (new-coord 30 -30 RECT-BOUNDARY-Y-MIN RECT-BOUNDARY-Y-MAX) 25
                "crosses the min limits so 25 is returned"))

;;; new-vel : NonNegInt Integer -> Boolean
;;; GIVEN: x/y coordinate of rectangle, x/y component of velocity
;;; RETURNS: true is rectangle is touching borders of scene, else false
;;; EXAMPLES: (new-vel 200 20) = 20
;;;           (new-vel 350 -10) = -10
;;;           (new-vel 470 24) = -24
;;;           (new-vel 40 -30) = 30
;;;           (new-vel 150 10) = 10
;;;           (new-vel 250 -15) = -15
;;;           (new-vel 260 25) = -25
;;;           (new-vel 30 -30) = 30
;;; DESIGN STRATEGY: dividing into cases based on wall rectangle can hit
(define (new-vel cur-coord cur-vel min max)
  (cond
    [(>= (+ cur-coord cur-vel) max) (- 0 cur-vel)]
    [(<= (+ cur-coord cur-vel) min) (- 0 cur-vel)]
    [else cur-vel]))

;;;
;;; TEST:
(begin-for-test
  (check-equal? (new-vel 200 20 RECT-BOUNDARY-X-MIN RECT-BOUNDARY-X-MAX)
                20 "doesn't hit any wall")
  (check-equal? (new-vel 350 -10 RECT-BOUNDARY-X-MIN RECT-BOUNDARY-X-MAX)
                -10 "doesn't hit any wall")
  (check-equal? (new-vel 470 24 RECT-BOUNDARY-X-MIN RECT-BOUNDARY-X-MAX)
                -24 "hits right wall")
  (check-equal? (new-vel 40 -30 RECT-BOUNDARY-X-MIN RECT-BOUNDARY-X-MAX)
                30 "hits left wall")
  (check-equal? (new-vel 150 10 RECT-BOUNDARY-Y-MIN RECT-BOUNDARY-Y-MAX)
                10 "doesn't hit any wall")
  (check-equal? (new-vel 250 -15 RECT-BOUNDARY-Y-MIN RECT-BOUNDARY-Y-MAX)
                -15 "doesn't hit any wall")
  (check-equal? (new-vel 260 25 RECT-BOUNDARY-Y-MIN RECT-BOUNDARY-Y-MAX)
                -25 "hits bottom wall")
  (check-equal? (new-vel 30 -30 RECT-BOUNDARY-Y-MIN RECT-BOUNDARY-Y-MAX)
                30 "hits top wall"))

;;; update-rect : Rectangle -> Rectangle
;;; GIVEN: an instance of Rectangle structure which needs to be updated
;;; RETURNS: an updated instance Rectangle structure
;;; EXAMPLE: (update-rect (new-rectangle 30 40 -10 30)) =
;;;          (make-rect 30 70 10 30 #false 0 0 0 0)
;;;          (update-rect (new-rectangle 150 200 -10 30)) =
;;;          (make-rect 140 230 -10 30 #false 0 0 0 0)
;;;          (update-rect (new-rectangle 360 40 30 -10)) =
;;;          (make-rect 370 30 -30 -10 #false 0 0 0 0)
;;;          (update-rect (new-rectangle 30 40 10 -30)) =
;;;          (make-rect 40 25 10 30 #false 0 0 0 0)
;;;          (update-rect (new-rectangle 150 70 -10 30)) =
;;;          (make-rect 140 100 -10 30 #false 0 0 0 0)
;;;          (update-rect (new-rectangle 30 270 -10 30)) =
;;;          (make-rect 30 275 10 -30 #false 0 0 0 0)
;;;          (update-rect (new-rectangle 42 255 -12 20)) =
;;;          (make-rect 30 70 10 30 #false 0 0 0 0)
;;; DESIGN STRATEGY: use templete for Rectangle on r
(define (update-rect r)
  (if (rect-selected? r)
      r
      (new-rectangle (new-coord (rect-x r) (rect-vx r)
                                RECT-BOUNDARY-X-MIN RECT-BOUNDARY-X-MAX)
                     (new-coord (rect-y r) (rect-vy r)
                                RECT-BOUNDARY-Y-MIN RECT-BOUNDARY-Y-MAX)
                     (new-vel (rect-x r) (rect-vx r)
                              RECT-BOUNDARY-X-MIN RECT-BOUNDARY-X-MAX)
                     (new-vel (rect-y r) (rect-vy r)
                              RECT-BOUNDARY-Y-MIN RECT-BOUNDARY-Y-MAX))))

;;;
;;; TEST:
(begin-for-test
  (check-equal? (update-rect SEL-RECT)
                (make-rect 200 150 0 0 #true 0 0 0 0)
                "when selected, rectangle doesn't move")
  (check-equal? (update-rect (new-rectangle 30 40 -10 30))
                (make-rect 30 70 10 30 false 0 0 0 0)
                "rectangle would bounce when it hits the left boundary")
  (check-equal? (update-rect (new-rectangle 150 200 -10 30))
                (make-rect 140 230 -10 30 false 0 0 0 0)
                "rectangle would move normally inside the scene")
  (check-equal? (update-rect (new-rectangle 360 40 30 -10))
                (make-rect 370 30 -30 -10 false 0 0 0 0)
                "rectangle would bounce when hits the right boundary")
  (check-equal? (update-rect (new-rectangle 30 40 10 -30))
                (make-rect 40 25 10 30 false 0 0 0 0)
                "rectangle bounces when hits the top boundary")
  (check-equal? (update-rect (new-rectangle 150 70 -10 30))
                (make-rect 140 100 -10 30 false 0 0 0 0)
                "rectangle moves noramlly inside the scene")
  (check-equal? (update-rect (new-rectangle 30 270 -10 30))
                (make-rect 30 275 10 -30 false 0 0 0 0)
                "rectangle bounces when hits the bottom boundary")
  (check-equal? (update-rect (new-rectangle 42 255 -12 20))
                (make-rect 30 275 12 -20 false 0 0 0 0)
                "rectangle reverses the motion when hits the corner perfectly"))

;;; new-rects: ListOfRectangle -> ListOfRectangle
;;; GIVEN: a ListOfRectangle which are to be updated on tick
;;; RETURNS: an updated ListOfRectangle
;;; EXAMPLES: (new-rects (list SEL-RECT)) = (cons SEL-RECT '())
(define (new-rects lor)
  (cond
    [(empty? lor) empty]
    [else
     (cons (update-rect (first lor)) (new-rects (rest lor)))]))

;;;
;;; TESTS:
(begin-for-test
  (check-equal? (new-rects (list SEL-RECT))
                (cons SEL-RECT '())
                "returns the list of updated recatangles"))

;;; world-after-tick : WorldState -> WorldState
;;; GIVENS: an instance of World structure 
;;; RETURNS: the world state that should follow the given world state
;;;          after a tick.
;;; EXMAPLES: (world-after-tick (initial-world 0)) = (make-world empty #true)
;;; DESIGN STRATEGY: use templete for World on w
(define (world-after-tick w)
  (if (world-paused? w) 
      w
      (make-world (new-rects (world-rects w)) false)))

;;;
;;; TEST:
(begin-for-test
  (check-equal? (world-after-tick (initial-world 0)) 
                (make-world empty #true)
                "initial world in scene (paused)")
  (check-equal? (world-after-tick (make-world empty #false)) 
                (make-world empty #false)
                "world with rectangles at new position in scene (unpaused)"))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; world-after-key-event : World KeyEvent -> World
;;; GIVEN: an instance of WorldState and a KeyEvent
;;; WHERE: KeyEvent is the " " -> Space Bar
;;; RETURNS: the WorldState that should follow the given Worldstate
;;;          after the given keyevent.
;;; EXAMPLES: (world-after-key-event (initial-world 0) " ") =
;;;                                (make-world INIT-RECT1 INIT-RECT2 #false)
;;; DESIGN STRATEGY: divide into case based on KeyEvent
(define (world-after-key-event w kev)
  (cond
    [(key=? kev " ")
     (if (world-paused? w)
         (make-world (world-rects w) false)
         (make-world (world-rects w) true))]
    [(key=? kev "n")
     (make-world (cons INIT-RECT (world-rects w)) (world-paused? w))]
    [else
     (make-world (keys-update-rects (world-rects w) kev) (world-paused? w))]))

;;;
;;; TEST:
(begin-for-test
  (check-equal? (world-after-key-event unpaused-world " ")
                (make-world '() #true)
                "toggled pause from false to true")
  (check-equal? (world-after-key-event paused-world " ")
                (make-world '() #false)
                "toggled pause from true to false")
  (check-equal? (world-after-key-event unpaused-world "n")
                (make-world (cons INIT-RECT '()) #false)
                "added a new rectangle")
  (check-equal? (world-after-key-event unpaused-world-with-rect "up")
                (make-world (cons INIT-RECT '()) #false)
                "passes to helper functions"))

;;; keys-update-rects: ListOfRect KeyEvent -> ListOfRect
;;; GIVEN: a list of rectanges and key-event
;;; RETURNS: an updated ListOfRectangle
;;; EXAMPLE: (keys-update-rects (list INIT-RECT) "up") = (cons INIT-RECT '())
(define (keys-update-rects lor kev)
  (cond
    [(empty? lor) empty]
    [else
     (if (rect-selected? (first lor))
         (cons (rect-after-key-event (first lor) kev)
               (keys-update-rects (rest lor) kev))
         (cons (first lor) (keys-update-rects (rest lor) kev)))]))

;;;
;;; TESTS:
(begin-for-test
  (check-equal? (keys-update-rects (list INIT-RECT) "up")
                (cons INIT-RECT '())
                "no change as the rectangle is not selected")
  (check-equal? (keys-update-rects (list SEL-RECT) "up")
                (cons (make-rect 200 150 0 -2 #true 0 0 0 0) '())
                "change in velocity of the rectangle which is selected"))

;;; rect-after-key-event: Rectangle KeyEvent -> Rectangle
;;; GIVEN: a Rectangle and a KeyEvent
;;; RETURNS: a Rectangle which follows the KeyEvent
;;; EXAMPLE: (keys-update-rects (list SEL-RECT) "up") =
;;;          (cons RECT-AFTER-UP '())
;;;          (keys-update-rects (list SEL-RECT) "down") =
;;;          (cons RECT-AFTER-DOWN '())
;;; DESIGN STRATEGY: divide case based on KeyEvent
(define (rect-after-key-event r kev)
  (cond
    [(key=? kev "up")
     (update-velocity-y r -2)]
    [(key=? kev "down")
     (update-velocity-y r +2)]
    [(key=? kev "left")
     (update-velocity-x r -2)]
    [(key=? kev "right")
     (update-velocity-x r +2)]
    [else r]))

;;;
;;; TESTS:
(begin-for-test
  (check-equal? (rect-after-key-event SEL-RECT "up")
                RECT-AFTER-UP
                "increases velocity by 2 in up direction")
  (check-equal? (rect-after-key-event SEL-RECT "down")
                RECT-AFTER-DOWN
                "increases velocity by 2 in down direction")
  (check-equal? (rect-after-key-event SEL-RECT "left")
                RECT-AFTER-LEFT
                "increases velocity by 2 in left direction")
  (check-equal? (rect-after-key-event SEL-RECT "right")
                RECT-AFTER-RIGHT
                "increases velocity by 2 in right direction")
  (check-equal? (rect-after-key-event SEL-RECT "i")
                SEL-RECT
                "no effect on rectangle"))

;;; update-velocity-x: Rectangle Integer -> Rectangle
;;; update-velocity-y: Rectangle Integer -> Rectangle
;;; GIVEN: a Rectangle and an Integer by which the velocity is to be updated
;;; RETURNS: a Rectangle with updated velocity
;;; EXAMPLES: (update-velocity-x SEL-RECT +2) = RECT-AFTER-RIGHT
;;;           (update-velocity-y SEL-RECT -2) = RECT-AFTER-UP
;;; DESIGN STRATEGY: combine simpler functions
(define (update-velocity-x r vel)
  (make-rect (rect-x r) (rect-y r) (+ vel (rect-vx r)) (rect-vy r) (rect-selected? r)
             (rect-mx r) (rect-my r) (rect-ox r) (rect-oy r)))

(define (update-velocity-y r vel)
  (make-rect (rect-x r) (rect-y r) (rect-vx r) (+ vel (rect-vy r)) (rect-selected? r)
             (rect-mx r) (rect-my r) (rect-ox r) (rect-oy r)))

;;;
;;; TESTs:
(begin-for-test
  (check-equal? (update-velocity-x SEL-RECT +2)
                RECT-AFTER-RIGHT
                "update the x-velocity by +2")
  (check-equal? (update-velocity-y SEL-RECT -2)
                RECT-AFTER-UP
                "update the y-velocity by -2"))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; Mouse Events

;;; in-rect? : Rectangle NonNegInt NonNegInt -> Boolean
;;; GIVEN: an instance of the rectangle class and x-y coordinates of mouse
;;; RETURNS: true if mouse is over rectangle else false
;;; EXAMPLES: (in-rect? RECT-IMAGE-UNSEL 220 150) = true
;;;           (in-rect? RECT-IMAGE-UNSEL 220 50) = false
;;; DESIGN STRATEGY: combine simpler function
(define (in-rect? r mx my)
  (and
   (<= 
    (- (rect-x r) RECTANGLE-WIDTH-HALF)
    mx
    (+ (rect-x r) RECTANGLE-WIDTH-HALF))
   (<= 
    (- (rect-y r) RECTANGLE-HEIGHT-HALF)
    my
    (+ (rect-y r) RECTANGLE-HEIGHT-HALF))))

;;;
;;; TESTS:
(begin-for-test
  (check-equal? (in-rect? SEL-RECT 220 150) true
                "returns true for cursor on rectangle")
  (check-equal? (in-rect? SEL-RECT 220 50) false
                "returns false for cursor outside rectangle"))

;;; rect-after-mouse-up : Rectangle NonNegInt NonNegInt -> Rectangle
;;; GIVEN: Rectangle and coordinates of mouse
;;; RETURN: a Rectangle which is not selected and has no effect of mouse
;;; EXAMPLES: (rect-after-mouse-up SEL-RECT1 220 150) = INIT-RECT
;;; DESIGN STARTEGY: use templete for Rectangle on r
(define (rect-after-mouse-up r mx my)
  (make-rect (rect-x r) (rect-y r) (rect-vx r) (rect-vy r) false 0 0 0 0))

;;;
;;; TESTS:
(begin-for-test
  (check-equal? (rect-after-mouse-up SEL-RECT 220 110)
                INIT-RECT
                "the rectangle is unselected"))

;;; rect-after-drag : Rectangle NonNegInt NonNegInt -> Rectangle
;;; GIVEN: Rectangle and coordinates of mouse
;;; RETURNS: Rectangle which follows mouse
;;; EXAMPLE: (rect-after-drag SEL-RECT1 220 150) =
;;;          (make-rect 220 150 0 0 #true 220 150 0 0)
;;;          (rect-after-drag INIT-RECT 220 50) =
;;;          (make-rect 200 150 0 0 #false 0 0 0 0)
;;; DESIGN STARTEGY: use templete for Rectangle on r
(define (rect-after-drag r mx my)
  (if (rect-selected? r)
      (make-rect (+ (rect-ox r) mx) (+ (rect-oy r) my) (rect-vx r) (rect-vy r)
                 true mx my (rect-ox r) (rect-oy r))
      r))

;;;
;;; TEST:
(begin-for-test
  (check-equal? (rect-after-drag SEL-RECT 220 150)
                (make-rect 220 150 0 0 #true 220 150 0 0)
                "if its on rectangle, it changes the object")
  (check-equal? (rect-after-drag INIT-RECT 220 50)
                (make-rect 200 150 0 0 #false 0 0 0 0)
                "if its not on rectangle, it return the same object"))

;;; rect-after-mouse-down : Rectangle NonNegInt NonNegInt -> Rectangle
;;; GIVEN: an instance of Rectangle and coordinates of mouse
;;; RETURNS: Rectangle which reacts to mouse-down event
;;; EXAMPLES: (rect-after-mouse-down SEL-RECT 220 150) = 
;;;           (make-rect 200 150 0 0 #true 220 150 -20 0)
;;;           (rect-after-mouse-down SEL-RECT 220 50) =
;;;           (make-rect 200 150 0 0 #true 0 0 0 0)
;;; DESIGN STRATEGY: use templete for Rectangle on r
(define (rect-after-mouse-down r mx my)
  (if (in-rect? r mx my)
      (make-rect (rect-x r) (rect-y r) (rect-vx r) (rect-vy r) true mx my
                 (- (rect-x r) mx) (- (rect-y r) my))
      r))

;;;
;;; TEST:
(begin-for-test
  (check-equal? (rect-after-mouse-down SEL-RECT 220 150) 
                (make-rect 200 150 0 0 #true 220 150 -20 0)
                "mouse down selects the rectangle if it is over it")
  (check-equal? (rect-after-mouse-down SEL-RECT 220 50) 
                (make-rect 200 150 0 0 #true 0 0 0 0)
                "mouse doesn't do anything if it is not over rectangle"))

;;; rect-after-mouse-event : Rectangle NonNegInt NonNegInt MouseEvent -> Rectangle
;;; GIVEN: Rectangle, coordinates of mouse and MouseEvent
;;; RETURNS: a Rectangle based on the MouseEvent
;;; EXAMPLES: (rect-after-mouse-event SEL-RECT 220 150 "button-down") =
;;;           (make-rect 200 150 0 0 #true 220 150 -20 0)
;;;           (rect-after-mouse-event SEL-RECT 220 50 "drag") =
;;;           (make-rect 200 150 0 0 #true 0 0 0 0)
;;; DESIGN STRATEGY: divide into cases based on MouseEvent
(define (rect-after-mouse-event r mx my mev)
  (cond
    [(mouse=? mev "button-down") (rect-after-mouse-down r mx my)]
    [(mouse=? mev "drag") (rect-after-drag r mx my)]
    [(mouse=? mev "button-up") (rect-after-mouse-up r mx my)]
    [else r]))

;;;
;;; TESTS:
(begin-for-test
  (check-equal? (rect-after-mouse-event SEL-RECT 220 150 "button-down")
                (make-rect 200 150 0 0 #true 220 150 -20 0)
                "selects the rectangle")
  (check-equal? (rect-after-mouse-event SEL-RECT 220 50 "drag")
                (make-rect 220 50 0 0 #true 220 50 0 0)
                "no effect as mouse is outside the rectangle")
  (check-equal? (rect-after-mouse-event SEL-RECT 220 150 "button-up")
                (make-rect 200 150 0 0 #false 0 0 0 0)
                "deselects the rectangle")
  (check-equal? (rect-after-mouse-event SEL-RECT 220 150 "enter")
                (make-rect 200 150 0 0 #true 0 0 0 0)
                "returns same object, no defination for 'enter' event"))

;;; mouse-update-rects: ListOfRect Integer Integer MouseEvent -> ListOfRect
;;; GIVEN: a ListOfRectangle in scene, mouse co-ordinated and MouseEvent
;;; RETURNS: a ListOfRectangle which reflects the changes due to MouseEvent
;;; EXAMPLE: (mouse-update-rects (list INIT-RECT) 220 150 "button-down") =
;;;          (cons SEL-RECT '()))
;;; DESIGN STRATEGY: use templete for ListOfRect on lor
(define (mouse-update-rects lor mx my mev)
  (cond
    [(empty? lor) empty]
    [else
     (cons (rect-after-mouse-event (first lor) mx my mev)
           (mouse-update-rects (rest lor) mx my mev))]))

;;;
;;; TESTS:
(begin-for-test
  (check-equal? (mouse-update-rects (list INIT-RECT) 220 150 "button-down")
                (cons (make-rect 200 150 0 0 #t 220 150 -20 0) '())
                "responds to the mouse event by traversing through list"))

;;; world-after-mouse-event : WorldState NonNegInt NonNegInt MouseEvent -> WorldState
;;; GIVEN: worldstate coordinates of mouse and mouseevent
;;; RETURNS: a worldstate which follows the given mouseevent
;;; EXAMPLES: (world-after-mouse-event unpaused-world-with-rect 200 140 "button-down") =
;;;           (make-world (cons (make-rect 200 150 0 0 #true 200 140 0 10) '()) #false)
;;; DESIGN STRATEGY: use templete for WorldState on w
(define (world-after-mouse-event w mx my mev)
  (make-world (mouse-update-rects (world-rects w) mx my mev)
              (world-paused? w)))

;;;
;;; TESTS:
(begin-for-test
  (check-equal? (world-after-mouse-event unpaused-world-with-rect 200 140 "button-down")
                (make-world (cons (make-rect 200 150 0 0 #true 200 140 0 10) '()) #false)
                "responds to the mouse event"))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; helper function for world-to-scene

;;; position-x : Rectangle -> NonNegInt
;;; position-y : Rectangle -> NonNegInt
;;; GIVEN: an instance on Rectangle structure
;;; RETURNS: x/y coordinate of the given rectangle
;;; EXAMPLES: (position-x INIT-RECT) = 200
;;;           (position-y INIT-RECT) = 150
;;; DESIGN STRATEGY: use templete for Rectangle on r
(define (position-x r)
  (rect-x r))

(define (position-y r)
  (rect-y r))

;;;
;;; TESTS:
(begin-for-test
  (check-equal? (position-x INIT-RECT) 200)
  (check-equal? (position-y INIT-RECT) 150))

;;; string-velocity : Integer Integer -> String
;;; GIVEN: x and y velocities of a rectangle
;;; RETURNS: the string representation of this velocities
;;; EXAMPLES: (string-velocity 5 7) = "(5,7)"
;;;           (string-velocity 13 -17) = "(13,-17)"
;;; DESIGN STRATEGY: combine simpler function
(define (string-velocity a b)
  (string-append "(" (number->string a) "," (number->string b) ")"))

;;; TESTS:
(begin-for-test
  (check-equal? (string-velocity 5 7) "(5,7)" "5 & 7 converted to string")
  (check-equal? (string-velocity 13 -17) "(13,-17)" "13 & -17 converted to string"))

;;; rect-with-text : Rectangle -> Image
;;; GIVEN: an instance of Rectangle structure
;;; RETURN: an image which has the velocities inside rectangle
;;; EXAMPLE: (rect-with-text INIT-RECT) = RECT-WITH-VEL-UNSEL
;;;          (rect-with-text SEL-RECT) = RECT-WITH-VEL-SEL
;;; DESIGN STRATEGY: use templete for Rectangle on r
(define (rect-with-text r)
  (if (rect-selected? r)
      (overlay/align "center" "center" RECT-IMAGE-SEL
                     (text (string-velocity (rect-vx r) (rect-vy r)) 11 "red"))
      (overlay/align "center" "center" RECT-IMAGE-UNSEL
                     (text (string-velocity (rect-vx r) (rect-vy r)) 11 "blue"))))

;;;
;;; TESTS:
(begin-for-test
  (check-equal? (rect-with-text INIT-RECT)
                RECT-WITH-VEL-UNSEL
                "image with velocity on it (unselected)")
  (check-equal? (rect-with-text SEL-RECT)
                RECT-WITH-VEL-SEL
                "image with velocity on it (selected)"))

;;; place-rect : Rectangle Image -> Image
;;; GIVEN: an instance of Rectangle structure and an Image
;;; RETURNS: an Image which is formed by merging rectangle to given image
;;; EXAMPLE: (place-rect INIT-RECT EMPTY-CANVAS) = returns INIT-RECT placed
;;;          over EMPTY-CANVAS
;;; DESIGN STARTEGY: combine simpler functions
(define (place-rect r c)
  (if (rect-selected? r)
      (place-image CIRCLE (rect-mx r) (rect-my r) 
                   (place-image (rect-with-text r) (position-x r) (position-y r) c))
      (place-image (rect-with-text r) (position-x r) (position-y r) c)))

(define RECT-SEL-WITH-CIRCLE (place-image CIRCLE 190 140 
                                          (place-image RECT-WITH-VEL-SEL 200 150
                                                       EMPTY-CANVAS)))
(define RECT-UNSEL-WITH-CIRCLE (place-image RECT-WITH-VEL-UNSEL
                                            200 150 EMPTY-CANVAS))

;;; display-world: ListOfRect -> Image
;;; GIVEN: a ListOfRectangle which are to be rendered
;;; RETURNS: a image consisting of all the items to be rendered
;;; EXAMPLES: (display-world (list INIT-RECT SEL-RECT)) = image with both
;;;           rectangles on it
;;; DESGIN STRATEGY: use templete for ListOfRectangle on lor
(define (display-world lor)
  (cond
    [(empty? lor) EMPTY-CANVAS]
    [else
     (place-rect (first lor) (display-world (rest lor)))]))

;;; world-to-scene : World -> Scene
;;; GIVEN: an instance of WorldState
;;; RETURNS: a Scene that portrays the given world.
;;; EXAMPLE: (world-to-scene unpaused-world) = INIT-CANVAS
;;; STRATEGY: Use template for World on w
(define (world-to-scene w)
  (display-world (world-rects w)))

;;; TEST:
(begin-for-test
  (check-equal? (world-to-scene (make-world (list INIT-RECT) false))
                RECT-UNSEL-WITH-CIRCLE
                "a scene which represents information of WorldState")
  (check-equal? (world-to-scene (make-world (list SEL-RECT1) false))
                RECT-SEL-WITH-CIRCLE
                "a scene which represents information of WorldState"))

;;; (screensaver 0.5)