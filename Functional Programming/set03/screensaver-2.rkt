;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-beginner-reader.ss" "lang")((modname screensaver-2) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f () #f)))
;;;screensaver-2.
;;;two boxes of same dimension are moving in the scene. when they touch
;;;the wall, the bounce back in scene. Also, They can be dragged to any position
;;;in the scene using mouse.

;;;start with (screensaver 0.5)

(require rackunit)
(require "extras.rkt")

(require 2htdp/image)
(require 2htdp/universe)

(check-location "03" "screensaver-2.rkt")

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
         world-rect1
         world-rect2
         world-paused?
         initial-world
         new-rectangle
         new-x
         new-y
         hits-x-wall?
         hits-y-wall?
         place-rect
         update-rect
         world-after-tick
         world-after-key-event
         position-x
         position-y
         string-velocity
         rect-with-text
         world-to-scene
         in-rect?
         rect-after-mouse-down
         rect-after-mouse-up
         rect-after-drag
         rect-after-mouse-event
         world-after-mouse-event)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; SCREENSAVER FUNCTION

;;; screensaver : PosReal -> world
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

;;; dimension of the rectangle
(define RECTANGLE-WIDTH 60)
(define RECTANGLE-HEIGHT 50)
(define RECTANGLE-WIDTH-HALF 30)
(define RECTANGLE-HEIGHT-HALF 25)


;;; coordinates of rectangle
(define INIT-RECTANGLE1-X 200)
(define INIT-RECTANGLE1-Y 100)
(define INIT-RECTANGLE2-X 200)
(define INIT-RECTANGLE2-Y 200)

;;; initial speed of rectangle
(define INIT-RECTANGLE1-SPEED-X -12)
(define INIT-RECTANGLE1-SPEED-Y 20)
(define INIT-RECTANGLE2-SPEED-X 23)
(define INIT-RECTANGLE2-SPEED-Y -14)

;;; boundary coordinates
(define RECT-BOUNDARY-X-MAX (- CANVAS-WIDTH RECTANGLE-WIDTH-HALF))
(define RECT-BOUNDARY-Y-MAX (- CANVAS-HEIGHT RECTANGLE-HEIGHT-HALF))
(define RECT-BOUNDARY-X-MIN (+ 0 RECTANGLE-WIDTH-HALF))
(define RECT-BOUNDARY-Y-MIN (+ 0 RECTANGLE-HEIGHT-HALF))

;;; empty canvas
(define EMPTY-CANVAS (empty-scene CANVAS-WIDTH CANVAS-HEIGHT))

;;; string images
(define RECT1-VEL (text "(-12,20)" 11 "blue"))
(define RECT1-VEL-SEL (text "(-12,20)" 11 "red"))
(define RECT2-VEL (text "(23,-14)" 11 "blue"))
(define RECT2-VEL-SEL (text "(23,-14)" 11 "red"))

;;; image of rectangle
(define RECT-IMAGE-UNSEL (rectangle RECTANGLE-WIDTH RECTANGLE-HEIGHT "outline" "blue"))
(define RECT-IMAGE-SEL (rectangle RECTANGLE-WIDTH RECTANGLE-HEIGHT "outline" "red"))
(define RECT1-WITH-VEL (overlay/align "center" "center" RECT-IMAGE-UNSEL RECT1-VEL))
(define RECT2-WITH-VEL (overlay/align "center" "center" RECT-IMAGE-UNSEL RECT2-VEL))
(define RECT2-WITH-VEL-SEL (overlay/align "center" "center" RECT-IMAGE-SEL RECT2-VEL-SEL))

;;; image of circle
(define CIRCLE (circle 5 "outline" "red"))

;;; canvas images
(define INIT-CANVAS (place-image RECT1-WITH-VEL 200 100
                                 (place-image RECT2-WITH-VEL 200 200 EMPTY-CANVAS)))


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
(define INIT-RECT1 (make-rect INIT-RECTANGLE1-X INIT-RECTANGLE1-Y
                              INIT-RECTANGLE1-SPEED-X INIT-RECTANGLE1-SPEED-Y
                              false 0 0 0 0))
