;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-intermediate-lambda-reader.ss" "lang")((modname screensaver-5) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f () #f)))
;;; This program runs a screensaver 
(require rackunit)
(require "extras.rkt")

(check-location "05" "screensaver-4.rkt")

(require 2htdp/image)
(require 2htdp/universe)

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
         rect-pen-down?
         dot-x 
         dot-y 
         world-rects
         world-dots
         world-paused?
         initial-world
         new-rectangle
         new-coord
         new-vel
         update-rect
         new-rects
         add-dot
         update-dots
         world-after-tick
         world-after-key-event
         keys-update-rects
         set-dots
         rect-after-key-event
         update-velocity-x
         update-velocity-y
         in-rect?
         rect-after-mouse-up
         rect-after-drag
         rect-after-mouse-down
         rect-after-mouse-event
         mouse-update-rects
         world-after-mouse-event
         position-x
         position-y
         string-velocity
         rect-with-text
         place-rect
         place-dots
         display-world
         world-to-scene)
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

;;; color
(define SEL-COLOR "red")
(define UNSEL-COLOR "blue")
(define DOT-COLOR "black")

;;; empty canvas
(define EMPTY-CANVAS (empty-scene CANVAS-WIDTH CANVAS-HEIGHT))

;;; dimension of the rectangle
(define RECTANGLE-WIDTH 60)
(define RECTANGLE-HEIGHT 50)
(define RECTANGLE-WIDTH-HALF 30)
(define RECTANGLE-HEIGHT-HALF 25)

;;; image of circle
(define CIRCLE (circle 5 "outline" SEL-COLOR))
(define DOT-IMAGE (circle 1 "solid" DOT-COLOR))

;;; velocity of rectange
(define RECT-VEL-UNSEL (text "(0,0)" 11 UNSEL-COLOR))
(define RECT-VEL-SEL (text "(0,0)" 11 SEL-COLOR))

;;; image of rectangle
(define RECT-IMAGE-UNSEL (rectangle RECTANGLE-WIDTH RECTANGLE-HEIGHT "outline" UNSEL-COLOR))
(define RECT-IMAGE-SEL (rectangle RECTANGLE-WIDTH RECTANGLE-HEIGHT "outline" SEL-COLOR))
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

(define-struct rect (x y vx vy selected? mx my ox oy pen-down?))
;;; a Rectangle is a (make-rect NonNegInt NonNegInt Integer Integer Boolean
;;;                             NonNegInt NonNegInt Integer Integer Boolean)
;;; Interpretation:
;;; x is x-coordinate of the center of rectangle
;;; y is y-coordinate of the center of rectangle 
;;; vx is the speed with which rectangle is moving on x-axis
;;;    (+ve -> moves to right & -ve -> moves to left)
;;; vy is the speed with which rectangle is moving on y-axis
;;;    (+ve -> moves to bottom & -ve -> moves to top)
;;; selected? true of rectangle is selected else false
;;; mx is the x-coordinates of the mouse on rectangle
;;; my is the y-coordinates of the mouse on rectangle
;;; ox is the x-offset of the mouse from center of rectangle
;;; oy is the y-offset of the mouse from center of rectangle
;;; pen-down? true if the dots are getting printed else false
;;;
;;; templete:
;;; rect-fn: Rectangle -> ??
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
   (rect-oy r)
   (rect-pen-down? r)))
|#
;;; examples of rect, for testing
(define INIT-RECT (make-rect INIT-RECT-X INIT-RECT-Y INIT-RECT-SPEED-X
                             INIT-RECT-SPEED-Y false 0 0 0 0 false))
(define SEL-RECT (make-rect INIT-RECT-X INIT-RECT-Y INIT-RECT-SPEED-X
                            INIT-RECT-SPEED-Y true 0 0 0 0 false))
(define SEL-RECT1 (make-rect INIT-RECT-X INIT-RECT-Y INIT-RECT-SPEED-X
                             INIT-RECT-SPEED-Y true 190 140 0 0 false))
