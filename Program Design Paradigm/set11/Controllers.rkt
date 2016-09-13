#lang racket
(require "Interfaces.rkt")
(require "BaseForControllers.rkt")
(require "Model.rkt")
(require "extras.rkt")
(require rackunit)
(require 2htdp/image)
(require 2htdp/universe)

(provide PositionController%
         VelocityController%
         XController%
         YController%
         XYController%)

;;; A PositionController is a (new PositionController% [m Model<%>]
;;;                                                    [center-x NonNegInt]
;;;                                                    [center-y NonNegInt])
;;;
;;; A PositionController represents a class which visually displays information
;;; regarding the particle. It also enables users to manipulate position of the
;;; particle.
(define PositionController%
  (class* TextualController% (Controller<%>)

    ;; inherited fields from the super-class
    (inherit-field center-x center-y model particle-x particle-y particle-vx
                   particle-vy selected?)
    
    (super-new)

    ;; register this controller with model
    (send model register this)

    ;; after-key-event : KeyEvent -> Void
    ;; GIVEN : a KeyEvent which ocurred in the world
    ;; EFFECT : it updates this object to a state which should follow after key event
    ;; DETAILS : position of the particle is changed using arrow keys
    ;; DESIGN STRATEGY : cases on wether this controller is selected or not
    (define/override (after-key-event kev) 
      (if selected?
          (cond
            [(key=? "up" kev)
             (send model execute-command
                   (make-set-position particle-x (- particle-y 5)))]
            [(key=? "down" kev)
             (send model execute-command
                   (make-set-position particle-x (+ particle-y 5)))]
            [(key=? "left" kev)
             (send model execute-command
                   (make-set-position (- particle-x 5) particle-y))]
            [(key=? "right" kev)
             (send model execute-command
                   (make-set-position (+ particle-x 5) particle-y))]
            [else this])
          this))

    ;; get-top-string : -> String
    ;; GIVEN : no arguments
    ;; RETURNS : a string which should displayed on the top of controller
    ;; DESIGN STRATEGY : return a String
    (define/override (get-top-string)
      "Arrow keys change Position")
    ))

;;; A VelocityController is a (new VelocityController% [m Model<%>]
;;;                                                    [center-x NonNegInt]
;;;                                                    [center-y NonNegInt])
;;;
;;; A VelocityController represents a class which visually displays information
;;; regarding the particle. It also enables users to manipulate velocity of the
;;; particle.
(define VelocityController%
  (class* TextualController% (Controller<%>)

    ;; inherited fields from the super-class
    (inherit-field model center-x center-y particle-x particle-y particle-vx
                   particle-vy selected?)
    
    (super-new)

    ;; register this controller with model
    (send model register this)

    ;; after-key-event : KeyEvent -> Void
    ;; GIVEN : a KeyEvent which ocurred in the world
    ;; EFFECT : it updates this object to a state which should follow after key event
    ;; DETAILS : velocity of the particle is changed using arrow keys
    ;; DESIGN STRATEGY : cases on wether this controller is selected or not
    (define/override (after-key-event kev) 
      (if selected?
          (cond
            [(key=? "up" kev)
             (send model execute-command
                   (make-incr-velocity 0 (- 0 5)))]
            [(key=? "down" kev)
             (send model execute-command
                   (make-incr-velocity 0 5))]
            [(key=? "left" kev)
             (send model execute-command
                   (make-incr-velocity (- 0 5) 0))]
            [(key=? "right" kev)
             (send model execute-command
                   (make-incr-velocity 5 0) )]
            [else this])
          this))

    ;; get-top-string : -> String
    ;; GIVEN : no arguments
    ;; RETURNS : a string which should displayed on the top of controller
    ;; DESIGN STRATEGY : return a String
    (define/override (get-top-string)
      "Arrow keys change Velocity")
    ))

;;; A XController is a (new XController% [m Model<%>]
;;;                                      [center-x NonNegInt]
;;;                                      [center-y NonNegInt])
;;;
;;; A XController represents a class which visually displays data related to the
;;; particle in graphical format. In particular, it displays the particle's
;;; position on x-axis.
(define XController%
  (class* GraphicalController% (Controller<%>)

    ;; fields needed from the super-class
    (inherit-field model center-x center-y off-mx off-my particle-x particle-y
                   selected? draggable? particle-vx particle-vy
                   handle-side handle-center-x handle-center-y half-handle-side
                   handle-off-mx handle-off-my box-width half-box-width dx-from-mouse)

    ;; dimensions of the field of interaction inside the controller
    (field [width 150])
    (field [height 40])

    ;; half of dimensions of the field of interaction inside the controller
    (field [half-width (/ width 2)])
    (field [half-height (/ height 2)])

    (super-new)

    ;; register this controller with model
    (send model register this)

    ;; set handle-center-x and handle-center-y to new values
    (set! handle-center-x (+ (- center-x half-box-width) half-handle-side))
    (set! handle-center-y (+ (- center-y half-height) half-handle-side))

    ;; get-controller-img : -> Image
    ;; GIVEN : no arguments
    ;; RETURNS : an image with this controller painted on it
    ;; DESIGN STRATEGY : combine simpler functions
    (define/override (get-controller-img)
      (overlay
       (get-inner-box)
       (get-outer-box)))

    ;; get-outer-box : -> Image
    ;; GIVEN : no arguments
    ;; RETURNS : an Image consisting of the outer box
    ;; DESIGN STRATEGY : combine simpler functions
    (define (get-outer-box)
      (overlay
       (rectangle width height "outline" "blue")
       (overlay/xy (get-handle-img) 0 0 (rectangle box-width 40 "outline" "black"))))

    ;; get-handle-img : -> Image
    ;; GIVEN : no arguments
    ;; RETURNS : an Image consisting of handle used to drag controller around
    ;; DESIGN STRATEGY : combine simpler function
    (define (get-handle-img)
      (rectangle handle-side handle-side "outline" (current-handle-color)))

    ;; get-inner-box : -> Image
    ;; GIVEN : no arguments
    ;; RETURNS : an Image consisting of the particle and inner box
    ;; DESIGN STRATEGY : combine simpler functions
    (define (get-inner-box)
      (place-image (get-particle-img)
                   particle-x
                   (/ height 2)
                   (rectangle width height "outline" "blue")))

    ;; get-particle-img : -> Image
    ;; GIVEN : no arguments
    ;; RETURNS : an Image of the particle
    ;; DESIGN STRATEGY : combine simpler functions
    (define (get-particle-img)
      (overlay
       (circle 3 "solid" "black")
       (circle 10 "solid" "red")))

    ;; current-handle-color : -> String
    ;; GIVEN : no arguments
    ;; RETURNS : String of the color handle should have
    ;; DESIGN STRATEGY : cases on wether the controller is draggable or not
    (define (current-handle-color)
      (if draggable? "red" "black"))

    ;; after-button-down : Integer Integer -> Void
    ;; GIVEN : x/y coordinates of the mouse
    ;; EFFECT : upadtes this object to a state which should follow after button down
    ;; DESIGN STRATEGY : cases based on position of the mouse
    (define/override (after-button-down mx my)
      (cond [(in-handle? mx my)
             (begin
               (set! draggable? true)
               (set! off-mx (- center-x mx))
               (set! off-my (- center-y my))
               (set! handle-off-mx (- handle-center-x mx))
               (set! handle-off-my (- handle-center-y my)))]
            [(in-controller? mx my)
             (begin
               (set! selected? true)
               (set! dx-from-mouse (- mx particle-x))
               (send model execute-command (make-set-paused true)))]
            [else this]))

    ;; after-drag : Integer Integer -> Void
    ;; GIVEN : x/y coordinates of the mouse
    ;; EFFECT : updates this object to a state which should follow after drag
    ;; DESIGN STRATEGY : cases on position of mouse
    (define/override (after-drag mx my)
      (cond
        [draggable?
         (begin
           (set! center-x (+ mx off-mx))
           (set! center-y (+ my off-my))
           (set! handle-center-x (+ mx handle-off-mx))
           (set! handle-center-y (+ my handle-off-my)))]
        [selected?
         (send model execute-command
               (make-set-position (- mx dx-from-mouse) particle-y))]))

    ;; in-handle? : Integer Integer -> Boolean
    ;; GIVEN : x/y coordinates of the mouse
    ;; RETURNS : true if the mouse is in handle else false
    ;; DESIGN STRATEGY : combine simpler functions
    (define (in-handle? mx my)
      (and (<= (- handle-center-x half-handle-side)
               mx
               (+ handle-center-x half-handle-side))
           (<= (- handle-center-y half-handle-side)
               my 
               (+ handle-center-y half-handle-side))))

    ;; in-controller? : Integer Integer -> Boolean
    ;; GIVEN : x/y coordinates of the mouse
    ;; RETURNS : true if the mouse is in controller else false
    ;; DESIGN STRATEGY : combine simpler functions
    (define (in-controller? mx my)
      (and (<= (- center-x half-width)
               mx
               (+ center-x half-width))
           (<= (- center-y half-height)
               my 
               (+ center-y half-height))))
    ))