(define INIT-RECT2 (make-rect INIT-RECTANGLE2-X INIT-RECTANGLE2-Y
                              INIT-RECTANGLE2-SPEED-X INIT-RECTANGLE2-SPEED-Y
                              false 0 0 0 0))
(define SEL-RECT1 (make-rect INIT-RECTANGLE1-X INIT-RECTANGLE1-Y
                             INIT-RECTANGLE1-SPEED-X INIT-RECTANGLE1-SPEED-Y
                             true 0 0 0 0))
(define SEL-RECT2 (make-rect INIT-RECTANGLE2-X INIT-RECTANGLE2-Y
                             INIT-RECTANGLE2-SPEED-X INIT-RECTANGLE2-SPEED-Y
                             true 180 220 0 0))

(define-struct world (rect1 rect2 paused?))
;;; a world is a (make-world rect rect Boolean)
;;; Interpretation:
;;; rect1 represents rect of the screensaver initially at
;;;            INIT-RECT1-X and INIT-RECT1-Y
;;; rect2 represents rect of the screensaver initially at
;;;            INIT-RECT2-X and INIT-RECT2-Y
;;; paused? states wether the world is paused or not
;;;
;;; templete:
;;; world-fn : world -> ??
#|
(define (world-fn w)
  (...
   (world-rect1 w)
   (world-rect2 w)
   (world-paused? w)))
