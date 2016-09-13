#lang racket
(require "Interfaces.rkt")
(require "Model.rkt")
(require 2htdp/image)
(require 2htdp/universe)

(provide Controller%
         TextualController%
         GraphicalController%)

;;; A Controller is a (new Controller% [m Model<%>]
;;;                                    [center-x NonNegInt]
;;;                                    [center-y NonNegInt])
;;;
;;; A Controller contains basic data which is needed to implement any specific
;;; sort of controller.
(define Controller%
  (class* object% (Controller<%>)
    
    ;; a variable to store the model controllers are refering to
    (init-field model)
    
    ;; x/y coordinates of center of the canvas
    (init-field center-x)
    (init-field center-y)
    
    ;; x/y offsets of the mouse click inside the controller
    (init-field [off-mx 0])
    (init-field [off-my 0])
    
    ;; various data needed to implement the functionality of handle which is used
    ;; to drag controller around the screen
    (field [handle-side 10])
    (field [half-handle-side (/ handle-side 2)])
    (field [handle-off-mx 0])
    (field [handle-off-my 0])
    (field [handle-center-x 0])
    (field [handle-center-y 0])
    
    ;; true when the mouse click happens inside the controller
    (field [selected? false])
    
    ;; true when the mouse click happens inside the handle and controller is
    ;; draggable
    (field [draggable? false])
    
    ;; values associated with the partical
    (field [particle-x 0])
    (field [particle-y 0])
    (field [particle-vx 0])
    (field [particle-vy 0])
    
    (super-new)
    
    ;; add-to-scene : Scene -> Scene
    ;; GIVEN : a scene
    ;; RETURNS : a scene like the given one, but with this object
    ;;           painted on it
    ;; DESIGN STRATEGY : combine simpler functions
    (define/public (add-to-scene s)
      (place-image (get-controller-img) center-x center-y s))
    
    ;; after-tick : -> Void
    ;; GIVEN : no arguments
    ;; EFFECT : updates this object to a state which should follow after tick
    ;; DESIGN STRATEGY : return any value
    (define/public (after-tick)
      'void)
    
    ;; after-button-up : Integer Integer -> Void
    ;; GIVEN : x/y co-ordinates of the mouse
    ;; EFFECT : updates this object to a state which should follow after button
    ;;          up
    ;; DESIGN STRATEGY : updates this object to a state which should follow after
    ;;                   button up
    (define/public (after-button-up mx my)
      (begin
        (set! selected? false)
        (set! draggable? false)
        (send model execute-command (make-set-paused false))))
    
    ;; receive-signal : Signal -> Void
    ;; GIVEN : a Signal
    ;; EFFECT : updates this object to a new state using the data sent in signal
    ;; DESIGN STRATEGY : cases on sig
    (define/public (receive-signal sig)
      (cond
        [(report-position? sig)
         (begin
           (set! particle-x (report-position-pos-x sig))
           (set! particle-y (report-position-pos-y sig)))]
        [(report-velocity? sig)
         (begin
           (set! particle-vx (report-velocity-vel-x sig))
           (set! particle-vy (report-velocity-vel-y sig)))]))
    
    ;; few methods which will be implemented by sub-classes. These methods have
    ;; a specific implementation bsaed on the controller in which they happened
    (abstract get-controller-img)
    (abstract after-button-down)
    (abstract after-drag)
    (abstract after-key-event)

    ;; methods for testing
    ;; for-test:particle-x : -> NonNegInt
    ;; GIVEN : no arguments
    ;; RETURNS : x-coordinate of particle
    ;; DESIGN STRATEGY : return a value of this object
    (define/public (for-test:particle-x)
      particle-x)

    ;; for-test:particle-y : -> NonNegInt
    ;; GIVEN : no arguments
    ;; RETURNS : y-coordinate of particle
    ;; DESIGN STRATEGY : return a value of this object
    (define/public (for-test:particle-y)
      particle-y)

    ;; for-test:particle-vx : -> Integer
    ;; GIVEN : no arguments
    ;; RETURNS : x velocity of particle
    ;; DESIGN STRATEGY : return a value of this object
    (define/public (for-test:particle-vx)
      particle-vx)

    ;; for-test:particle-vy : -> NonNegInt
    ;; GIVEN : no arguments
    ;; RETURNS : y velocity of particle
    ;; DESIGN STRATEGY : return a value of this object
    (define/public (for-test:particle-vy)
      particle-vy)

    ;; for-test:selected? : -> Boolean
    ;; GIVEN : no arguments
    ;; RETURNS : true if controller is selected else false
    ;; DESIGN STRATEGY : return a value of this object
    (define/public (for-test:selected?)
      selected?)

    ;; for-test:draggable? : -> Boolean
    ;; GIVEN : no arguments
    ;; RETURNS : true if controller is draggable else false
    ;; DESIGN STRATEGY : return a value of this object
    (define/public (for-test:draggable?)
      draggable?)

    ;; for-test:center-x : -> NonNegInt
    ;; GIVEN : no arguments
    ;; RETURNS : x coordinate of center for canvas
    ;; DESIGN STRATEGY : return a value of this object
    (define/public (for-test:center-x)
      center-x)

    ;; for-test:center-y : -> NonNegInt
    ;; GIVEN : no arguments
    ;; RETURNS : y coordinate of center for canvas
    ;; DESIGN STRATEGY : return a value of this object
    (define/public (for-test:center-y)
      center-y)
    ))

;;; A TextualController is a (new TextualController%)
;;;
;;; A TextualController is an entity which handles the representation of all sorts
;;; of controllers which presents data in text. This class can be inherited to
;;; implement more specific case of data manipulation using TextualControllers.
(define TextualController%
  (class* Controller% (Controller<%>)
    
    ;; fields inherited from the base class for controllers
    (inherit-field model center-x center-y off-mx off-my particle-x particle-y
                   selected? draggable? particle-vx particle-vy 
                   handle-side half-handle-side handle-off-mx handle-off-my
                   handle-center-x handle-center-y)
    
    ;; width and height of textual controller
    (field [width 150])
    (field [height 40])
    
    ;; half of width and height
    (field [half-width (/ width 2)])
    (field [half-height (/ height 2)])
    
    (super-new)
    
    ;; update these values according to dimensions of the controller
    (set! handle-center-x (+ (- center-x half-width) half-handle-side))
    (set! handle-center-y (+ (- center-y half-height) half-handle-side))
    
    ;; after-button-down : Integer Integer -> Void
    ;; GIVEN : x/y coordinates of mouse
    ;; EFFECT : updates this object to a state it should follow after button down
    ;; DESIGN STRATEGY : divide into cases depending on location of mouse
    (define/override (after-button-down mx my)
      (cond [(in-handle? mx my)
             (begin
               (set! draggable? true)
               (set! off-mx (- mx center-x))
               (set! off-my (- my center-y))
               (set! handle-off-mx (- mx handle-center-x))
               (set! handle-off-my (- my handle-center-y)))]
            [(in-controller? mx my)
             (set! selected? true)]
            [else this]))    
    
    ;; in-handle? : Integer Integer -> Boolean
    ;; GIVEN : x/y coordinate of the mouse
    ;; RETURNS : true if the mouse is inside handle else false
    ;; DESIGN STRATEGY : combine simpler functions
    (define (in-handle? mx my)
      (and (<= (- handle-center-x half-handle-side)
               mx
               (+ handle-center-x half-handle-side))
           (<= (- handle-center-y half-handle-side)
               my 
               (+ handle-center-y half-handle-side))))
    
    ;; in-controller? : Integer Integer -> Boolean
    ;; GIVEN : x/y coordinate of the mouse
    ;; RETURNS : true if the mouse is inside controller else false
    ;; DESIGN STRATEGY : combine simpler functions
    (define (in-controller? mx my)
      (and (<= (- center-x half-width)
               mx
               (+ center-x half-width))
           (<= (- center-y half-height)
               my 
               (+ center-y half-height))))
    
    ;; after-drag : Integer Integer -> Void
    ;; GIVEN : x/y coordinate of the mouse
    ;; EFFECT : updates this object to an instance it should follow after drag
    ;; DESIGN STRATEGY : cases on wether the controller is draggable or not
    (define/override (after-drag mx my)
      (if draggable?
          (begin
            (set! center-x (- mx off-mx))
            (set! center-y (- my off-my))
            (set! handle-center-x (- mx handle-off-mx))
            (set! handle-center-y (- my handle-off-my)))
          'this))
    
    ;; get-controller-img : -> Image
    ;; GIVEN : no arguments
    ;; RETURNS : an image with the controller painted on it
    ;; DESIGN STRATEGY : combine simpler function
    (define/override (get-controller-img)
      (overlay
       (get-text-img)
       (get-rect-img)))
    
    ;; get-text-img : -> Image
    ;; GIVEN : no arguments
    ;; RETURNS : an image consisting all the textual information regarding this
    ;;           controller
    ;; DESIGN STRATEGY : combine simpler function
    (define (get-text-img)
      (above (text (get-top-string) 9 (current-handle/text-color selected?))
             (text (string-append "X=" (real->decimal-string particle-x)
                                  " Y=" (real->decimal-string particle-y))
                   9 (current-handle/text-color selected?))
             (text (string-append "VX=" (real->decimal-string particle-vx)
                                  " VY=" (real->decimal-string particle-vy))
                   9 (current-handle/text-color selected?))))

    ;; get-rect-img : -> Image
    ;; GIVEN : no arguments
    ;; RETURNS : an image of the boundary for this controller
    ;; DESIGN STRATEGY : combine simpler function
    (define (get-rect-img)
      (overlay/offset
       (rectangle handle-side handle-side "outline" (current-handle/text-color draggable?))
       (- (+ half-width) half-handle-side)
       (- (+ half-height) half-handle-side)
       (rectangle width height "outline" "black")))

    ;; current-handle/text-color : Boolean -> String
    ;; GIVEN : value of draggable
    ;; RETURNS : the color handle/text should have
    (define (current-handle/text-color val)
      (if val "red" "black"))

    ;; an abstract method to be implemented by sub-classes.
    (abstract get-top-string)
    ))

;;; A GraphicalController is a (new GraphicalController%)
;;;
;;; A GraphicalController is an entity which handles the representation of all sorts
;;; of controllers which presents data using graphics. This class can be inherited to
;;; implement more specific case of data manipulation using GraphicalControllers.
(define GraphicalController%
  (class* Controller% (Controller<%>)

    ;; fields inherited from the base class for controllers
    (inherit-field model center-x center-y off-mx off-my particle-x particle-y
                   selected? draggable? particle-vx particle-vy
                   handle-side handle-center-x handle-center-y half-handle-side
                   handle-off-mx handle-off-my)

    ;; the width and height of the box surrounding the particle
    (field [box-width 180])
    (field [box-height 130])

    ;; half of width and height of the box surrounding the particle
    (field [half-box-width (/ box-width 2)])
    (field [half-box-height (/ box-height 2)])

    ;; offset for particle when mouse click happens
    (field [dx-from-mouse 0])
    (field [dy-from-mouse 0])

    (super-new)

    ;; after-key-event : KeyEvent -> Void
    ;; GIVEN : a KeyEvent
    ;; EFFECT : a state which should follow after-key-event
    ;; DETAIL : GraphicalController ignores after-key-event
    ;; DESIGN STRATEGY : return arbitary value
    (define/override (after-key-event kev)
      'this)
    ))