;;; A YController is a (new YController% [m Model<%>]
;;;                                      [center-x NonNegInt]
;;;                                      [center-y NonNegInt])
;;;
;;; A YController represents a class which visually displays data related to the
;;; particle in graphical format. In particular, it displays the particle's
;;; position on y-axis.
(define YController%
  (class* GraphicalController% (Controller<%>)

    ;; fields needed from the super-class
    (inherit-field model center-x center-y draggable? off-mx off-my handle-off-mx
                   half-handle-side handle-center-x handle-center-y handle-side
                   handle-off-my selected? particle-x particle-y particle-vx
                   particle-vy box-height half-box-height dy-from-mouse)

    ;; dimensions of the field of interaction inside the controller
    (field [width 40])
    (field [height 100])

    ;; half of dimensions of the field of interaction inside the controller
    (field [half-width (/ width 2)])
    (field [half-height (/ height 2)])

    (super-new)

    ;; register this controller with model
    (send model register this)

    ;; set handle-center-x and handle-center-y to new values
    (set! handle-center-x (+ (- center-x half-width) half-handle-side))
    (set! handle-center-y (+ (- center-y half-box-height) half-handle-side))

    ;; get-controller-img : -> Image
    ;; GIVEN : no arguments
    ;; RETURNS : an image with this controller painted on it
    ;; DESIGN STRATEGY : combine simpler functions
    (define/override (get-controller-img)
      (overlay
       (get-inner-box)
       (get-outer-box)))

    ;; get-outer-box : -> Image
    ;; GIVEN : no arguments
    ;; RETURNS : an Image consisting of the outer box
    ;; DESIGN STRATEGY : combine simpler functions
    (define (get-outer-box)
      (overlay
       (rectangle width height "outline" "blue")
       (overlay/xy
        (get-handle-img)
        0 0
        (rectangle 40 box-height "outline" "black"))))

    ;; get-handle-img : -> Image
    ;; GIVEN : no arguments
    ;; RETURNS : an Image consisting of handle used to drag controller around
    ;; DESIGN STRATEGY : combine simpler function
    (define (get-handle-img)
      (rectangle handle-side handle-side "outline" (current-handle-color)))

    ;; get-inner-box : -> Image
    ;; GIVEN : no arguments
    ;; RETURNS : an Image consisting of the particle and inner box
    ;; DESIGN STRATEGY : combine simpler functions
    (define (get-inner-box)
      (place-image
       (get-particle-img)
       (/ width 2)
       particle-y
       (rectangle width height "outline" "blue")))

    ;; get-particle-img : -> Image
    ;; GIVEN : no arguments
    ;; RETURNS : an Image of the particle
    ;; DESIGN STRATEGY : combine simpler functions
    (define (get-particle-img)
      (overlay
       (circle 3 "solid" "black")
       (circle 10 "solid" "red")))

    ;; current-handle-color : -> String
    ;; GIVEN : no arguments
    ;; RETURNS : String of the color handle should have
    ;; DESIGN STRATEGY : cases on wether the controller is draggable or not
    (define (current-handle-color)
      (if draggable? "red" "black"))
    
    ;; after-button-down : Integer Integer -> Void
    ;; GIVEN : x/y coordinates of the mouse
    ;; EFFECT : upadtes this object to a state which should follow after button down
    ;; DESIGN STRATEGY : cases based on position of the mouse
    (define/override (after-button-down mx my)
      (cond [(in-handle? mx my)
             (begin
               (set! draggable? true)
               (set! off-mx (- center-x mx))
               (set! off-my (- center-y my))
               (set! handle-off-mx (- handle-center-x mx))
               (set! handle-off-my (- handle-center-y my)))]
            [(in-controller? mx my)
             (begin
               (set! selected? true)
               (set! dy-from-mouse (- my particle-y))
               (send model execute-command
                     (make-set-paused true)))]
            [else this]))

    ;; after-drag : Integer Integer -> Void
    ;; GIVEN : x/y coordinates of the mouse
    ;; EFFECT : updates this object to a state which should follow after drag
    ;; DESIGN STRATEGY : cases on position of mouse
    (define/override (after-drag mx my)
      (cond
        [draggable?
          (begin
            (set! center-x (+ mx off-mx))
            (set! center-y (+ my off-my))
            (set! handle-center-x (+ mx handle-off-mx))
            (set! handle-center-y (+ my handle-off-my)))]
        [selected?
         (send model execute-command
               (make-set-position
                particle-x
                (- my dy-from-mouse)))]))

    ;; in-handle? : Integer Integer -> Boolean
    ;; GIVEN : x/y coordinates of the mouse
    ;; RETURNS : true if the mouse is in handle else false
    ;; DESIGN STRATEGY : combine simpler functions
    (define (in-handle? mx my)
      (and (<= (- handle-center-x half-handle-side)
               mx
               (+ handle-center-x half-handle-side))
           (<= (- handle-center-y half-handle-side)
               my 
               (+ handle-center-y half-handle-side))))

    ;; in-controller? : Integer Integer -> Boolean
    ;; GIVEN : x/y coordinates of the mouse
    ;; RETURNS : true if the mouse is in controller else false
    ;; DESIGN STRATEGY : combine simpler functions
    (define (in-controller? mx my)
      (and (<= (- center-x half-width)
               mx
               (+ center-x half-width))
           (<= (- center-y half-height)
               my 
               (+ center-y half-height))))
    ))