|#
;;; examples of world, for testing
(define unpaused-world (make-world INIT-RECT1 INIT-RECT2 false))
(define unpaused-world-2 (make-world INIT-RECT1 SEL-RECT2 false))
(define paused-world (make-world INIT-RECT1 INIT-RECT2 true))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; initial-world : Any -> world
;;; GIVEN: any value (ignored)
;;; RETURNS: the initial world specified in the problem set
;;; EXAMPLES: (initial-world 0) = (make-world INIT-RECT1 INIT-RECT2 #true)
;;; DESIGN STRATEGY: combine simpler function
(define (initial-world num)
  (make-world INIT-RECT1 INIT-RECT2 true))

;;;
;;;TESTS:
(begin-for-test
  (check-equal? (initial-world 0)
                (make-world INIT-RECT1 INIT-RECT2 #true)
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

;;; new-x : NonNegInt Integer -> Integer
;;; new-y : NonNegInt Integer -> Integer
;;; GIVEN: x/y coordinate of rectangle, x/y component of velocity
;;; RETURNS: a value of x/y which is always within the scene
;;; EXAMPLES: (new-x 200 20) = 220
;;;           (new-x 350 -10) = 340
;;;           (new-x 470 24) = 370
;;;           (new-x 40 -30) = 30
;;;           (new-y 150 10) = 160
;;;           (new-y 250 -15) = 235
;;;           (new-y 260 25) = 275
;;;           (new-y 30 -30) = 25
;;; DESIGN STRATEGY: dividing into cases based on wall rectangle can hit
(define (new-x x vx)
  (cond
    [(>= (+ x vx) RECT-BOUNDARY-X-MAX) RECT-BOUNDARY-X-MAX]
    [(<= (+ x vx) RECT-BOUNDARY-X-MIN) RECT-BOUNDARY-X-MIN]
    [else (+ x vx)]))

(define (new-y y vy)
  (cond
    [(>= (+ y vy) RECT-BOUNDARY-Y-MAX) RECT-BOUNDARY-Y-MAX]
    [(<= (+ y vy) RECT-BOUNDARY-Y-MIN) RECT-BOUNDARY-Y-MIN]
    [else (+ y vy)]))

;;;
;;; TESTS:
(begin-for-test
  (check-equal? (new-x 200 20) 220 "returns new value based on boundaries")
  (check-equal? (new-x 350 -10) 340 "returns new value based on boundaries")
  (check-equal? (new-x 470 24) 370 "crosses the max limits so 370 is returned")
  (check-equal? (new-x 40 -30) 30 "crosses the min limits so 30 is returned")
  (check-equal? (new-y 150 10) 160 "returns new value based on boundaries")
  (check-equal? (new-y 250 -15) 235 "returns new value based on boundaries")
  (check-equal? (new-y 260 25) 275 "crosses the max limits so 275 is returned")
  (check-equal? (new-y 30 -30) 25 "crosses the min limits so 25 is returned"))

;;; hits-x-wall? : NonNegInt Integer -> Boolean
;;; hits-y-wall? : NonNegInt Integer -> Boolean
;;; GIVEN: x/y coordinate of rectangle, x/y component of velocity
;;; RETURNS: true is rectangle is touching borders of scene, else false
;;; EXAMPLES: (hits-x-wall? 200 20) = false
;;;           (hits-x-wall? 350 -10) = false
;;;           (hits-x-wall? 470 24) = true
;;;           (hits-x-wall? 40 -30) = true
;;;           (hits-y-wall? 150 10) = false
;;;           (hits-y-wall? 250 -15) = false
;;;           (hits-y-wall? 260 25) = true
;;;           (hits-y-wall? 30 -30) = true
;;; DESIGN STRATEGY: dividing into cases based on wall rectangle can hit
(define (hits-x-wall? x vx)
  (cond
    [(>= (+ x vx) RECT-BOUNDARY-X-MAX) true]
    [(<= (+ x vx) RECT-BOUNDARY-X-MIN) true]
    [else false]))

(define (hits-y-wall? y vy)
  (cond
    [(>= (+ y vy) RECT-BOUNDARY-Y-MAX) true]
    [(<= (+ y vy) RECT-BOUNDARY-Y-MIN) true]
    [else false]))

;;;
;;; TEST:
(begin-for-test
  (check-equal? (hits-x-wall? 200 20) false "doesn't hit any wall")
  (check-equal? (hits-x-wall? 350 -10) false "doesn't hit any wall")
  (check-equal? (hits-x-wall? 470 24) true "hits right wall")
  (check-equal? (hits-x-wall? 40 -30) true "hits left wall")
  (check-equal? (hits-y-wall? 150 10) false "doesn't hit any wall")
  (check-equal? (hits-y-wall? 250 -15) false "doesn't hit any wall")
  (check-equal? (hits-y-wall? 260 25) true "hits bottom wall")
  (check-equal? (hits-y-wall? 30 -30) true "hits top wall"))

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
      (new-rectangle (new-x (rect-x r) (rect-vx r))
                     (new-y (rect-y r) (rect-vy r))
                     (if (hits-x-wall? (rect-x r) (rect-vx r))
                         (- 0 (rect-vx r)) (rect-vx r))
                     (if (hits-y-wall? (rect-y r) (rect-vy r))
                         (- 0 (rect-vy r)) (rect-vy r)))
      ))

;;;
;;; TEST:
(begin-for-test
  (check-equal? (update-rect SEL-RECT1)
                (make-rect 200 100 -12 20 #t 0 0 0 0)
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
                "rectangle reverses the motion when hits the corner perfectly")
  )

;;; world-after-tick : world -> world
;;; GIVENS: an instance of world structure 
;;; RETURNS: the world state that should follow the given world state
;;;          after a tick.
;;; EXMAPLES: (world-after-tick (initial-world 0)) =
;;;                                (make-world INIT-RECT1 INIT-RECT2 #true)
;;; DESIGN STRATEGY: use templete for world on w
(define (world-after-tick w)
  (if (world-paused? w) 
      w
      (make-world (update-rect (world-rect1 w))
                       (update-rect (world-rect2 w)) false)))

;;;
;;; TEST:
(begin-for-test
  (check-equal? (world-after-tick (initial-world 0)) 
                (make-world INIT-RECT1 INIT-RECT2 #true)
                "initial world in scene (paused)")
  (check-equal? (world-after-tick (make-world INIT-RECT1 INIT-RECT2 #false)) 
                (make-world (new-rectangle 188 120 -12 20) (new-rectangle 223 186 23 -14) #false)
                "world with rectangles at new position in scene (unpaused)"))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; world-after-key-event : world KeyEvent -> world
;;; GIVEN: an instance of world and a KeyEvent
;;; WHERE: KeyEvent is the " " -> Space Bar
;;; RETURNS: the world that should follow the given world
;;;          after the given keyevent.
;;; EXAMPLES: (world-after-key-event (initial-world 0) " ") =
;;;                                (make-world INIT-RECT1 INIT-RECT2 #false)
;;; DESIGN STRATEGY: divide into case based on KeyEvent
(define (world-after-key-event w kev)
  (cond
    [(key=? kev " ")
     (if (world-paused? w)
         (make-world (world-rect1 w) (world-rect2 w) false)
         (make-world (world-rect1 w) (world-rect2 w) true))]
    [else w]))

;;;
;;; TEST:
(begin-for-test
  (check-equal? (world-after-key-event (initial-world 0) " ")
                (make-world INIT-RECT1 INIT-RECT2 #false)
                "toggles pause to false i.e. unpaused world")
  (check-equal? (world-after-key-event (make-world INIT-RECT1 INIT-RECT2 #false) " ") 
                (make-world INIT-RECT1 INIT-RECT2 #true)
                "toggles pause to true i.e. paused world")
  (check-equal? (world-after-key-event (initial-world 0) "w")
                (make-world INIT-RECT1 INIT-RECT2 #true)
                "invalid input, so no change"))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; helper function for world-to-scene

;;; position-x : Rectangle -> NonNegInt
;;; position-y : Rectangle -> NonNegInt
;;; GIVEN: an instance on Rectangle structure
;;; RETURNS: x/y coordinate of the given rectangle
;;; EXAMPLES: (position-x INIT-RECT1) = 200
;;;           (position-x INIT-RECT2) = 200
;;;           (position-y INIT-RECT1) = 100
;;;           (position-y INIT-RECT2) = 200
;;; DESIGN STRATEGY: use templete for Rectangle on r
(define (position-x r)
  (rect-x r))

(define (position-y r)
  (rect-y r))

;;;
;;; TEST:
(begin-for-test
  (check-equal? (position-x INIT-RECT1) 200)
  (check-equal? (position-x INIT-RECT2) 200)
  (check-equal? (position-y INIT-RECT1) 100)
  (check-equal? (position-y INIT-RECT2) 200)
  )

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
;;; EXAMPLE: (rect-with-text INIT-RECT1) = RECT1-WITH-VEL
;;;          (rect-with-text INIT-RECT2) = RECT1-WITH-VEL
;;; DESIGN STRATEGY: use templete for Rectangle on r
(define (rect-with-text r)
  (if (rect-selected? r)
      (overlay/align "center" "center" RECT-IMAGE-SEL
                     (text (string-velocity (rect-vx r) (rect-vy r)) 11 "red"))
      (overlay/align "center" "center" RECT-IMAGE-UNSEL
                     (text (string-velocity (rect-vx r) (rect-vy r)) 11 "blue"))))

;;; TEST:
(begin-for-test
  (check-equal? (rect-with-text INIT-RECT1) RECT1-WITH-VEL "rectangle with velocity")
  (check-equal? (rect-with-text INIT-RECT2) RECT2-WITH-VEL "rectangle with velocity")
  (check-equal? (rect-with-text SEL-RECT2) RECT2-WITH-VEL-SEL "rectangle with velocity"))

;;; place-rect : Rectangle Image -> Image
;;; GIVEN: an instance of Rectangle structure and an Image
;;; RETURNS: an Image which is formed by merging rectangle to given image
;;; EXAMPLE: (place-rect INIT-RECT1 EMPTY-CANVAS) = returns INIT-RECT1 placed
;;;          over EMPTY-CANVAS
;;; DESIGN STARTEGY: combine simpler functions
(define (place-rect r c)
  (if (rect-selected? r)
      (place-image CIRCLE (rect-mx r) (rect-my r) 
                   (place-image (rect-with-text r) (position-x r) (position-y r) c))
      (place-image (rect-with-text r) (position-x r) (position-y r) c)))

(define RECT-SEL-WITH-CIRCLE (place-image CIRCLE 180 220 
                                          (place-image RECT2-WITH-VEL-SEL 200 200
                                                       (place-image RECT1-WITH-VEL
                                                                    200 100 EMPTY-CANVAS))))
;;; world-to-scene : World -> Scene
;;; GIVEN: an instance of world
;;; RETURNS: a Scene that portrays the given world.
;;; EXAMPLE: (world-to-scene unpaused-world) = INIT-CANVAS
;;; STRATEGY: Use template for World on w
(define (world-to-scene w)
  (place-rect (world-rect2 w) (place-rect (world-rect1 w) EMPTY-CANVAS)))

;;; TEST:
(begin-for-test
  (check-equal? (world-to-scene unpaused-world)
                INIT-CANVAS
                "a scene which represents information of world")
  (check-equal? (world-to-scene unpaused-world-2)
                RECT-SEL-WITH-CIRCLE
                "a scene which represents information of world"))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; helper functions to world-after-mouse-event function

;;; in-rect? : Rectangle NonNegInt NonNegInt -> Boolean
;;; GIVEN: an instance of the rectangle class and x-y coordinates of mouse
;;; RETURNS: true if mouse is over rectangle else false
;;; EXAMPLES: (in-rect? RECT-IMAGE-UNSEL 220 110) = true
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
  (check-equal? (in-rect? SEL-RECT1 220 110) true
                "returns true for cursor on rectangle")
  (check-equal? (in-rect? SEL-RECT1 220 50) false
                "returns false for cursor outside rectangle"))

;;; rect-after-mouse-down : Rectangle NonNegInt NonNegInt -> Rectangle
;;; GIVEN: an instance of Rectangle and coordinates of mouse
;;; RETURNS: Rectangle which reacts to mouse-down event
;;; EXAMPLES: (rect-after-mouse-down SEL-RECT1 220 110) =
;;;           (make-rect 200 100 -12 20 #true 220 110 -20 -10)
;;;           (rect-after-mouse-down SEL-RECT1 220 50) =
;;;           (make-rect 200 100 -12 20 #true 0 0 0 0)
;;; DESIGN STRATEGY: use templete for Rectangle on r
(define (rect-after-mouse-down r mx my)
  (if (in-rect? r mx my)
      (make-rect (rect-x r) (rect-y r) (rect-vx r) (rect-vy r) true mx my
                 (- (rect-x r) mx) (- (rect-y r) my))
      r))

;;;
;;; TEST:
(begin-for-test
  (check-equal? (rect-after-mouse-down SEL-RECT1 220 110) 
                (make-rect 200 100 -12 20 #true 220 110 -20 -10)
                "mouse down selects the rectangle if it is over it")
  (check-equal? (rect-after-mouse-down SEL-RECT1 220 50) 
                (make-rect 200 100 -12 20 #true 0 0 0 0)
                "mouse doesn't do anything if it is not over rectangle"))

;;; rect-after-drag : Rectangle NonNegInt NonNegInt -> Rectangle
;;; GIVEN: Rectangle and coordinates of mouse
;;; RETURNS: Rectangle which follows mouse
;;; EXAMPLE: (rect-after-drag SEL-RECT1 220 110) =
;;;          (make-rect 220 110 -12 20 #true 220 110 0 0)
;;;          (rect-after-drag SEL-RECT1 220 50) =
;;;          (make-rect 200 100 -12 20 #true 0 0 0 0)
;;; DESIGN STARTEGY: use templete for Rectangle on r
(define (rect-after-drag r mx my)
  (if (rect-selected? r)
      (make-rect (+ (rect-ox r) mx) (+ (rect-oy r) my) (rect-vx r) (rect-vy r)
                 true mx my (rect-ox r) (rect-oy r))
      r))

;;;
;;; TEST:
(begin-for-test
  (check-equal? (rect-after-drag SEL-RECT1 220 110)
                (make-rect 220 110 -12 20 #t 220 110 0 0)
                "if its on rectangle, it changes the object")
  (check-equal? (rect-after-drag SEL-RECT1 220 50)
                (make-rect 220 50 -12 20 #t 220 50 0 0)
                "if its not on rectangle, it return the same object"))

;;; rect-after-mouse-up : Rectangle NonNegInt NonNegInt -> Rectangle
;;; GIVEN: Rectangle and coordinates of mouse
;;; RETURN: a Rectangle which is not selected and has no effect of mouse
;;; EXAMPLES: (rect-after-mouse-up SEL-RECT1 220 110) =
;;;           (make-rect 200 100 -12 20 #false 0 0 0 0)
;;;           (rect-after-mouse-up SEL-RECT1 220 50) =
;;;           (make-rect 200 100 -12 20 #true 0 0 0 0)
;;; DESIGN STARTEGY: use templete for Rectangle on r
(define (rect-after-mouse-up r mx my)
  (make-rect (rect-x r) (rect-y r) (rect-vx r) (rect-vy r) false 0 0 0 0))

;;;
;;; TESTS:
(begin-for-test
  (check-equal? (rect-after-mouse-up SEL-RECT1 220 110)
                (make-rect 200 100 -12 20 #false 0 0 0 0)
                "the rectangle is unselected")
  (check-equal? (rect-after-mouse-up SEL-RECT1 220 50)
                (make-rect 200 100 -12 20 #false 0 0 0 0)
                "the rectangle has no effect as mouse was outside rectangle"))

;;; rect-after-mouse-event : Rectangle NonNegInt NonNegInt KeyEvent -> Rectangle
;;; GIVEN: Rectangle, coordinates of mouse and keyevent
;;; RETURNS: a Rectangle based on the keyevent
;;; EXAMPLES: (rect-after-mouse-event SEL-RECT1 220 110 "button-down") =
;;;           (make-rect 200 100 -12 20 #true 220 110 -20 -10)
;;;           (rect-after-mouse-event SEL-RECT1 220 50 "button-down") =
;;;           (make-rect 200 100 -12 20 #true 0 0 0 0)
;;; DESIGN STRATEGY: divide into cases based on KeyEvent
(define (rect-after-mouse-event r mx my mev)
  (cond
    [(mouse=? mev "button-down") (rect-after-mouse-down r mx my)]
    [(mouse=? mev "drag") (rect-after-drag r mx my)]
    [(mouse=? mev "button-up") (rect-after-mouse-up r mx my)]
    [else r]))

;;;
;;; TEST:
(begin-for-test
  (check-equal? (rect-after-mouse-event SEL-RECT1 220 110 "button-down")
                (make-rect 200 100 -12 20 #true 220 110 -20 -10)
                "selects the rectangle")
  (check-equal? (rect-after-mouse-event SEL-RECT1 220 50 "drag")
                (make-rect 220 50 -12 20 #t 220 50 0 0)
                "no effect as mouse is outside the rectangle")
  (check-equal? (rect-after-mouse-event SEL-RECT1 220 110 "button-up")
                (make-rect 200 100 -12 20 #false 0 0 0 0)
                "deselects the rectangle")
  (check-equal? (rect-after-mouse-event SEL-RECT1 220 110 "enter")
                (make-rect 200 100 -12 20 #true 0 0 0 0)
                "returns same object, no defination for 'enter' event"))

;;; world-after-mouse-event : world NonNegInt NonNegInt MouseEvent -> world
;;; GIVEN: world coordinates of mouse and mouseevent
;;; RETURNS: a world which follows the given mouseevent
;;; EXAMPLES: (world-after-mouse-event paused-world 180 220 "button-down") =
;;;           (make-world INIT-RECT1 SEL-RECT2 #true)
;;; DESIGN STRATEGY: use templete for world on w
(define (world-after-mouse-event w mx my mev)
  (make-world (rect-after-mouse-event (world-rect1 w) mx my mev)
                   (rect-after-mouse-event (world-rect2 w) mx my mev)
                   (world-paused? w)))

;;;
;;;TESTS:
(begin-for-test
  (check-equal? (world-after-mouse-event paused-world 180 220 "button-up")
                (make-world INIT-RECT1 INIT-RECT2 #true)
                "returns a world with rect2 selected"))

;;;
;;; (screensaver 0.5)
(define RECTANGLE-NEAR-EDGE (new-rectangle 35 40 30 20))
	(define BUTTON-DOWN "button-down")
	(define BUTTON-UP "button-up")
	(define DRAG "drag")
	(define SELECTED-RECTANGLE-NEAR-EDGE
	  (rect-after-mouse-event RECTANGLE-NEAR-EDGE 32 32 BUTTON-DOWN))