(define RECT-AFTER-UP (make-rect INIT-RECT-X INIT-RECT-Y INIT-RECT-SPEED-X
                                 (- INIT-RECT-SPEED-Y 2) #true 0 0 0 0 false))
(define RECT-AFTER-DOWN (make-rect INIT-RECT-X INIT-RECT-Y INIT-RECT-SPEED-X
                                   (+ INIT-RECT-SPEED-Y 2) #true 0 0 0 0 false))
(define RECT-AFTER-LEFT (make-rect INIT-RECT-X INIT-RECT-Y (- INIT-RECT-SPEED-X 2)
                                   INIT-RECT-SPEED-Y #true 0 0 0 0 false))
(define RECT-AFTER-RIGHT (make-rect INIT-RECT-X INIT-RECT-Y (+ INIT-RECT-SPEED-X 2)
                                    INIT-RECT-SPEED-Y #true 0 0 0 0 false))
(define RECT-PEN-DOWN (make-rect INIT-RECT-X INIT-RECT-Y (+ INIT-RECT-SPEED-X 2)
                                 INIT-RECT-SPEED-Y #false 0 0 0 0 true))

(define-struct dot (x y))
;;; a dot is (make-dot NonNegInt NonNegint)
;;; Interpretation:
;;; x is the x coordinate of dot
;;; y is the y coordinate of dot
;;;
;;; templelte:
;;; dot-fn: Dot -> ??
#|
(define (dot-fn d)
  (...
   (dot-x d)
   (dot-y d)))
|#
;;; examples of dot, for testing
(define DOT0 (make-dot 200 150))
(define DOT1 (make-dot 200 152))
(define DOT2 (make-dot 200 148))
(define DOT3 (make-dot 202 150))
(define DOT4 (make-dot 198 150))

;;; A ListOfRectangle (LOR) is one of:
;;; -- empty
;;; -- (cons Rectangle LOR)
;;; list-fn : ListOfX -> ??
#|
(define (list-fn lst)
  (cond
    [(empty? lst) ...]
    [else
     (...
      (first lst)
      (list-fn (rest lst)))]))
|#

;;; A ListofDot (LOD) is one of:
;;; -- empty
;;; -- (cons Dot LOD)
;;; list-fn : ListOfX -> ??
#|
(define (list-fn lst)
  (cond
    [(empty? lst) ...]
    [else
     (...
      (first lst)
      (list-fn (rest lst)))]))
|#

(define-struct world (rects dots paused?))
;;; a WorldState is a (make-world rect dot Boolean)
;;; Interpretation:
;;; rects represents ListOfRectangle in scene
;;; dots represents ListOfDot in scene
;;; paused? states wether the world is paused or not
;;;
;;; templete:
;;; world-fn : WorldState -> ??
#|
(define (world-fn w)
  (...
   (world-rects w)
   (world-dots w)
   (world-paused? w)))
|#
;;; examples of WorldState, for testing
(define unpaused-world (make-world empty empty false))
(define paused-world (make-world empty empty true))
(define unpaused-world-with-rect (make-world (cons INIT-RECT '()) empty #false))
(define unpaused-world-with-sel-rect (make-world (cons SEL-RECT '()) empty #false))

(define CANVAS-WITH-DOTS (place-image DOT-IMAGE 200 150
                                      (place-image DOT-IMAGE 200 152 EMPTY-CANVAS)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; initial-world : Any -> WorldState
;;; GIVEN: any value (ignored)
;;; RETURNS: the initial world specified in the problem set
;;; EXAMPLES: (initial-world 0) = (make-world (list INIT-RECT1 INIT-RECT2) #true)
;;; DESIGN STRATEGY: combine simpler function
(define (initial-world num)
  (make-world empty empty true))

;;;
;;;TESTS:
(begin-for-test
  (check-equal? (initial-world 0)
                (make-world empty empty #true)
                "make a default world and ignore the number"))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; helper functions to world-after-tick function

;;; new-rectangle : NonNegInt NonNegInt Int Int -> Rectangle
;;; GIVEN: 2 non-negative integers x and y, and 2 integers vx and vy
;;; RETURNS: a Rectangle centered at (x,y), which will travel with
;;;          velocity (vx, vy).
;;; EXAMPLE: (new-rectangle 30 40 -10 30) = (make-rect 30 40 -10 30 #false 0 0 0 0)
;;;          (new-rectangle 60 50 -12 30) = (make-rect 60 50 -12 30 #false 0 0 0 0)
;;; DESIGN STRATEGY: combine simpler function
(define (new-rectangle x y vx vy)
  (make-rect x y vx vy false 0 0 0 0 false))

;;; TESTS:
(begin-for-test
  (check-equal? (new-rectangle 30 40 -10 30)
                (make-rect 30 40 -10 30 false 0 0 0 0 false)
                "create rectangle at specified position")
  (check-equal? (new-rectangle 60 50 -12 30)
                (make-rect 60 50 -12 30 false 0 0 0 0 false)
                "create rectangle at specified position"))

;;; new-coord : NonNegInt Integer NonNegInt NonNegInt -> Integer
;;; GIVEN: x/y coordinate of rectangle, x/y component of velocity & boundary extremes
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

;;; new-vel : NonNegInt Integer NonNegInt NonNegInt -> Boolean
;;; GIVEN: x/y coordinate of rectangle, x/y component of velocity & boundary extremes
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
      (make-rect (new-coord (rect-x r) (rect-vx r)
                            RECT-BOUNDARY-X-MIN RECT-BOUNDARY-X-MAX)
                 (new-coord (rect-y r) (rect-vy r)
                            RECT-BOUNDARY-Y-MIN RECT-BOUNDARY-Y-MAX)
                 (new-vel (rect-x r) (rect-vx r)
                          RECT-BOUNDARY-X-MIN RECT-BOUNDARY-X-MAX)
                 (new-vel (rect-y r) (rect-vy r)
                          RECT-BOUNDARY-Y-MIN RECT-BOUNDARY-Y-MAX)
                 false 0 0 0 0 (rect-pen-down? r))))

;;;
;;; TEST:
(begin-for-test
  (check-equal? (update-rect SEL-RECT)
                (make-rect 200 150 0 0 #true 0 0 0 0 #false)
                "when selected, rectangle doesn't move")
  (check-equal? (update-rect (new-rectangle 30 40 -10 30))
                (make-rect 30 70 10 30 #false 0 0 0 0 #false)
                "rectangle would bounce when it hits the left boundary")
  (check-equal? (update-rect (new-rectangle 150 200 -10 30))
                (make-rect 140 230 -10 30 #false 0 0 0 0 #false)
                "rectangle would move normally inside the scene")
  (check-equal? (update-rect (new-rectangle 360 40 30 -10))
                (make-rect 370 30 -30 -10 false 0 0 0 0 #false)
                "rectangle would bounce when hits the right boundary")
  (check-equal? (update-rect (new-rectangle 30 40 10 -30))
                (make-rect 40 25 10 30 false 0 0 0 0 #false)
                "rectangle bounces when hits the top boundary")
  (check-equal? (update-rect (new-rectangle 150 70 -10 30))
                (make-rect 140 100 -10 30 false 0 0 0 0 #false)
                "rectangle moves noramlly inside the scene")
  (check-equal? (update-rect (new-rectangle 30 270 -10 30))
                (make-rect 30 275 10 -30 false 0 0 0 0 #false)
                "rectangle bounces when hits the bottom boundary")
  (check-equal? (update-rect (new-rectangle 42 255 -12 20))
                (make-rect 30 275 12 -20 false 0 0 0 0 #false)
                "rectangle reverses the motion when hits the corner perfectly"))

;;; new-rects: ListOfRectangle -> ListOfRectangle
;;; GIVEN: a ListOfRectangle which are to be updated on tick
;;; RETURNS: an updated ListOfRectangle
;;; EXAMPLES: (new-rects (list SEL-RECT)) = (cons SEL-RECT '())
;;; DESIGN STRATEGY: use HOF map on lor
(define (new-rects lor)
  (map update-rect lor))

;;;
;;; TESTS:
(begin-for-test
  (check-equal? (new-rects (list SEL-RECT))
                (cons SEL-RECT '())
                "returns the list of updated recatangles"))

;;; add-dot: Rectangle ListOfDot -> ListOfDot
;;; GIVEN: an instance of Rectangle and a list of Dot
;;; RETURNS: a ListOfDot with all new dots added
;;; EXAMPLES: (add-dot RECT-PEN-DOWN (list DOT1 DOT2)) = (list DOT0 DOT1 DOT2)
;;; DESIGN STRATEGY: use templete for Rectangle on r
(define (add-dot r lod)
  (if (and (rect-pen-down? r) (not (rect-selected? r)))
      (cons (make-dot (rect-x r) (rect-y r)) lod)
      lod))

;;;
;;; TESTS:
(begin-for-test
  (check-equal? (add-dot RECT-PEN-DOWN (list DOT1 DOT2))
                (list DOT0 DOT1 DOT2)
                "adds dot to the ListOfDot")
  (check-equal? (add-dot INIT-RECT (list DOT1 DOT2))
                (list DOT1 DOT2)
                "no dots added as pen is not down"))

;;; update-dots: ListOfRectangle ListOfDot -> ListOfDot
;;; GIVEN: a ListOfRectangle and dots
;;; RETURNS: an updated ListOfDot
;;; EXAMPLES: (update-dots (list RECT-PEN-DOWN) (list DOT0 DOT1))
;;;           = (list DOT0 DOT0 DOT1)
;;; DESIGN STRATEGY: use HOF foldr on lor and lod
(define (update-dots lor lod)
  (foldr add-dot lod lor))

;;;
;;; TESTS:
(begin-for-test
  (check-equal? (update-dots (list RECT-PEN-DOWN) (list DOT0 DOT1))
                (list DOT0 DOT0 DOT1)
                "dot added at the desired position"))

;;; world-after-tick : WorldState -> WorldState
;;; GIVENS: an instance of World structure 
;;; RETURNS: the world state that should follow the given world state
;;;          after a tick.
;;; EXMAPLES: (world-after-tick (initial-world 0)) = (make-world empty #true)
;;; DESIGN STRATEGY: use templete for World on w
(define (world-after-tick w)
  (if (world-paused? w) 
      w
      (make-world (new-rects (world-rects w))
                  (update-dots (world-rects w) (world-dots w))
                  false)))

;;;
;;; TEST:
(begin-for-test
  (check-equal? (world-after-tick paused-world) 
                (make-world empty empty #true)
                "initial world in scene (paused)")
  (check-equal? (world-after-tick unpaused-world) 
                (make-world empty empty #false)
                "world with rectangles at new position in scene (unpaused)"))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; world-after-key-event : WorldState KeyEvent -> WorldState
;;; GIVEN: an instance of WorldState and a KeyEvent
;;; RETURNS: a WorldState that would follow the given WorldState
;;;          after the given keyevent.
;;; EXAMPLES: (world-after-key-event (initial-world 0) " ") =
;;;                                (make-world INIT-RECT1 INIT-RECT2 #false)
;;; DESIGN STRATEGY: divide into cases based on KeyEvent
(define (world-after-key-event w kev)
  (cond
    [(key=? kev " ")
     (if (world-paused? w)
         (make-world (world-rects w) (world-dots w) false)
         (make-world (world-rects w) (world-dots w) true))]
    [(key=? kev "n")
     (make-world (cons INIT-RECT (world-rects w)) (world-dots w) (world-paused? w))]
    [else
     (make-world (keys-update-rects (world-rects w) kev) (world-dots w) (world-paused? w))]))

;;;
;;; TEST:
(begin-for-test
  (check-equal? (world-after-key-event unpaused-world " ")
                (make-world '() '() #true)
                "toggled pause from false to true")
  (check-equal? (world-after-key-event paused-world " ")
                (make-world '() '() #false)
                "toggled pause from true to false")
  (check-equal? (world-after-key-event unpaused-world "n")
                (make-world (cons INIT-RECT '()) '() #false)
                "added a new rectangle")
  (check-equal? (world-after-key-event unpaused-world-with-rect "up")
                (make-world (cons INIT-RECT '()) '() #false)
                "passes to helper functions"))

;;; keys-update-rects: ListOfRectangle KeyEvent -> ListOfRectangle
;;; GIVEN: a list of rectanges and key-event
;;; RETURNS: an updated ListOfRectangle
;;; EXAMPLE: (keys-update-rects (list INIT-RECT) "up") = (cons INIT-RECT '())
;;; DESIGN STRATEGY: ue HOF map on lor
(define (keys-update-rects lor kev)
  (map
   ;;; Rectangle -> Rectangle
   (lambda (x) (if (rect-selected? x) (rect-after-key-event x kev) x))
   lor))

;;;
;;; TESTS:
(begin-for-test
  (check-equal? (keys-update-rects (list INIT-RECT) "up")
                (cons INIT-RECT '())
                "no change as the rectangle is not selected")
  (check-equal? (keys-update-rects (list SEL-RECT) "up")
                (cons (make-rect 200 150 0 -2 #true 0 0 0 0 false) '())
                "change in velocity of the rectangle which is selected"))

;;; set-dots: Rectangle Boolean -> Rectangle
;;; GIVEN: a Rectangle and a value for pen-down? field in Rectangle
;;; RETURNS: a Rectangle that has its value updated
;;; EXAMPLE: (set-dots INIT-RECT true) = (make-rect 200 150 0 0 #false 0 0 0 0 #true)
;;;          (set-dots INIT-RECT false) = (make-rect 200 150 0 0 #false 0 0 0 0 #false)
;;; DESIGN STRATEGY: use templete of Rectangle on r
(define (set-dots r val)
  (make-rect (rect-x r) (rect-y r) (rect-vx r) (rect-vy r) (rect-selected? r)
             (rect-mx r) (rect-my r) (rect-ox r) (rect-oy r) val))

;;;
;;; TESTS:
(begin-for-test
  (check-equal? (set-dots INIT-RECT true)
                (make-rect 200 150 0 0 #false 0 0 0 0 #true)
                "sets pen-down? to true")
  (check-equal? (set-dots INIT-RECT false)
                (make-rect 200 150 0 0 #false 0 0 0 0 #false)
                "sets pen-down? to false"))

;;; rect-after-key-event: Rectangle KeyEvent -> Rectangle
;;; GIVEN: a Rectangle and a KeyEvent
;;; RETURNS: a Rectangle which follows the KeyEvent
;;; EXAMPLE: (keys-update-rects (list SEL-RECT) "up") = (cons RECT-AFTER-UP '())
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
    [(key=? kev "d")
     (set-dots r true)]
    [(key=? kev "u")
     (set-dots r false)]
    [else r]))

;;;
;;; TESTS:
(begin-for-test
  (check-equal? (keys-update-rects (list SEL-RECT) "up")
                (cons RECT-AFTER-UP '())
                "increases velocity by 2 in up direction")
  (check-equal? (keys-update-rects (list SEL-RECT) "down")
                (cons RECT-AFTER-DOWN '())
                "increases velocity by 2 in down direction")
  (check-equal? (keys-update-rects (list SEL-RECT) "left")
                (cons RECT-AFTER-LEFT '())
                "increases velocity by 2 in left direction")
  (check-equal? (keys-update-rects (list SEL-RECT) "right")
                (cons RECT-AFTER-RIGHT '())
                "increases velocity by 2 in right direction")
  (check-equal? (keys-update-rects (list SEL-RECT) "d")
                (cons (make-rect 200 150 0 0 #true 0 0 0 0 #true) '())
                "enables pen")
  (check-equal? (keys-update-rects (list SEL-RECT) "u")
                (cons SEL-RECT '())
                "disables pen")
  (check-equal? (keys-update-rects (list SEL-RECT) "i")
                (cons SEL-RECT '())
                "no effect on rectangle"))

;;; update-velocity-x: Rectangle Integer -> Rectangle
;;; update-velocity-y: Rectangle Integer -> Rectangle
;;; GIVEN: a Rectangle and an Integer by which the velocity is to be updated
;;; RETURNS: a Rectangle with updated velocity
;;; EXAMPLES: (update-velocity-x SEL-RECT +2) = RECT-AFTER-RIGHT
;;;           (update-velocity-y SEL-RECT -2) = RECT-AFTER-UP
;;; DESIGN STRATEGY: use templete for Rectangle on r
(define (update-velocity-x r vel)
  (make-rect (rect-x r) (rect-y r) (+ vel (rect-vx r)) (rect-vy r) (rect-selected? r)
             (rect-mx r) (rect-my r) (rect-ox r) (rect-oy r) (rect-pen-down? r)))

(define (update-velocity-y r vel)
  (make-rect (rect-x r) (rect-y r) (rect-vx r) (+ vel (rect-vy r)) (rect-selected? r)
             (rect-mx r) (rect-my r) (rect-ox r) (rect-oy r) (rect-pen-down? r)))

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
;;; DESIGN STRATEGY: use templete for Rectangle on r
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
;;; RETURN: a Rectangle which is not selected
;;; EXAMPLES: (rect-after-mouse-up SEL-RECT1 220 150) = INIT-RECT
;;; DESIGN STRATEGY: use templete for Rectangle on r
(define (rect-after-mouse-up r mx my)
  (make-rect (rect-x r) (rect-y r) (rect-vx r) (rect-vy r) false 0 0 0 0
             (rect-pen-down? r)))

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
;;;          (rect-after-drag SEL-RECT1 220 50) =
;;;          (make-rect 200 150 0 0 #true 0 0 0 0)
;;; DESIGN STRATEGY: use templete for Rectangle on r
(define (rect-after-drag r mx my)
  (if (rect-selected? r)
      (make-rect (+ (rect-ox r) mx) (+ (rect-oy r) my) (rect-vx r) (rect-vy r)
                 true mx my (rect-ox r) (rect-oy r) (rect-pen-down? r))
      r))

;;;
;;; TEST:
(begin-for-test
  (check-equal? (rect-after-drag SEL-RECT 220 150)
                (make-rect 220 150 0 0 #true 220 150 0 0 #false)
                "if its on rectangle, it changes the object")
  (check-equal? (rect-after-drag INIT-RECT 220 50)
                (make-rect 200 150 0 0 #false 0 0 0 0 #false)
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
                 (- (rect-x r) mx) (- (rect-y r) my) (rect-pen-down? r))
      r))

;;;
;;; TEST:
(begin-for-test
  (check-equal? (rect-after-mouse-down SEL-RECT 220 150) 
                (make-rect 200 150 0 0 #true 220 150 -20 0 false)
                "mouse down selects the rectangle if it is over it")
  (check-equal? (rect-after-mouse-down SEL-RECT 220 50) 
                (make-rect 200 150 0 0 #true 0 0 0 0 false)
                "mouse doesn't do anything if it is not over rectangle"))

;;; rect-after-mouse-event : Rectangle NonNegInt NonNegInt MouseEvent -> Rectangle
;;; GIVEN: Rectangle, coordinates of mouse and MouseEvent
;;; RETURNS: a Rectangle based on the keyevent
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
                (make-rect 200 150 0 0 #true 220 150 -20 0 false)
                "selects the rectangle")
  (check-equal? (rect-after-mouse-event SEL-RECT 220 50 "drag")
                (make-rect 220 50 0 0 true 220 50 0 0 false)
                "no effect as mouse is outside the rectangle")
  (check-equal? (rect-after-mouse-event SEL-RECT 220 150 "button-up")
                (make-rect 200 150 0 0 #false 0 0 0 0 false)
                "deselects the rectangle")
  (check-equal? (rect-after-mouse-event SEL-RECT 220 150 "enter")
                (make-rect 200 150 0 0 #true 0 0 0 0 false)
                "returns same object, no defination for 'enter' event"))

;;; mouse-update-rects: ListOfRectangle Integer Integer MouseEvent -> ListOfRectangle
;;; GIVEN: a ListOfRectangle in scene, mouse co-ordinated and MouseEvent
;;; RETURNS: a ListOfRectangle which reflects the changes due to MouseEvent
;;; EXAMPLE: (mouse-update-rects (list INIT-RECT) 220 150 "button-down") =
;;;          (cons SEL-RECT '()))
;;; DESIGN STRATEGY: use HOF map on lor
(define (mouse-update-rects lor mx my mev)
  (map
   ;;; Rectangle -> Rectangle
   (lambda (x) (rect-after-mouse-event x mx my mev)) lor))

;;;
;;; TESTS:
(begin-for-test
  (check-equal? (mouse-update-rects (list INIT-RECT) 220 150 "button-down")
                (cons (make-rect 200 150 0 0 #t 220 150 -20 0 false) '())
                "responds to the mouse event by traversing through list"))

;;; world-after-mouse-event: WorldState NonNegInt NonNegInt MouseEvent -> WorldState
;;; GIVEN: worldstate, coordinates of mouse and mouseevent
;;; RETURNS: a worldstate which follows the given mouseevent
;;; EXAMPLES: (world-after-mouse-event unpaused-world-with-rect 200 140 "button-down") =
;;;           (make-world (cons (make-rect 200 150 0 0 #true 200 140 0 10) '()) #false)
;;; DESIGN STRATEGY: use templete for WorldState on w
(define (world-after-mouse-event w mx my mev)
  (make-world (mouse-update-rects (world-rects w) mx my mev)
              (world-dots w) (world-paused? w)))

;;;
;;; TESTS:
(begin-for-test
  (check-equal? (world-after-mouse-event unpaused-world-with-rect 200 140 "button-down")
                (make-world (cons (make-rect 200 150 0 0 #true 200 140 0 10 false)
                                  '()) '() #false)
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
                     (text (string-velocity (rect-vx r) (rect-vy r)) 11 SEL-COLOR))
      (overlay/align "center" "center" RECT-IMAGE-UNSEL
                     (text (string-velocity (rect-vx r) (rect-vy r)) 11 UNSEL-COLOR))))

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
;;; DESIGN STRATEGY: use templete for Rectangle on r
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

;;; place-dots: ListOfDot -> Image
;;; GIVEN: a ListOfDot which are to be displayed
;;; RETURNS: a Image which has all dots placed on the EMPTY-CANVAS
;;; EXAMPLE: (place-dots (list DOT0 DOT1)) = CANVAS-WITH-DOTS
;;; DESIGN STRATEGY: use HOF foldr on lod
(define (place-dots lod)
  (foldr
   ;; Dot Image -> Image
   (lambda (a b) (place-image DOT-IMAGE (dot-x a) (dot-y a) b))
   EMPTY-CANVAS
   lod))

;;;
;;; TESTS:
(begin-for-test
  (check-equal? (place-dots (list DOT0 DOT1))
                CANVAS-WITH-DOTS
                "a canvas with dots on it"))

;;; display-world: ListOfRectangle ListOfDot -> Image
;;; GIVEN: a ListOfRectangle & ListOfDot which are to be rendered
;;; RETURNS: a image consisting of all the items to be rendered
;;; EXAMPLES: (display-world (list INIT-RECT SEL-RECT)) = image with both
;;;           rectangles on it
;;; DESGIN STRATEGY: use HOF foldr on lor lod
(define (display-world lor lod)
  (foldr
   ;;; Rectangle Image -> Image
   (lambda (a b) (place-rect a b)) (place-dots lod) lor))

;;; world-to-scene : World -> Scene
;;; GIVEN: an instance of WorldState
;;; RETURNS: a Scene that portrays the given world.
;;; EXAMPLE: (world-to-scene unpaused-world) = INIT-CANVAS
;;; DESIGN STRATEGY: Use template for World on w
(define (world-to-scene w)
  (display-world (world-rects w) (world-dots w)))

;;; TEST:
(begin-for-test
  (check-equal? (world-to-scene (make-world (list INIT-RECT) empty false))
                RECT-UNSEL-WITH-CIRCLE
                "a scene which represents information of WorldState")
  (check-equal? (world-to-scene (make-world (list SEL-RECT1) empty false))
                RECT-SEL-WITH-CIRCLE
                "a scene which represents information of WorldState"))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