;;; A XYController is a (new XYController% [m Model<%>]
;;;                                        [center-x NonNegInt]
;;;                                        [center-y NonNegInt])
;;;
;;; A XYController represents a class which visually displays data related to the
;;; particle in graphical format. In particular, it displays the particle's
;;; position on x-axis and y-axis.
(define XYController%
  (class* GraphicalController% (Controller<%>)

    ;; fields needed from the super-class
    (inherit-field model center-x center-y draggable? off-mx off-my handle-off-mx
                   half-handle-side handle-side handle-off-my selected? particle-x
                   particle-y handle-center-x handle-center-y particle-vx
                   particle-vy box-width box-height half-box-width half-box-height
                   dx-from-mouse dy-from-mouse)

    ;; dimensions of the field of interaction inside the controller
    (field [width 150])
    (field [height 100])

    ;; half of dimensions of the field of interaction inside the controller
    (field [half-width (/ width 2)])
    (field [half-height (/ height 2)])

    (super-new)

    ;; register this controller with model
    (send model register this)

    ;; set handle-center-x and handle-center-y to new values
    (set! handle-center-x (+ (- center-x half-box-width) half-handle-side))
    (set! handle-center-y (+ (- center-y half-box-height) half-handle-side))

    ;; get-controller-img : -> Image
    ;; GIVEN : no arguments
    ;; RETURNS : an image with this controller painted on it
    ;; DESIGN STRATEGY : combine simpler functions
    (define/override (get-controller-img)
      (overlay
       (get-inner-box)
       (get-outer-box)))

    ;; get-outer-box : -> Image
    ;; GIVEN : no arguments
    ;; RETURNS : an Image consisting of the outer box
    ;; DESIGN STRATEGY : combine simpler functions
    (define (get-outer-box)
      (overlay
       (rectangle width height "outline" "blue")
       (overlay/xy
        (get-handle-img)
        0 0
        (rectangle box-width box-height "outline" "black"))))

    ;; get-handle-img : -> Image
    ;; GIVEN : no arguments
    ;; RETURNS : an Image consisting of handle used to drag controller around
    ;; DESIGN STRATEGY : combine simpler function
    (define (get-handle-img)
      (rectangle handle-side handle-side "outline" (current-handle-color)))

    ;; get-inner-box : -> Image
    ;; GIVEN : no arguments
    ;; RETURNS : an Image consisting of the particle and inner box
    ;; DESIGN STRATEGY : combine simpler functions
    (define (get-inner-box)
      (place-image
       (get-particle-img)
       particle-x
       particle-y
       (rectangle width height "outline" "blue")))

    ;; get-particle-img : -> Image
    ;; GIVEN : no arguments
    ;; RETURNS : an Image of the particle
    ;; DESIGN STRATEGY : combine simpler functions
    (define (get-particle-img)
      (overlay
       (circle 3 "solid" "black")
       (circle 10 "solid" "red")))

    ;; current-handle-color : -> String
    ;; GIVEN : no arguments
    ;; RETURNS : String of the color handle should have
    ;; DESIGN STRATEGY : cases on wether the controller is draggable or not
    (define (current-handle-color)
      (if draggable? "red" "black"))

    ;; after-button-down : Integer Integer -> Void
    ;; GIVEN : x/y coordinates of the mouse
    ;; EFFECT : upadtes this object to a state which should follow after button down
    ;; DESIGN STRATEGY : cases based on position of the mouse
    (define/override (after-button-down mx my)
      (cond [(in-handle? mx my)
             (begin
               (set! draggable? true)
               (set! off-mx (- center-x mx))
               (set! off-my (- center-y my))
               (set! handle-off-mx (- handle-center-x mx))
               (set! handle-off-my (- handle-center-y my)))]
            [(in-controller? mx my)
             (begin
               (set! selected? true)
               (set! dx-from-mouse (- mx particle-x))
               (set! dy-from-mouse (- my particle-y))
               (send model execute-command
                     (make-set-paused true)))]
            [else this]))

    ;; after-drag : Integer Integer -> Void
    ;; GIVEN : x/y coordinates of the mouse
    ;; EFFECT : updates this object to a state which should follow after drag
    ;; DESIGN STRATEGY : cases on position of mouse
    (define/override (after-drag mx my)
      (cond
        [draggable?
          (begin
            (set! center-x (+ mx off-mx))
            (set! center-y (+ my off-my))
            (set! handle-center-x (+ mx handle-off-mx))
            (set! handle-center-y (+ my handle-off-my)))] 
        [selected?
         (send model execute-command
               (make-set-position
                (- mx dx-from-mouse)
                (- my dy-from-mouse)))]))

    ;; in-controller? : Integer Integer -> Boolean
    ;; GIVEN : x/y coordinates of the mouse
    ;; RETURNS : true if the mouse is in controller else false
    ;; DESIGN STRATEGY : combine simpler functions
    (define (in-controller? mx my)
      (and (<= (- center-x half-width)
               mx
               (+ center-x half-width))
           (<= (- center-y half-height)
               my 
               (+ center-y half-height))))

    ;; in-handle? : Integer Integer -> Boolean
    ;; GIVEN : x/y coordinates of the mouse
    ;; RETURNS : true if the mouse is in handle else false
    ;; DESIGN STRATEGY : combine simpler functions
    (define (in-handle? mx my)
      (and (<= (- handle-center-x half-handle-side)
               mx
               (+ handle-center-x half-handle-side))
           (<= (- handle-center-y half-handle-side)
               my 
               (+ handle-center-y half-handle-side))))
    ))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; TESTS:


(define MODEL-1 (new Model%))
(define MODEL-2 (new Model%))
(define MODEL-3 (new Model%))
(define MODEL-4 (new Model%))
(define MODEL-5 (new Model%))

;; tests for VelocityController

(define VELOCITY-CONTROLLER
  (new VelocityController%
       [model MODEL-1]
       [center-x 100]
       [center-y 250]))

(define VELOCITY-CONTROLLER-2
  (new VelocityController%
       [model MODEL-1]
       [center-x 95]
       [center-y 245]))

(define VELOCITY-CONTROLLER-3
  (new VelocityController%
       [model MODEL-1]
       [center-x 95]
       [center-y 245]))

(define VC-UNSELECTED-TEXT-IMG
  (above (text "Arrow keys change Velocity"
               9 
               "black")
         (text (string-append
                "X="
                (real->decimal-string 75)
                " Y="
                (real->decimal-string 50))
               9 
               "black")
         (text (string-append
                "VX="
                (real->decimal-string 0)
                " VY="
                (real->decimal-string 0))
               9
               "black")))

(define VC-SELECTED-TEXT-IMG
  (above (text "Arrow keys change Velocity"
               9 
               "red")
         (text (string-append
                "X="
                (real->decimal-string 75)
                " Y="
                (real->decimal-string 50))
               9 
               "red")
         (text (string-append
                "VX="
                (real->decimal-string 0)
                " VY="
                (real->decimal-string 0))
               9
               "red")))

(define VC-UNDRAGGABLE-RECT-IMG
  (overlay/offset
       (rectangle
        10
        10
        "outline"
        "black")
       (- (+ 75) 5)
       (- (+ 20) 5)
       (rectangle
        150
        40
        "outline"
        "black")))

(define VC-DRAGGABLE-RECT-IMG
  (overlay/offset
       (rectangle
        10
        10
        "outline"
        "red")
       (- (+ 75) 5)
       (- (+ 20) 5)
       (rectangle
        150
        40
        "outline"
        "black")))

(define EMPTY-CANVAS (empty-scene 500 600))

(define UNSELECTED/UNDRAGGABLE-VC-IMG
  (overlay
   VC-UNSELECTED-TEXT-IMG
   VC-UNDRAGGABLE-RECT-IMG))

(define UNSELECTED/DRAGGABLE-VC-IMG
  (overlay
   VC-UNSELECTED-TEXT-IMG
   VC-DRAGGABLE-RECT-IMG))

(define SELECTED/UNDRAGGABLE-VC-IMG
  (overlay
   VC-SELECTED-TEXT-IMG
   VC-UNDRAGGABLE-RECT-IMG))

(define TEST-SCENE-1
  (place-image
   UNSELECTED/UNDRAGGABLE-VC-IMG
   95
   245
   EMPTY-CANVAS))

(define TEST-SCENE-2
  (place-image
   UNSELECTED/DRAGGABLE-VC-IMG
   95
   245
   EMPTY-CANVAS))

(define TEST-SCENE-3
  (place-image
   SELECTED/UNDRAGGABLE-VC-IMG
   95
   245
   EMPTY-CANVAS))

(define VC-INITIAL-PARTICLE-X (send VELOCITY-CONTROLLER for-test:particle-x))
(define VC-INITIAL-PARTICLE-Y (send VELOCITY-CONTROLLER for-test:particle-y))
(define VC-INITIAL-PARTICLE-VX (send VELOCITY-CONTROLLER for-test:particle-vx))
(define VC-INITIAL-PARTICLE-VY (send VELOCITY-CONTROLLER for-test:particle-vy))
(begin (send VELOCITY-CONTROLLER after-tick))
(define VC-PARTICLE-X-AFTER-1-TICK (send VELOCITY-CONTROLLER for-test:particle-x))
(define VC-PARTICLE-Y-AFTER-1-TICK (send VELOCITY-CONTROLLER for-test:particle-y))
(define VC-PARTICLE-VX-AFTER-1-TICK (send VELOCITY-CONTROLLER for-test:particle-vx))
(define VC-PARTICLE-VY-AFTER-1-TICK (send VELOCITY-CONTROLLER for-test:particle-vy))
(send VELOCITY-CONTROLLER after-button-down 500 500)
(define VC-SELECTED?-AFTER-BD-1 (send VELOCITY-CONTROLLER for-test:selected?))
(define VC-DRAGGABLE?-AFTER-BD-1 (send VELOCITY-CONTROLLER for-test:draggable?))
(send VELOCITY-CONTROLLER after-drag 100 100)
(define VC-X-AFTER-DRAG-1 (send VELOCITY-CONTROLLER for-test:center-x))
(define VC-Y-AFTER-DRAG-1 (send VELOCITY-CONTROLLER for-test:center-y))
(send VELOCITY-CONTROLLER after-button-down 30 235)
(define VC-DRAGGABLE-AFTER-BD-2 (send VELOCITY-CONTROLLER for-test:draggable?))
(send VELOCITY-CONTROLLER after-drag 25 230)
(define VC-X-AFTER-DRAG-2 (send VELOCITY-CONTROLLER for-test:center-x))
(define VC-Y-AFTER-DRAG-2 (send VELOCITY-CONTROLLER for-test:center-y))
(send VELOCITY-CONTROLLER after-button-up 500 500)
(define VC-SELECTED-AFTER-BU (send VELOCITY-CONTROLLER for-test:selected?))
(send VELOCITY-CONTROLLER after-button-down 95 245)
(define VC-SELECTED-AFTER-BD-3 (send VELOCITY-CONTROLLER for-test:selected?))
(send VELOCITY-CONTROLLER after-key-event "left")
(define VC-PARTICLE-VX-AFTER-LEFT (send VELOCITY-CONTROLLER for-test:particle-vx))
(send VELOCITY-CONTROLLER after-key-event "right")
(define VC-PARTICLE-VX-AFTER-RIGHT (send VELOCITY-CONTROLLER for-test:particle-vx))
(send VELOCITY-CONTROLLER after-key-event "up")
(define VC-PARTICLE-VY-AFTER-UP (send VELOCITY-CONTROLLER for-test:particle-vy))
(send VELOCITY-CONTROLLER after-key-event "down")
(define VC-PARTICLE-VY-AFTER-DOWN (send VELOCITY-CONTROLLER for-test:particle-vy))
(send VELOCITY-CONTROLLER after-key-event "j")
(send VELOCITY-CONTROLLER after-button-up 100 100)
(send VELOCITY-CONTROLLER after-key-event "g")


(begin-for-test
  (check-equal?
   VC-INITIAL-PARTICLE-X 75
   "The initial x coordinate of the particle should be 75")
  (check-equal?
   VC-INITIAL-PARTICLE-Y 50
   "The intial y coordinate of the particle should be 50")
  (check-equal?
   VC-INITIAL-PARTICLE-VX 0
   "The initial vx of the particle should be 0")
  (check-equal?
   VC-INITIAL-PARTICLE-VY 0
   "The initial vy of the particle should be 0")
  (check-equal?
   VC-PARTICLE-X-AFTER-1-TICK 75
   "A tick sent to the controller should not affect x")
  (check-equal?
   VC-PARTICLE-Y-AFTER-1-TICK 50
   "A tick sent to the controller should not affect y")
  (check-equal?
   VC-PARTICLE-VX-AFTER-1-TICK 0
   "A tick sent to the controller should not affect vx")
  (check-equal?
   VC-PARTICLE-VY-AFTER-1-TICK 0
   "A tick sent to the controller should not affect vy")
  (check-equal?
   VC-SELECTED?-AFTER-BD-1 false
   "The controller should not be selected after the given button down")
  (check-equal?
   VC-DRAGGABLE?-AFTER-BD-1 false
   "The controller should not be draggable after the given button down")
  (check-equal?
   VC-X-AFTER-DRAG-1 100
   "A drag should have no effect when the controller is not selected")
  (check-equal?
   VC-Y-AFTER-DRAG-1 250
   "A drag should have no effect when the controlle is not selected")
  (check-equal?
   VC-SELECTED-AFTER-BU false
   "The controller should not be selected")
  (check-equal?
   VC-DRAGGABLE-AFTER-BD-2 true
   "The controller should be draggable after a button down at the given location")
  (check-equal?
   VC-X-AFTER-DRAG-2 95
   "The x coordinate after the given drag should be 95")
  (check-equal?
   VC-Y-AFTER-DRAG-2 245
   "The y coordinate after the given drag should be 245")
  (check-equal?
   VC-SELECTED-AFTER-BD-3 true
   "The controller should be selected after the given button down")
  (check-equal?
   VC-PARTICLE-VX-AFTER-LEFT -5
   "The vx of the particle should be -5 after the given key event")
  (check-equal?
   VC-PARTICLE-VX-AFTER-RIGHT 0
   "The vx of the particle should be 0")
  (check-equal?
   VC-PARTICLE-VY-AFTER-UP -5
   "The vy of the particle should be -5")
  (check-equal?
   VC-PARTICLE-VY-AFTER-DOWN 0
   "The vy of the particle should be 0")
  (check-equal?
   (send VELOCITY-CONTROLLER add-to-scene EMPTY-CANVAS) TEST-SCENE-1
  "The two images should be the same"))

(send VELOCITY-CONTROLLER-2 after-button-down 25 230)

(begin-for-test
  (check-equal? (send VELOCITY-CONTROLLER-2 add-to-scene EMPTY-CANVAS) TEST-SCENE-2)
  "The two images should be the same")

(send VELOCITY-CONTROLLER-3 after-button-down 95 245)

(begin-for-test
  (check-equal? (send VELOCITY-CONTROLLER-3 add-to-scene EMPTY-CANVAS) TEST-SCENE-3)
  "The two images should be the same")
                
;; tests for PositionController                  
  

(define POSITION-CONTROLLER
  (new PositionController%
       [model MODEL-2]
       [center-x 100]
       [center-y 250]))

(define POSITION-CONTROLLER-2
  (new PositionController%
       [model MODEL-2]
       [center-x 95]
       [center-y 245]))

(define POSITION-CONTROLLER-3
  (new PositionController%
       [model MODEL-2]
       [center-x 95]
       [center-y 245]))


(define PC-UNSELECTED-TEXT-IMG
  (above (text "Arrow keys change Position"
               9 
               "black")
         (text (string-append
                "X="
                (real->decimal-string 75)
                " Y="
                (real->decimal-string 50))
               9 
               "black")
         (text (string-append
                "VX="
                (real->decimal-string 0)
                " VY="
                (real->decimal-string 0))
               9
               "black")))

(define PC-SELECTED-TEXT-IMG
  (above (text "Arrow keys change Position"
               9 
               "red")
         (text (string-append
                "X="
                (real->decimal-string 75)
                " Y="
                (real->decimal-string 50))
               9 
               "red")
         (text (string-append
                "VX="
                (real->decimal-string 0)
                " VY="
                (real->decimal-string 0))
               9
               "red")))

(define PC-UNDRAGGABLE-RECT-IMG
  (overlay/offset
       (rectangle
        10
        10
        "outline"
        "black")
       (- (+ 75) 5)
       (- (+ 20) 5)
       (rectangle
        150
        40
        "outline"
        "black")))

(define PC-DRAGGABLE-RECT-IMG
  (overlay/offset
       (rectangle
        10
        10
        "outline"
        "red")
       (- (+ 75) 5)
       (- (+ 20) 5)
       (rectangle
        150
        40
        "outline"
        "black")))

(define UNSELECTED/UNDRAGGABLE-PC-IMG
  (overlay
   PC-UNSELECTED-TEXT-IMG
   PC-UNDRAGGABLE-RECT-IMG))

(define UNSELECTED/DRAGGABLE-PC-IMG
  (overlay
   PC-UNSELECTED-TEXT-IMG
   PC-DRAGGABLE-RECT-IMG))

(define SELECTED/UNDRAGGABLE-PC-IMG
  (overlay
   PC-SELECTED-TEXT-IMG
   PC-UNDRAGGABLE-RECT-IMG))

(define TEST-SCENE-4
  (place-image
   UNSELECTED/UNDRAGGABLE-PC-IMG
   95
   245
   EMPTY-CANVAS))

(define TEST-SCENE-5
  (place-image
   UNSELECTED/DRAGGABLE-PC-IMG
   95
   245
   EMPTY-CANVAS))

(define TEST-SCENE-6
  (place-image
   SELECTED/UNDRAGGABLE-PC-IMG
   95
   245
   EMPTY-CANVAS))


(define PC-INITIAL-PARTICLE-X (send POSITION-CONTROLLER for-test:particle-x))
(define PC-INITIAL-PARTICLE-Y (send POSITION-CONTROLLER for-test:particle-y))
(define PC-INITIAL-PARTICLE-VX (send POSITION-CONTROLLER for-test:particle-vx))
(define PC-INITIAL-PARTICLE-VY (send POSITION-CONTROLLER for-test:particle-vy))
(send POSITION-CONTROLLER after-tick)
(define PC-PARTICLE-X-AFTER-1-TICK (send POSITION-CONTROLLER for-test:particle-x))
(define PC-PARTICLE-Y-AFTER-1-TICK (send POSITION-CONTROLLER for-test:particle-y))
(define PC-PARTICLE-VX-AFTER-1-TICK (send POSITION-CONTROLLER for-test:particle-vx))
(define PC-PARTICLE-VY-AFTER-1-TICK (send POSITION-CONTROLLER for-test:particle-vy))
(send POSITION-CONTROLLER after-button-down 500 500)
(define PC-SELECTED?-AFTER-BD-1 (send POSITION-CONTROLLER for-test:selected?))
(define PC-DRAGGABLE?-AFTER-BD-1 (send POSITION-CONTROLLER for-test:draggable?))
(send POSITION-CONTROLLER after-drag 100 100)
(define PC-X-AFTER-DRAG-1 (send POSITION-CONTROLLER for-test:center-x))
(define PC-Y-AFTER-DRAG-1 (send POSITION-CONTROLLER for-test:center-y))
(send POSITION-CONTROLLER after-button-down 30 235)
(define PC-DRAGGABLE-AFTER-BD-2 (send POSITION-CONTROLLER for-test:draggable?))
(send POSITION-CONTROLLER after-drag 25 230)
(define PC-X-AFTER-DRAG-2 (send POSITION-CONTROLLER for-test:center-x))
(define PC-Y-AFTER-DRAG-2 (send POSITION-CONTROLLER for-test:center-y))
(send POSITION-CONTROLLER after-button-up 500 500)
(send POSITION-CONTROLLER after-button-down 95 245)
(define PC-SELECTED-AFTER-BD-3 (send POSITION-CONTROLLER for-test:selected?))
(send POSITION-CONTROLLER after-key-event "left")
(define PC-PARTICLE-X-AFTER-LEFT (send POSITION-CONTROLLER for-test:particle-x))
(send POSITION-CONTROLLER after-key-event "right")
(define PC-PARTICLE-X-AFTER-RIGHT (send POSITION-CONTROLLER for-test:particle-x))
(send POSITION-CONTROLLER after-key-event "up")
(define PC-PARTICLE-Y-AFTER-UP (send POSITION-CONTROLLER for-test:particle-y))
(send POSITION-CONTROLLER after-key-event "down")
(define PC-PARTICLE-Y-AFTER-DOWN (send POSITION-CONTROLLER for-test:particle-y))
(send POSITION-CONTROLLER after-key-event "j")
(send POSITION-CONTROLLER after-button-up 100 100)
(send POSITION-CONTROLLER after-key-event "g")

(begin-for-test
  (check-equal?
   PC-INITIAL-PARTICLE-X 75
   "The initial x coordinate of the particle should be 75")
  (check-equal?
   PC-INITIAL-PARTICLE-Y 50
   "The intial y coordinate of the particle should be 50")
  (check-equal?
   PC-INITIAL-PARTICLE-VX 0
   "The initial vx of the particle should be 0")
  (check-equal?
   PC-INITIAL-PARTICLE-VY 0
   "The initial vy of the particle should be 0")
  (check-equal?
   PC-PARTICLE-X-AFTER-1-TICK 75
   "A tick sent to the controller should not affect x")
  (check-equal?
   PC-PARTICLE-Y-AFTER-1-TICK 50
   "A tick sent to the controller should not affect y")
  (check-equal?
   PC-PARTICLE-VX-AFTER-1-TICK 0
   "A tick sent to the controller should not affect vx")
  (check-equal?
   PC-PARTICLE-VY-AFTER-1-TICK 0
   "A tick sent to the controller should not affect vy")
  (check-equal?
   PC-SELECTED?-AFTER-BD-1 false
   "The controller should not be selected after the given button down")
  (check-equal?
   PC-DRAGGABLE?-AFTER-BD-1 false
   "The controller should not be draggable after the given button down")
  (check-equal?
   PC-X-AFTER-DRAG-1 100
   "A drag should have no effect when the controller is not selected")
  (check-equal?
   PC-Y-AFTER-DRAG-1 250
   "A drag should have no effect when the controlle is not selected")
  (check-equal?
   PC-DRAGGABLE-AFTER-BD-2 true
   "The controller should be draggable after a button down at the given location")
  (check-equal?
   PC-X-AFTER-DRAG-2 95
   "The x coordinate after the given drag should be 95")
  (check-equal?
   PC-Y-AFTER-DRAG-2 245
   "The y coordinate after the given drag should be 245")
  (check-equal?
   PC-SELECTED-AFTER-BD-3 true
   "The controller should be selected after the given button down")
  (check-equal?
   PC-PARTICLE-X-AFTER-LEFT 70
   "The x coordinate of the particle should be 70 after the given key event")
  (check-equal?
   PC-PARTICLE-X-AFTER-RIGHT 75
   "The x coordinate of the particle should be 75")
  (check-equal?
   PC-PARTICLE-Y-AFTER-UP 45
   "The y coordinate of the particle should be 45")
  (check-equal?
   PC-PARTICLE-Y-AFTER-DOWN 50
   "The y of the particle should be 50")
  (check-equal?
   (send POSITION-CONTROLLER add-to-scene EMPTY-CANVAS) TEST-SCENE-4
  "The two images should be the same"))

(send POSITION-CONTROLLER-2 after-button-down 25 230)

(begin-for-test
  (check-equal? (send POSITION-CONTROLLER-2 add-to-scene EMPTY-CANVAS) TEST-SCENE-5)
  "The two images should be the same")

(send POSITION-CONTROLLER-3 after-button-down 95 245)

(begin-for-test
  (check-equal? (send POSITION-CONTROLLER-3 add-to-scene EMPTY-CANVAS) TEST-SCENE-6)
  "The two images should be the same")


;; tests for XController

(define X-CONTROLLER (new XController%
               [model MODEL-4]
               [center-x 100]
               [center-y 250]))

(define X-CONTROLLER-2 (new XController%
                [model MODEL-4]
                [center-x 95]
                [center-y 245]))

(define X-TEST-IMG-1
  (overlay
   (place-image
    (overlay
     (circle 3 "solid" "black")
     (circle 10 "solid" "red"))
    74
    (/ 40 2)
    (rectangle 150 40 "outline" "blue"))
   (overlay
    (rectangle 150 40 "outline" "blue")
    (overlay/xy
     (rectangle 10 10 "outline" "black")
     0 0
     (rectangle 180 40 "outline" "black")))))

(define X-TEST-IMG-DRAGGABLE
  (overlay
   (place-image
    (overlay
     (circle 3 "solid" "black")
     (circle 10 "solid" "red"))
    74
    (/ 40 2)
    (rectangle 150 40 "outline" "blue"))
   (overlay
    (rectangle 150 40 "outline" "blue")
    (overlay/xy
     (rectangle 10 10 "outline" "red")
     0 0
     (rectangle 180 40 "outline" "black")))))


(define X-TEST-SCENE-1
  (place-image X-TEST-IMG-1 95 245 EMPTY-CANVAS))

(define X-TEST-SCENE-2
  (place-image X-TEST-IMG-DRAGGABLE 95 245 EMPTY-CANVAS))

(define X-INITIAL-PARTICLE-X (send X-CONTROLLER for-test:particle-x))
(define X-INITIAL-PARTICLE-Y (send X-CONTROLLER for-test:particle-y))
(define X-INITIAL-PARTICLE-VX (send X-CONTROLLER for-test:particle-vx))
(define X-INITIAL-PARTICLE-VY (send X-CONTROLLER for-test:particle-vy))
(send X-CONTROLLER after-tick)
(send X-CONTROLLER after-key-event "up")
(define X-PARTICLE-X-AFTER-TICK (send X-CONTROLLER for-test:particle-x))
(define X-PARTICLE-Y-AFTER-TICK (send X-CONTROLLER for-test:particle-y))
(define X-PARTICLE-VX-AFTER-TICK (send X-CONTROLLER for-test:particle-vx))
(define X-PARTICLE-VY-AFTER-TICK (send X-CONTROLLER for-test:particle-vy))
(send X-CONTROLLER after-button-down 500 500)
(define X-CONTROLLER-SELECTED-BD-1 (send X-CONTROLLER for-test:selected?))
(send X-CONTROLLER after-drag 400 400)
(define X-PARTICLE-X-AFTER-DRAG-1 (send X-CONTROLLER for-test:particle-x))
(define X-PARTICLE-Y-AFTER-DRAG-1 (send X-CONTROLLER for-test:particle-y))
(define X-CENTER-X-AFTER-DRAG-1 (send X-CONTROLLER for-test:center-x))
(define X-CENTER-Y-AFTER-DRAG-1 (send X-CONTROLLER for-test:center-y))
(send X-CONTROLLER after-button-down 15 235)
(define X-DRAGGABLE-AFTER-BD-2 (send X-CONTROLLER for-test:draggable?))
(send X-CONTROLLER after-drag 10 230)
(define X-CENTER-X-AFTER-DRAG-2 (send X-CONTROLLER for-test:center-x))
(define X-CENTER-Y-AFTER-DRAG-2 (send X-CONTROLLER for-test:center-y))
(send X-CONTROLLER after-button-up 500 500)
(send X-CONTROLLER after-button-down 95 245)
(define X-SELECTED-AFTER-BD-3 (send X-CONTROLLER for-test:selected?))
(send X-CONTROLLER after-drag 94 244)
(define XC-PARTICLE-X-AFTER-DRAG-3 (send X-CONTROLLER for-test:particle-x))
(define XC-PARTICLE-Y-AFTER-DRAG-3 (send X-CONTROLLER for-test:particle-y))


(begin-for-test
  (check-equal?
   X-INITIAL-PARTICLE-X 75
   "The intial x coordinate of the particle should be 75")
  (check-equal?
   X-INITIAL-PARTICLE-Y 50
   "The initial y coordinate of the particle should be 50")
  (check-equal?
   X-INITIAL-PARTICLE-VY 0
   "The initial vy should be 0")
  (check-equal?
   X-INITIAL-PARTICLE-VX 0
   "The initial vx should be 0")
  (check-equal?
   X-PARTICLE-X-AFTER-TICK 75
   "A tick has no effect on a controller")
  (check-equal?
   X-PARTICLE-Y-AFTER-TICK 50
   "A tick has no effect on a controller")
  (check-equal?
   X-PARTICLE-VX-AFTER-TICK 0
   "A tick has no effect on a controller")
  (check-equal?
   X-PARTICLE-VY-AFTER-TICK 0
   "A tick has no effect on a controller")
  (check-equal?
   X-CONTROLLER-SELECTED-BD-1 false
   "The button down was outside the controller")
  (check-equal?
   X-PARTICLE-X-AFTER-DRAG-1 75
   "The given drag should have no effect")
  (check-equal?
   X-PARTICLE-Y-AFTER-DRAG-1 50
   "The given drag should have no effect")
  (check-equal?
   X-CENTER-X-AFTER-DRAG-1 100
   "The given drag should have no effect")
  (check-equal?
   X-CENTER-Y-AFTER-DRAG-1 250
   "The given drag should have no effect")
  (check-equal?
   X-DRAGGABLE-AFTER-BD-2 true
   "The controller should be draggable after the given buton-down")
  (check-equal?
   X-CENTER-X-AFTER-DRAG-2 95
   "The new x coordinate of the controller should be 95")
  (check-equal?
   X-CENTER-Y-AFTER-DRAG-2 245
   "The new y coordinate of the controller should be 245")
  (check-equal?
   X-SELECTED-AFTER-BD-3 true
   "The controller should be selected after the given button-down")
  (check-equal?
   XC-PARTICLE-X-AFTER-DRAG-3 74
   "The new x coordinate of the particle should be 74")
  (check-equal?
   XC-PARTICLE-Y-AFTER-DRAG-3 50
   "The new y coordinate of the particle should be 49")
  (check-equal?
   X-TEST-SCENE-1 (send X-CONTROLLER add-to-scene EMPTY-CANVAS)
   "The two images should be the same"))

(send X-CONTROLLER-2 after-button-down 15 235)

(begin-for-test
  (check-equal? X-TEST-SCENE-2 (send X-CONTROLLER-2 add-to-scene EMPTY-CANVAS)))

;; tests for YController

(define Y-CONTROLLER (new YController%
               [model MODEL-5]
               [center-x 100]
               [center-y 250]))

(define Y-CONTROLLER-2 (new YController%
                [model MODEL-5]
                [center-x 95]
                [center-y 245]))

(define Y-TEST-IMG-1
  (overlay
   (place-image
    (overlay
     (circle 3 "solid" "black")
     (circle 10 "solid" "red"))
    (/ 40 2)
    49
    (rectangle 40 100 "outline" "blue"))
   (overlay
    (rectangle 40 100 "outline" "blue")
    (overlay/xy
     (rectangle 10 10 "outline" "black")
     0 0
     (rectangle 40 130 "outline" "black")))))

(define Y-TEST-IMG-DRAGGABLE
  (overlay
   (place-image
    (overlay
     (circle 3 "solid" "black")
     (circle 10 "solid" "red"))
    (/ 40 2)
    49
    (rectangle 40 100 "outline" "blue"))
   (overlay
    (rectangle 40 100 "outline" "blue")
    (overlay/xy
     (rectangle 10 10 "outline" "red")
     0 0
     (rectangle 40 130 "outline" "black")))))


(define Y-TEST-SCENE-1
  (place-image Y-TEST-IMG-1 95 245 EMPTY-CANVAS))

(define Y-TEST-SCENE-2
  (place-image Y-TEST-IMG-DRAGGABLE 95 245 EMPTY-CANVAS))

(define Y-INITIAL-PARTICLE-X (send Y-CONTROLLER for-test:particle-x))
(define Y-INITIAL-PARTICLE-Y (send Y-CONTROLLER for-test:particle-y))
(define Y-INITIAL-PARTICLE-VX (send Y-CONTROLLER for-test:particle-vx))
(define Y-INITIAL-PARTICLE-VY (send Y-CONTROLLER for-test:particle-vy))
(send Y-CONTROLLER after-tick)
(send Y-CONTROLLER after-key-event "up")
(define Y-PARTICLE-X-AFTER-TICK (send Y-CONTROLLER for-test:particle-x))
(define Y-PARTICLE-Y-AFTER-TICK (send Y-CONTROLLER for-test:particle-y))
(define Y-PARTICLE-VX-AFTER-TICK (send Y-CONTROLLER for-test:particle-vx))
(define Y-PARTICLE-VY-AFTER-TICK (send Y-CONTROLLER for-test:particle-vy))
(send Y-CONTROLLER after-button-down 500 500)
(define Y-CONTROLLER-SELECTED-BD-1 (send Y-CONTROLLER for-test:selected?))
(send Y-CONTROLLER after-drag 400 400)
(define Y-PARTICLE-X-AFTER-DRAG-1 (send Y-CONTROLLER for-test:particle-x))
(define Y-PARTICLE-Y-AFTER-DRAG-1 (send Y-CONTROLLER for-test:particle-y))
(define Y-CENTER-X-AFTER-DRAG-1 (send Y-CONTROLLER for-test:center-x))
(define Y-CENTER-Y-AFTER-DRAG-1 (send Y-CONTROLLER for-test:center-y))
(send Y-CONTROLLER after-button-down 85 190)
(define Y-DRAGGABLE-AFTER-BD-2 (send Y-CONTROLLER for-test:draggable?))
(send Y-CONTROLLER after-drag 80 185)
(define Y-CENTER-X-AFTER-DRAG-2 (send Y-CONTROLLER for-test:center-x))
(define Y-CENTER-Y-AFTER-DRAG-2 (send Y-CONTROLLER for-test:center-y))
(send Y-CONTROLLER after-button-up 500 500)
(send Y-CONTROLLER after-button-down 95 245)
(define Y-SELECTED-AFTER-BD-3 (send Y-CONTROLLER for-test:selected?))
(send Y-CONTROLLER after-drag 94 244)
(define YC-PARTICLE-X-AFTER-DRAG-3 (send Y-CONTROLLER for-test:particle-x))
(define YC-PARTICLE-Y-AFTER-DRAG-3 (send Y-CONTROLLER for-test:particle-y))


(begin-for-test
  (check-equal?
   Y-INITIAL-PARTICLE-X 75
   "The intial x coordinate of the particle should be 75")
  (check-equal?
   Y-INITIAL-PARTICLE-Y 50
   "The initial y coordinate of the particle should be 50")
  (check-equal?
   Y-INITIAL-PARTICLE-VY 0
   "The initial vy should be 0")
  (check-equal?
   Y-INITIAL-PARTICLE-VX 0
   "The initial vx should be 0")
  (check-equal?
   Y-PARTICLE-X-AFTER-TICK 75
   "A tick has no effect on a controller")
  (check-equal?
   Y-PARTICLE-Y-AFTER-TICK 50
   "A tick has no effect on a controller")
  (check-equal?
   Y-PARTICLE-VX-AFTER-TICK 0
   "A tick has no effect on a controller")
  (check-equal?
   Y-PARTICLE-VY-AFTER-TICK 0
   "A tick has no effect on a controller")
  (check-equal?
   Y-CONTROLLER-SELECTED-BD-1 false
   "The button down was outside the controller")
  (check-equal?
   Y-PARTICLE-X-AFTER-DRAG-1 75
   "The given drag should have no effect")
  (check-equal?
   Y-PARTICLE-Y-AFTER-DRAG-1 50
   "The given drag should have no effect")
  (check-equal?
   Y-CENTER-X-AFTER-DRAG-1 100
   "The given drag should have no effect")
  (check-equal?
   Y-CENTER-Y-AFTER-DRAG-1 250
   "The given drag should have no effect")
  (check-equal?
   Y-DRAGGABLE-AFTER-BD-2 true
   "The controller should be draggable after the given buton-down")
  (check-equal?
   Y-CENTER-X-AFTER-DRAG-2 95
   "The new x coordinate of the controller should be 95")
  (check-equal?
   Y-CENTER-Y-AFTER-DRAG-2 245
   "The new y coordinate of the controller should be 245")
  (check-equal?
   Y-SELECTED-AFTER-BD-3 true
   "The controller should be selected after the given button-down")
  (check-equal?
   YC-PARTICLE-X-AFTER-DRAG-3 75
   "The new x coordinate of the particle should be 74")
  (check-equal?
   YC-PARTICLE-Y-AFTER-DRAG-3 49
   "The new y coordinate of the particle should be 49")
  (check-equal?
   Y-TEST-SCENE-1 (send Y-CONTROLLER add-to-scene EMPTY-CANVAS)
   "The two images should be the same"))

(send Y-CONTROLLER-2 after-button-down 85 190)

(begin-for-test
  (check-equal? Y-TEST-SCENE-2 (send Y-CONTROLLER-2 add-to-scene EMPTY-CANVAS)))

;; tests for XYController

(define XY-CONTROLLER (new XYController%
                [model MODEL-3]
                [center-x 100]
                [center-y 250]))

(define XY-CONTROLLER-2 (new XYController%
                [model MODEL-3]
                [center-x 95]
                [center-y 245]))

(define XY-TEST-IMG-1
  (overlay
   (place-image
    (overlay
     (circle 3 "solid" "black")
     (circle 10 "solid" "red"))
    74
    49
    (rectangle 150 100 "outline" "blue"))
   (overlay
    (rectangle 150 100 "outline" "blue")
    (overlay/xy
     (rectangle 10 10 "outline" "black")
     0 0
     (rectangle 180 130 "outline" "black")))))

(define XY-TEST-IMG-DRAGGABLE
  (overlay
   (place-image
    (overlay
     (circle 3 "solid" "black")
     (circle 10 "solid" "red"))
    74
    49
    (rectangle 150 100 "outline" "blue"))
   (overlay
    (rectangle 150 100 "outline" "blue")
    (overlay/xy
     (rectangle 10 10 "outline" "red")
     0 0
     (rectangle 180 130 "outline" "black")))))


(define XY-TEST-SCENE-1
  (place-image XY-TEST-IMG-1 95 245 EMPTY-CANVAS))

(define XY-TEST-SCENE-2
  (place-image XY-TEST-IMG-DRAGGABLE 95 245 EMPTY-CANVAS))

(define XY-INITIAL-PARTICLE-X (send XY-CONTROLLER for-test:particle-x))
(define XY-INITIAL-PARTICLE-Y (send XY-CONTROLLER for-test:particle-y))
(define XY-INITIAL-PARTICLE-VX (send XY-CONTROLLER for-test:particle-vx))
(define XY-INITIAL-PARTICLE-VY (send XY-CONTROLLER for-test:particle-vy))
(send XY-CONTROLLER after-tick)
(send XY-CONTROLLER after-key-event "up")
(define XY-PARTICLE-X-AFTER-TICK (send XY-CONTROLLER for-test:particle-x))
(define XY-PARTICLE-Y-AFTER-TICK (send XY-CONTROLLER for-test:particle-y))
(define XY-PARTICLE-VX-AFTER-TICK (send XY-CONTROLLER for-test:particle-vx))
(define XY-PARTICLE-VY-AFTER-TICK (send XY-CONTROLLER for-test:particle-vy))
(send XY-CONTROLLER after-button-down 500 500)
(define XY-CONTROLLER-SELECTED-BD-1 (send XY-CONTROLLER for-test:selected?))
(send XY-CONTROLLER after-drag 400 400)
(define XY-PARTICLE-X-AFTER-DRAG-1 (send XY-CONTROLLER for-test:particle-x))
(define XY-PARTICLE-Y-AFTER-DRAG-1 (send XY-CONTROLLER for-test:particle-y))
(define XY-CENTER-X-AFTER-DRAG-1 (send XY-CONTROLLER for-test:center-x))
(define XY-CENTER-Y-AFTER-DRAG-1 (send XY-CONTROLLER for-test:center-y))
(send XY-CONTROLLER after-button-down 15 190)
(define XY-DRAGGABLE-AFTER-BD-2 (send XY-CONTROLLER for-test:draggable?))
(send XY-CONTROLLER after-drag 10 185)
(define XY-CENTER-X-AFTER-DRAG-2 (send XY-CONTROLLER for-test:center-x))
(define XY-CENTER-Y-AFTER-DRAG-2 (send XY-CONTROLLER for-test:center-y))
(send XY-CONTROLLER after-button-up 500 500)
(send XY-CONTROLLER after-button-down 95 245)
(define XY-SELECTED-AFTER-BD-3 (send XY-CONTROLLER for-test:selected?))
(send XY-CONTROLLER after-drag 94 244)
(define PARTICLE-X-AFTER-DRAG-3 (send XY-CONTROLLER for-test:particle-x))
(define PARTICLE-Y-AFTER-DRAG-3 (send XY-CONTROLLER for-test:particle-y))


(begin-for-test
  (check-equal?
   XY-INITIAL-PARTICLE-X 75
   "The intial x coordinate of the particle should be 75")
  (check-equal?
   XY-INITIAL-PARTICLE-Y 50
   "The initial y coordinate of the particle should be 50")
  (check-equal?
   XY-INITIAL-PARTICLE-VY 0
   "The initial vy should be 0")
  (check-equal?
   XY-INITIAL-PARTICLE-VX 0
   "The initial vx should be 0")
  (check-equal?
   XY-PARTICLE-X-AFTER-TICK 75
   "A tick has no effect on a controller")
  (check-equal?
   XY-PARTICLE-Y-AFTER-TICK 50
   "A tick has no effect on a controller")
  (check-equal?
   XY-PARTICLE-VX-AFTER-TICK 0
   "A tick has no effect on a controller")
  (check-equal?
   XY-PARTICLE-VY-AFTER-TICK 0
   "A tick has no effect on a controller")
  (check-equal?
   XY-CONTROLLER-SELECTED-BD-1 false
   "The button down was outside the controller")
  (check-equal?
   XY-PARTICLE-X-AFTER-DRAG-1 75
   "The given drag should have no effect")
  (check-equal?
   XY-PARTICLE-Y-AFTER-DRAG-1 50
   "The given drag should have no effect")
  (check-equal?
   XY-CENTER-X-AFTER-DRAG-1 100
   "The given drag should have no effect")
  (check-equal?
   XY-CENTER-Y-AFTER-DRAG-1 250
   "The given drag should have no effect")
  (check-equal?
   XY-DRAGGABLE-AFTER-BD-2 true
   "The controller should be draggable after the given buton-down")
  (check-equal?
   XY-CENTER-X-AFTER-DRAG-2 95
   "The new x coordinate of the controller should be 95")
  (check-equal?
   XY-CENTER-Y-AFTER-DRAG-2 245
   "The new y coordinate of the controller should be 245")
  (check-equal?
   XY-SELECTED-AFTER-BD-3 true
   "The controller should be selected after the given button-down")
  (check-equal?
   PARTICLE-X-AFTER-DRAG-3 74
   "The new x coordinate of the particle should be 74")
  (check-equal?
   PARTICLE-Y-AFTER-DRAG-3 49
   "The new y coordinate of the particle should be 49")
  (check-equal?
   XY-TEST-SCENE-1 (send XY-CONTROLLER add-to-scene EMPTY-CANVAS)
   "The two images should be the same"))

(send XY-CONTROLLER-2 after-button-down 10 185)

(begin-for-test
  (check-equal? XY-TEST-SCENE-2 (send XY-CONTROLLER-2 add-to-scene EMPTY-CANVAS)))