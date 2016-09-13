#lang racket
(require rackunit)
(require "extras.rkt")
(require 2htdp/universe)   
(require 2htdp/image)
(require "WidgetWorks.rkt")

(provide run
         make-playground
         make-square-toy
         make-throbber
         make-clock
         make-football
         new-target
         Toy<%>
         PlaygroundState<%>
         Target<%>)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; CONSTANTS

;;; constants for canvas dimensions 
(define WIDTH 500)
(define HEIGHT 600)
(define CANVAS-CENTER-X (/ WIDTH 2))
(define CANVAS-CENTER-Y (/ HEIGHT 2))

;;; empty canvas
(define EMPTY-CANVAS (empty-scene WIDTH HEIGHT))

;;; keyboard event constats
(define SQUARE-KEY "s")
(define THROBBER-KEY "t")
(define CLOCK-KEY "w")
(define FOOTBALL-KEY "f")

;;; constants for mouse events
(define MOUSE-BUTTON-DOWN "button-down")
(define MOUSE-BUTTON-DRAG "drag")
(define MOUSE-BUTTON-UP "button-up")

;;; constants for throbber class
(define INITIAL-THROBBER-SIZE 5)

;;; constants for football class
(define INITIAL-FOOTBALL-SIZE 30)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; DATA DEFINITIONS :

;;; ListOfToy<%> (LOT<%>) :
;;; A LOT<%> is either :
;;; -- empty                : a LOT<%> with no elements
;;; -- (cons Toy<%> LOT<%>) : a LOT<%> with first element as toy and LOT<%> in rest
#;(define (lot-fn lot)
    (cond
      [(empty? lot)...]
      [else
       (... (send (first (lot)) ...)
            (lot-fn (rest (lot))))]))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; INTERFACES :

;;; This is built upon the the SWidget<%>. Every object in Playground must implement
;;; this interface
(define Toy<%> 
  (interface (SWidget<%>)
    ;; this includes all the methods from SWidget<%>
    
    ;; toy-x : -> Integer
    ;; toy-y : -> Integer
    ;; GIVEN : no arguments
    ;; RETURNS: the x or y position of the center of the toy
    toy-x
    toy-y
    
    ;; toy-data : -> Integer
    ;; GIVEN : no arguments
    ;; RETURNS : some data related to the toy. The interpretation of this data 
    ;;           depends on the class of the toy.
    toy-data
    ))

;;; This is built upon the Swidget<%>. Classes aiming to manage the playground
;;; for toy factory should implement this interface
(define PlaygroundState<%>
  (interface (SWidget<%>)
    ;; this includes all the methods in SWidget<%>
    
    ;; target-x : -> Integer
    ;; target-y : -> Integer
    ;; GIVEN : no arguments
    ;; RETURNS : the x and y coordinates of the target
    target-x
    target-y
    
    ;; target-selected? : -> Boolean
    ;; GIVEN : no arguments
    ;; RETURNS : true if the target is the target selected? else false
    target-selected?
    
    ;; get-toys : -> ListOfToy<%>
    ;; GIVEN : no arguments
    ;; RETURNS : a list of toys in the scene
    get-toys
    ))

;;; This is built upon the SWidget<%>. It enumerates methods which could be used
;;; for object which acts as a target for adding new toys in the playground
(define Target<%> 
  (interface (SWidget<%>)
    ;; this includes all the methods in SWidget<%>
    
    ;; target-x : -> Integer
    ;; target-x : -> Integer
    ;; GIVEN : no arguments
    ;; RETURNS: the x or y position of the center of the target
    target-x
    target-y
    
    ;; target-selected? : -> Boolean
    ;; GIVEN : no arguments
    ;; RETURNS : true if the Target is selected else false
    target-selected?
    ))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; CLASSES:


;;; A Target is a (new Target% [x Integer]
;;;                            [y Integer]
;;;                            [selected? Boolean]
;;;                            [off-mx Integer]
;;;                            [off-my Integer])
;;;
;;; A Target represents a location on the canvas where new toys are created.  
;;; A Target is selectable and dragable. Target implements Target<%> interface.
(define Target%
  (class* object% (Target<%>)
    
    ;; the x and y coordinates of the target in graphics coordinate system
    (init-field x y)
    
    ;; true if the target is selected, otherwise false
    (init-field selected?)
    
    ;; x and y distance from x and y coordinates of the center of the target to 
    ;; x and y coordinates of the mouse click when mouse is inside target
    (init-field off-mx off-my)
    
    ;; radius of the target
    (field [TARGET-RADIUS 10])
    
    ;; the target image constant
    (field [TARGET-IMG (circle TARGET-RADIUS "outline" "blue")])
    
    (super-new)
    
    ;; METHODS FROM INTERFACE Target<%>
    ;; -------------------------------------------------------------------------
    ;; after-tick : -> Void
    ;; GIVEN : no arguments
    ;; EFFECT : updates this widget to the state it should have following a tick
    ;; DETAILS : target ignores after-tick
    ;; DESIGN STRATEGY : return some value
    (define/public (after-tick)
      -999)
    
    ;; after-key-event : KeyEvent -> Void
    ;; GIVEN : a key event
    ;; EFFECT : updates this widget to the state it should have following this 
    ;;          KeyEvent
    ;; DETAILS : target ignores after-key-event
    ;; DESIGN STRATEGY : return the some value
    (define/public (after-key-event kev)
      -999)
    
    ;; after-button-down : NonNegInt NonNegInt -> Void
    ;; GIVEN : x and y coordinates of mouse location
    ;; EFFECT : updates the state of this object to a state that should follow 
    ;;          the specified mouse event at the given location
    ;; DETAILS : target gets selected if mouse is inside the target
    ;; DESIGN STRATEGY : divide cases based on wether mouse is in target or not
    (define/public (after-button-down mx my)
      (if (in-target? mx my)
          (begin
            (set! selected? true)
            (set! off-mx (- mx x))
            (set! off-my (- my y)))
          -999))
    
    ;; after-button-up : NonNegInt NonNegInt -> Target<%>
    ;; GIVEN : x and y coordinates of mouse location
    ;; EFFECT : updates the state of this object to a state that should follow 
    ;;          the specified mouse event at the given location
    ;; DETAILS : a selected target is unselected after a button-up
    ;; DESIGN STRATEGY : update this object
    (define/public (after-button-up mx my)
      (begin
        (set! selected? false)
        (set! off-mx 0)
        (set! off-my 0)))
    
    ;; after-drag : NonNegInt NonNegInt -> Target<%>
    ;; GIVEN : x and y coordinates of mouse location
    ;; EFFECT : updates the state of this object to a state that should follow 
    ;;          the specified mouse event at the given location
    ;; DETAILS : If it is selected, move it so that the vector from the center 
    ;;           to the drag event is equal to (mx, my)
    ;; DESIGN STRATEGY : divide cases based on wether target is selected or not
    (define/public (after-drag mx my)
      (if selected?
          (begin
            (set! x (- mx off-mx))
            (set! y (- my off-my))
            (set! selected? true))
          -999))   
    
    ;; add-to-scene : Scene -> Scene
    ;; GIVEN : a scene
    ;; RETURNS : a scene like the given one, but with this object painted on it
    ;; DETAILS : places the target image on the scene
    ;; DESIGN STRATEGY : combine simpler functions
    (define/public (add-to-scene scene)
      (place-image TARGET-IMG x y scene))
    
    ;; target-x : -> Integer
    ;; GIVEN : no arguments
    ;; RETURNS : the x coordinate of this target
    ;; DESIGN STRATEGY : return a value from the object
    (define/public (target-x)
      x)
    
    ;; target-y : -> Integer
    ;; GIVEN : no arguments
    ;; RETURNS : the y coordinate of this target
    ;; DESIGN STRATEGY : return a value from the object
    (define/public (target-y)
      y)
    
    ;; target-selected? : -> Boolean
    ;; GIVEN : no arguments
    ;; RETURNS : true if this target is selected else false
    ;; DESIGN STRATEGY : return a value from the object
    (define/public (target-selected?)
      selected?)
    
    ;; METHODS USED IN LOCAL SCOPE :
    ;; -------------------------------------------------------------------------
    ;; in-target? : NonNegInt NonNegInt -> Boolean
    ;; GIVEN: a location of mouse on the canvas
    ;; RETURNS: true iff the location is inside this target.
    ;; DESIGN STRATEGY : combine simpler functions
    (define (in-target? other-x other-y)
      (<= (+ (sqr (- x other-x)) (sqr (- y other-y)))
          (sqr TARGET-RADIUS)))
    ))

;;; A Square is a (new Square% [center-x Integer]
;;;                            [center-y Integer]
;;;                            [selected? Boolean]
;;;                            [off-mx Integer]
;;;                            [off-my Integer]
;;;                            [speed Integer]
;;;
;;; A Square is a Toy that travels across the canvas at a given rate.
;;; Squares are selectable and dragable
(define Square%
  (class* object% (Toy<%>)
    
    ;; the x and y coordinates of the center of the Square
    (init-field center-x center-y)
    
    ;; true if the Square is selected, false otherwise
    (init-field selected?)
    
    ;; x and y distance from x and y coordinates of the center of the target to 
    ;; x and y coordinates of the mouse click when mouse is inside square
    (init-field off-mx off-my)
    
    ;; the speed of the Square in the x direction
    (init-field speed)
    
    ;; the length of a side of the Square
    (field [LEN 40])
    
    ;; half the length of a side
    (field [HALF-LEN (/ LEN 2)])
    
    ;; an Image of the Square
    (field [SQUARE-IMG (rectangle LEN LEN "outline" "red")])
    
    ;; the maximal x coordinate of the center of a Square on the canvas
    (field [BOUNDARY-X-MAX (- WIDTH HALF-LEN)])
    
    ;; the minimal x coordinate of the center of a Square on the canvas
    (field [BOUNDARY-X-MIN (+ 0 HALF-LEN)])
    
    (super-new)
    
    ;; METHODS FROM INTERFACE Toy<%>
    ;; -------------------------------------------------------------------------
    ;; after-tick : -> Void
    ;; GIVEN : no arguments
    ;; EFFECT : updates this object to a state it should follow after tick
    ;; DESIGN STRATEGY: Cases on selected?
    (define/public (after-tick)
      (if selected?
          -999
          (unselected-sqr-after-tick))) 
    
    ;; after-key-event : KeyEvent -> Void
    ;; GIVEN: a KeyEvent
    ;; EFFECT : updates this object to a state it should follow after key event
    ;; DETAILS: a Square ignores key events
    ;; DESIGN STRATEGY : return some value
    (define/public (after-key-event kev)
      -999)
    
    ;; after-button-down : NonNegInt NonNegInt -> Void
    ;; GIVEN: the x and y coordinates of a button-down event
    ;; EFFECT : updates this object to a state it should follow after button down
    ;; DETAILS : Square gets selected if mouse is inside the Square
    ;; DESIGN STRATEGY : Cases on whether the event is in the Square
    (define/public (after-button-down mx my)
      (if (in-sqr? mx my)
          (begin
            (set! selected? true)
            (set! off-mx (- mx center-x))
            (set! off-my (- my center-y)))
          -999))
    
    ;; after-button-up : NonNegInt NonNegInt -> Void
    ;; GIVEN :  x and y coordinates of mouse location
    ;; EFFECT : updates this object to a state it should follow after button up
    ;; DETAILS : a selected Square is unselected after a button-up
    ;; DESIGN STRATEGY : update this object
    (define/public (after-button-up mx my)
      (begin
        (set! selected? false)
        (set! off-mx 0)
        (set! off-my 0)))
    
    ;; after-drag : NonNegInt NonNegInt -> Void
    ;; GIVEN : x and y coordinates of mouse location
    ;; EFFECT : updates this object to a state which should follow after drag
    ;; DETAILS : If it is selected, move it so that the vector from the center to
    ;;           the drag event is equal to (mx, my)
    ;; DESIGN STRATEGY : Cases on whether the Square is selected.
    (define/public (after-drag mx my)
      (if selected?
          (begin
            (set! center-x (- mx off-mx))
            (set! center-y (- my off-my))
            (set! selected? true))
          -999))
    
    ;; add-to-scene : Scene -> Scene
    ;; GIVEN : a scene
    ;; RETURNS : a scene like the given one, but with this object painted on it
    ;; DETAILS : places the target image on the scene
    ;; DESIGN STRATEGY : combine simpler functions
    (define/public (add-to-scene scene)
      (place-image SQUARE-IMG center-x center-y scene))
    
    ;; toy-x : -> Integer
    ;; GIVEN: no arguments
    ;; RETURNS: the x location of the center of this Square
    ;; DESIGN STRATEGY : return a value from the object
    (define/public (toy-x)
      center-x)
    
    ;; toy-y : -> Integer
    ;; GIVEN: no arguments
    ;; RETURNS: the y location of the center of this Square in graphics
    ;;          coordinates
    ;; DESIGN STRATEGY : return a value from the object
    (define/public (toy-y)
      center-y)
    
    ;; toy-data : -> Integer
    ;; GIVEN: no arguments
    ;; RETURNS: the speed of this Square
    ;; DESIGN STRATEGY : return a value from the object
    (define/public (toy-data)
      speed)
    
    ;; METHODS USED IN LOCAL SCOPE :
    ;; -------------------------------------------------------------------------
    ;; unselected-sqr-after-tick : -> Void
    ;; GIVEN : no arguments
    ;; EFFECT : updates this object to a state it should follow after tick
    ;; DETAILS : if this Square will hit a boundary at the next tick then this
    ;;           Square will be placed at that boundary with the direction of
    ;;           its speed reversed. Otherwise the speed of this Square will
    ;;           be added to the current x coordinate of its center
    ;; DESIGN STRATEGY : create an instance of this class
    (define (unselected-sqr-after-tick)
      (local
        ((define updated-x (new-x))
         (define updated-speed (new-speed)))
        (begin
          (set! center-x updated-x)
          (set! speed updated-speed))))
    
    ;; new-x -> Integer
    ;; GIVEN: no arguments
    ;; RETURNS: the x coordinate of this Square after a tick of the clock
    ;; DETAILS: if this Square would touch a boundary at the next tick it is
    ;;          placed at that boundary, otherwise it's new location is it's
    ;;          current location plus its speed
    ;; DESIGN STRATEGY : divide into cases based on wall this square can hit
    (define (new-x)
      (cond
        [(>= (+ center-x speed) BOUNDARY-X-MAX) BOUNDARY-X-MAX]
        [(<= (+ center-x speed) BOUNDARY-X-MIN) BOUNDARY-X-MIN]
        [else (+ center-x speed)]))
    
    ;; new-speed -> Integer
    ;; GIVEN: no arguments
    ;; RETURNS: the speed of this Square after a tick of the clock
    ;; DETAILS: If this Square would touch a boundary at the next tick the 
    ;;          direction of its soeed is reversed, otherwise it is unaltered
    ;; DESIGN STRATEGY : divide into cases based on wall this square can hit
    (define (new-speed)
      (cond
        [(>= (+ center-x speed) BOUNDARY-X-MAX) (- 0 speed)]
        [(<= (+ center-x speed) BOUNDARY-X-MIN) (- 0 speed)]
        [else speed]))
    
    ;; in-sqr? : Integer Integer -> Boolean
    ;; GIVEN: a location on the canvas
    ;; RETURNS: true iff the location is inside this Square
    ;; DESIGN STRATEGY: combine simpler functions
    (define (in-sqr? other-x other-y)
      (and (<= (- center-x HALF-LEN)
               other-x
               (+ center-x HALF-LEN))
           (<= (- center-y HALF-LEN)
               other-y
               (+ center-y HALF-LEN))))
    
    ;; METHODS USED FOR TESTING :
    ;; -------------------------------------------------------------------------
    ;; for-test:selected? : -> Boolean
    ;; GIVEN: no arguments
    ;; RETURNS: true if this square is selected, false otherwise
    ;; DESIGN STRATEGY : return a value from this object
    (define/public (for-test:selected?) selected?)
    ))

;;; A Throbber is a (new Throbber% [center-x Integer]
;;;                                [center-y Integer]
;;;                                [selected? Boolean]
;;;                                [off-mx Integer]
;;;                                [off-my Integer]
;;;                                [speed Integer]
;;;                                [r Integer])
;;;
;;; A Throbber is a Toy whose radius gradually expands and contracts
;;; Trobbers are selecteable and draggable
(define Throbber%
  (class* object% (Toy<%>)
    
    ;; the x and y coordinates of the center of this Throbber
    (init-field center-x center-y)
    
    ;; true if this Throbber is selected, false otherwise
    (init-field selected?)
    
    ;; x and y distance from x and y coordinates of the center of this Throbber
    ;; to the x and y coordinates of the mouse click when mouse is inside
    ;; Throbber
    (init-field off-mx off-my)
    
    ;; the radius of this Throbber
    (init-field r)
    
    ;; the rate at which this Throbber's radius is changing
    (init-field speed)
    
    (super-new)
    
    ;; METHODS FROM INTERFACE Toy<%>
    ;; -------------------------------------------------------------------------
    ;; after-tick : -> Void
    ;; GIVEN : no arguments
    ;; EFFECT : updates this object to a state it should follow after a tick
    ;; DETAILS : at each tick of the clock the radius of this Throbber will
    ;;           increase or decrease by one pixel
    ;; DESIGN STRATEGY : update this object
    (define/public (after-tick)
      (local
        ((define updated-speed (new-speed)))
        (begin
          (set! r (+ r updated-speed))
          (set! speed updated-speed))))
    
    ;; after-key-event : KeyEvent -> Void
    ;; GIVEN : a KeyEvent
    ;; EFFECT : updates this throbber to a state which should follow after given KeyEvent
    ;; DETAILS : a Throbber ignores key events
    ;; DESIGN STRATEGY : return some value
    (define/public (after-key-event kev)
      -999)      
    
    ;; after-button-down : Integer Integer -> Void
    ;; GIVEN : the x and y coordinates of a button-down event
    ;; EFFECT : updates this object to a state which should follow after button down
    ;; DETAILS : Throbber gets selected if mouse is inside the Throbber
    ;; DESIGN STRATEGY: Cases on whether the event is in the Throbber
    (define/public (after-button-down mx my)
      (if (in-throbber? mx my)
          (begin
            (set! selected? true)
            (set! off-mx (- mx center-x))
            (set! off-my (- my center-y)))
          -999))
    
    ;; after-button-up : Integer Integer -> Void
    ;; GIVEN : the x and y coordinates of a button-up event
    ;; EFFECT : updates this object to a state which should follow button up
    ;; DETAILS : If the Throbber is selected, then unselect it
    ;; DESIGN STRATEGY : updates this object
    (define/public (after-button-up mx my)
      (begin
        (set! selected? false)
        (set! off-mx 0)
        (set! off-my 0)))  
    
    ;; after-drag : Integer Integer -> Void
    ;; GIVEN : the x and y coordinates of a drag event
    ;; EFFECT : updates this object to a state which should follow drag
    ;; DETAILS : if this Throbber is selected, move it so that the vector from
    ;;           the center to the drag event is equal to (mx, my)
    ;; DESIGN STRATEGY: Cases on whether the Throbber is selected.
    (define/public (after-drag mx my)
      (if selected?
          (begin
            (set! center-x (- mx off-mx))
            (set! center-y (- my off-my))
            (set! selected? true))
          -999))
    
    ;; add-to-scene : Scene -> Scene
    ;; GIVEN : a scene
    ;; RETURNS : a scene like the given one, but with this object painted on it
    ;; DETAILS : places the throbber image on the scene
    ;; DESIGN STRATEGY : combine simpler functions
    (define/public (add-to-scene scene)
      (place-image (get-throbber-image) center-x center-y scene))
    
    ;; toy-x : -> Integer
    ;; GIVEN : no arguments
    ;; RETURNS : the x coordinate of the center of this Throbber
    ;; DESIGN STRATEGY : return a value from this object
    (define/public (toy-x) center-x)
    
    ;; toy-y : -> Integer
    ;; GIVEN: no arguments
    ;; RETURNS: the y coordinate of the center of this Throbber
    ;; DESIGN STRATEGY : return a value from this object
    (define/public (toy-y) center-y)
    
    ;; toy-data : -> Integer
    ;; GIVEN: no arguments
    ;; RETURNS: the current radius of this Throbber
    ;; DESIGN STRATEGY : return a value from this object
    (define/public (toy-data) r)
    
    ;; in-throbber? : Integer Integer -> Boolean
    ;; GIVEN: a location on the canvas
    ;; RETURNS: true iff the location is inside this Throbber
    ;; DESIGN STRATEGY: combine simpler functions
    (define (in-throbber? other-x other-y)
      (<= (+ (sqr (- center-x other-x)) (sqr (- center-y other-y)))
          (sqr r)))
    
    ;; new-speed : -> Integer
    ;; GIVEN: no arguments
    ;; RETURNS: the rate at which the Throbbers radius should grow or shrink
    ;; DETAILS: the rate of change of the Throbbers radius will be positive
    ;;          up until it reaches a maximal value, then it will become
    ;;          negative until it reaches a minimal value
    ;; DESIGN STRATEGY : divide into cases based on value of radius
    (define (new-speed)
      (cond
        [(> (+ r 1) 20 ) -1]
        [(< (- r 1) 5 ) 1]
        [else speed]))
    
    ;; get-throbber-image : -> Image
    ;; GIVEN: no arguments
    ;; RETURNS: an image of this Throbber
    ;; DESIGN STRATEGY: combine simpler functions
    (define (get-throbber-image)
      (circle r "solid" "green"))
    
    ;; METHODS USED FOR TESTING :
    ;; -------------------------------------------------------------------------
    ;; for-test:selected? : -> Boolean
    ;; GIVEN: no arguments
    ;; RETURNS: true if this Throbber is selected, false otherwise
    ;; DESIGN STRATEGY : return a value from this object
    (define/public (for-test:selected?) selected?)
    ))

;;; A Clock is a (new Clock% [center-x Integer]
;;;                          [center-y Integer]
;;;                          [selected? Boolean]
;;;                          [off-mx Integer]
;;;                          [off-my Integer]
;;;                          [val Integer])
;;;
;;; A Clock is a Toy that displays the number of ticks since
;;; its creation. Clocks are selecteable and draggable
(define Clock%
  (class* object% (Toy<%>)
    
    ;; the x and y coordinates of the center of this Clock
    (init-field center-x center-y)
    
    ;; true if this clock is selected, false otherwise
    (init-field selected?)
    
    ;; x and y distance from x and y coordinates of the center of this Clock to 
    ;; x and y coordinates of the mouse click when mouse is inside Clock
    (init-field off-mx off-my)
    
    ;; the number of ticks since this Clock was created
    (init-field val)
    
    ;; the font size for the display of the Clock
    (field [SIZE 20])
    
    (super-new)
    
    ;; METHODS FROM INTERFACE Toy<%>
    ;; -------------------------------------------------------------------------
    ;; after-tick : -> Void
    ;; GIVEN : no arguments
    ;; EFFECT : updates this object to a state which should follow after tick
    ;; DETAILS : the Clock's val will be incremented by one
    ;; DESIGN STRATEGY : update this object
    (define/public (after-tick)
      (set! val (+ val 1)))
    
    ;; after-key-event : KeyEvent -> Void
    ;; GIVEN : a KeyEvent
    ;; EFFECT : updates this object to a state which should follow after this KeyEvent
    ;; DETAILS : a Clock ignores key events
    ;; DESIGN STRATEGY : return some value
    (define/public (after-key-event kev)
      -999)
    
    ;; after-button-down : Integer Integer -> Void
    ;; GIVEN : x and y coordinates of mouse location
    ;; EFFECT : updates this object to a state which should follow after button down
    ;; DETAILS : this Clock is slected if the mouse is inside the Clock when
    ;;           the button-down occurs
    ;; DESIGN STRATEGY: Cases on whether the event is in the Clock
    (define/public (after-button-down mx my)
      (if (in-clock? mx my)
          (begin
            (set! selected? true)
            (set! off-mx (- mx center-x))
            (set! off-my (- my center-y)))
          -999))
    
    ;; after-button-up : Integer Integer -> Void
    ;; GIVEN : x and y coordinates of mouse location
    ;; EFFECT : updates this object to a state which should follow after button up
    ;; DETAILS : a selected Clock is unselected after a button-up
    ;; DESIGN STRATEGY : update this object
    (define/public (after-button-up mx my)
      (begin
        (set! selected? false)
        (set! off-mx 0)
        (set! off-my 0)))  
    
    ;; after-drag : Integer Integer -> Void
    ;; GIVEN : x and y coordinates of mouse location
    ;; EFFECT : updates this object to a state which should follow drag
    ;; DETAILS: if this Clock is selected, move it so that the vector
    ;;          from the center to the drag event is equal to (mx, my)
    ;; DESIGN STRATEGY: cases on whether the Clock is selected.
    (define/public (after-drag mx my)
      (if selected?
          (begin
            (set! center-x (- mx off-mx))
            (set! center-y (- my off-my))
            (set! selected? true))
          -999))
    
    ;; add-to-scene : Scene -> Scene
    ;; GIVEN : a scene
    ;; RETURNS : a scene like the given one, but with this object painted on it
    ;; DETAILS : places the Clock image on the scene
    ;; DESIGN STRATEGY : combine simpler functions
    (define/public (add-to-scene scene)
      (place-image (get-clock-image) center-x center-y scene))
    
    ;; toy-x : -> Integer
    ;; GIVEN: no arguments
    ;; RETURNS: the x coordinate of the center of this Clock
    ;; DESIGN STRATEGY : return a value from this object
    (define/public (toy-x) center-x)
    
    ;; toy-y : -> Integer
    ;; GIVEN: no arguments
    ;; RETURNS: the y coordinate of the center of this Clock
    ;; DESIGN STRATEGY : return a value from this object
    (define/public (toy-y) center-y)
    
    ;; toy-data : -> Integer
    ;; GIVEN: no arguments
    ;; RETURNS: the current val of this Clock
    ;; DESIGN STRATEGY : return a value from this object
    (define/public (toy-data) val)
    
    ;; METHODS USED IN LOCAL SCOPE :
    ;; -------------------------------------------------------------------------
    ;; in-clock? : Integer Integer -> Boolean
    ;; GIVEN: a location of a mouse on the canvas
    ;; RETURNS: true iff the location is inside this Clock
    ;; DESIGN STRATEGY: combine simpler functions
    (define (in-clock? other-x other-y)
      (local
        ((define clk (get-clock-image))
         (define clk-w (image-width clk))
         (define clk-h (image-height clk)))
        (and (<= (- center-x (/ clk-w 2))
                 other-x
                 (+ center-x (/ clk-w 2)))
             (<= (- center-y (/ clk-h 2))
                 other-y
                 (+ center-y (/ clk-h 2))))))
    
    ;; get-clock-image : -> Image
    ;; GIVEN: no arguments
    ;; RETURNS: an Image of this Clock
    ;; STRATEGY: combine simpler functions
    (define (get-clock-image)
      (text (number->string val) SIZE "black"))
    
    ;; METHODS USED FOR TESTING :
    ;; -------------------------------------------------------------------------
    ;; for-test:selected? : -> Boolean
    ;; GIVEN: no arguments
    ;; RETURNS: true if this Clock is selected, false otherwise
    ;; DESIGN STRATEGY : return a value from this objectc
    (define/public (for-test:selected?) selected?)
    ))

;;; A Football is a (new Football% [center-x Integer]
;;;                                [center-y Integer]
;;;                                [selected? Boolean]
;;;                                [off-mx Integer]
;;;                                [off-my Integer]
;;;                                [size NonNegInt])
;;;
;;; A Football is a Toy that represents a Tom Brady Deflatable Football(TM)
;;; shrinking to size zero
(define Football%
  (class* object% (Toy<%>)
    
    ;; x and y coordinates of the center of the football
    (init-field center-x center-y)
    
    ;; true if the football is selected else false
    (init-field selected?)
    
    ;; x and y distance from x and y coordinates of the center of this Throbber
    ;; to the x and y coordinates of the mouse click when mouse is inside
    ;; Throbber
    (init-field off-mx off-my)
    
    ;; represents the current size of football. The size starts from 100 and
    ;; gradually decreses towards 0
    (init-field size)
    
    ;; image for football
    (define FOOTBALL-IMAGE (bitmap "football-clipart-14.png"))
    
    (super-new)
    
    ;; METHODS FROM INTERFACE Toy<%>
    ;; -------------------------------------------------------------------------
    ;; after-tick : -> Void
    ;; GIVEN : no arguments
    ;; EFFECT : updates this object to a state which should follow after a tick
    ;; DESIGN STRATEGY : update this object
    (define/public (after-tick)
      (set! size (get-new-size)))
    
    ;; after-key-event : KeyEvent -> Void
    ;; GIVEN : a key event
    ;; EFFECT : updates this object to a state which should follow this KeyEvent
    ;; DETAILS : Football ignores KeyEvents
    ;; DESIGN STRATEGY : return some value
    (define/public (after-key-event kev)
      -999)      
    
    ;; after-button-down : NonNegInt NonNegInt -> Void
    ;; GIVEN : x and y coordinates of mouse location
    ;; EFFECT : updates this object to a state which should follow after button down
    ;; DETAILS : when the event happens inside football, the football gets selected
    ;; STRATEGY : cases on whether the event is in the football
    (define/public (after-button-down mx my)
      (if (in-football? mx my)
          (begin
            (set! selected? true)
            (set! off-mx (- mx center-x))
            (set! off-my (- my center-y)))
          -999))
    
    ;; after-button-up : NonNegInt NonNegInt -> Void
    ;; GIVEN : x and y coordinates of mouse location
    ;; EFFECT : updates this object to a state which should follow after button up
    ;; DETAILS : the football gets unselected
    ;; STRATEGY : update this object
    (define/public (after-button-up mx my)
      (begin
        (set! selected? false)
        (set! off-mx 0)
        (set! off-my 0)))
    
    ;; after-drag : NonNegInt NonNegInt -> Void
    ;; GIVEN : x and y coordinates of mouse location
    ;; EFFECT : updates this object to a state which should follow after drag
    ;; DETAILS : If it is selected, move it so that the vector from the center to
    ;;           the drag event is equal to (mx, my)
    ;; STRATEGY: Cases on whether the football is selected.
    (define/public (after-drag mx my)
      (if selected?
          (begin
            (set! center-x (- mx off-mx))
            (set! center-y (- my off-my))
            (set! selected? true))
          -999))
    
    ;; add-to-scene : Scene -> Scene
    ;; GIVEN : a scene
    ;; RETURNS : a scene like the given one, but with this object painted on it
    ;; DESIGN STRATEGY : combine simpler functions
    (define/public (add-to-scene scene)
      (place-image (get-football-image) center-x center-y scene))
    
    ;; toy-x : -> Integer
    ;; GIVEN : no arguments
    ;; RETURNS : x value of the center of the football
    ;; DESIGN STRATEGY : return a value from the object
    (define/public (toy-x) center-x)
    
    
    ;; toy-y : -> Integer
    ;; GIVEN : no arguments
    ;; RETURNS : y value of the center of the football
    ;; DESIGN STRATEGY : return a value from the object
    (define/public (toy-y) center-y)
    
    ;; toy-data : -> Boolean
    ;; GIVEN : no arguments
    ;; RETURNS : size of the football
    ;; DESIGN STRATEGY : return a value from the object
    (define/public (toy-data) size)
    
    ;; METHODS USED IN LOCAL SCOPE :
    ;; -------------------------------------------------------------------------
    ;; get-new-size : -> PosInt
    ;; GIVEN : no arguments
    ;; RETURNS : a valid size which is gradually decresing until 1
    ;; DESIGN STRATEGY : divide cases on size
    (define (get-new-size)
      (if (= size 1)
          1
          (- size 1)))
    
    ;; in-target? : Integer Integer -> Boolean
    ;; GIVEN: a location on the canvas
    ;; RETURNS: true iff the location is inside this target.
    ;; DESIGN STRATEGY : combine simpler functions
    (define (in-football? m-x m-y)
      (<= (+ (sqr (- center-x m-x)) (sqr (- center-y m-y)))
          (sqr size)))
    
    ;; get-football-image : -> Image
    ;; GIVEN : no arguments
    ;; RETURNS : a scaled image of the football
    ;; DESIGN STRATEGY : combine simpler functions
    (define (get-football-image)
      (scale (/ size 14) FOOTBALL-IMAGE))
    
    ;; METHODS USED FOR TESTING :
    ;; -------------------------------------------------------------------------
    ;; for-test:selected? : -> Boolean
    ;; GIVEN : no arguments
    ;; RETURNS : true if the football is selected else false
    ;; DESIGN STRATEGY : return a value from this object
    (define/public (for-test:selected?) selected?)
    ))


;;; A PlaygroundState is a (new PlaygroundState% [sqr-speed Integer]
;;;                                              [toys ListOfToy<%>]
;;;                                              [target Target<%>])
;;;
;;; A PlaygroundState represents the current state of the toy factory and all the
;;; toys in it
(define PlaygroundState%
  (class* object% (PlaygroundState<%>)
    
    ;; the speed of all Square Toys in the world
    (init-field sqr-speed)
    
    ;; a ListOfToys in the world
    (init-field [toys empty])
    
    ;; the PlaygroundState's target where new toys are placed
    (init-field [target (new-target)])
    
    (super-new)
    
    ;; METHODS FROM INTERFACE PlaygroundState<%> :
    ;; -------------------------------------------------------------------------
    ;; after-tick : -> Void
    ;; GIVEN : no arguments
    ;; EFFECT : updates this object to a state it should follow after tick
    ;; DESIGN STRATEGY : call a more general function process-widgets
    (define/public (after-tick)
      (process-widgets
       (lambda (obj) (send obj after-tick))))
    
    ;; after-button-down : Integer Integer -> Void
    ;; GIVEN: a location
    ;; EFFECT: updates this widget to the state it should have following the
    ;;         button up mouse event at the given location
    ;; DESIGN STRATEGY : call a more general function process-widgets
    (define/public (after-button-down mx my)
      (process-widgets
       (lambda (obj) (send obj after-button-down mx my))))
    
    ;; after-button-up : Integer Integer -> Void
    ;; GIVEN: a location
    ;; EFFECT: updates this widget to the state it should have following the
    ;;         button down at the given location
    ;; DESIGN STRATEGY : call a more general function process-widgets
    (define/public (after-button-up mx my)
      (process-widgets
       (lambda (obj) (send obj after-button-up mx my))))
    
    ;; after-drag : Integer Integer -> Void
    ;; GIVEN: a location
    ;; EFFECT: updates this widget to the state it should have following the
    ;;         drag mouse event at the given location
    ;; DESIGN STRATEGY : call a more general function process-widgets
    (define/public (after-drag mx my)
      (process-widgets
       (lambda (obj) (send obj after-drag mx my))))
    
    ;; after-key-event : KeyEvent -> Void
    ;; GIVEN : a key event
    ;; EFFECT : updates this object to a state it should follow after this KeyEvent
    ;; DESIGN STRATEGY: Cases on kev   
    (define/public (after-key-event kev)
      (cond
        [(key=? kev SQUARE-KEY)
         (local
           ((define toy (make-square-toy (target-x) (target-y) sqr-speed)))
           (add-this-toy-in-playground toy))]
        [(key=? kev THROBBER-KEY)
         (local
           ((define toy (make-throbber (target-x) (target-y))))
           (add-this-toy-in-playground toy))]
        [(key=? kev CLOCK-KEY)
         (local
           ((define toy (make-clock (target-x) (target-y))))
           (add-this-toy-in-playground toy))]
        [(key=? kev FOOTBALL-KEY)
         (local
           ((define toy (make-football (target-x) (target-y))))
           (add-this-toy-in-playground toy))]
        [else -999]))
    
    ;; add-to-scene : Scene -> Scene
    ;; GIVEN : a scene on which this playground is to be painted
    ;; RETURNS : a scene that depicts this World
    ;; DESIGN STRATEGY : use HOF foldr on the toys and target in this PlaygroundState
    (define/public (add-to-scene scene)
      (foldr
       (lambda (obj scene)
         ;; Toy<%> Image -> Image
         (send obj add-to-scene scene))
       scene
       (cons target toys)))
    
    ;; target-x : -> Integer
    ;; GIVEN : no arguments
    ;; RETURNS : the x coordinate of the target
    ;; DESIGN STRATEGY : combine simpler function
    (define/public (target-x)
      (send target target-x))
    
    ;; target-y : -> Integer
    ;; GIVEN : no arguments
    ;; RETURNS : the y coordinate of the target
    ;; DESIGN STRATEGY : combine simpler function
    (define/public (target-y)
      (send target target-y))
    
    ;; target-selected? : -> Boolean
    ;; GIVEN : no arguments
    ;; RETURNS : true if the target is selected else false
    ;; DESIGN STRATEGY : combine simpler function
    (define/public (target-selected?)
      (send target target-selected?))
    
    ;; get-toys : -> ListOfToy<%>
    ;; GIVEN : no arguments
    ;; RETURNS : a ListOfToy in current world
    ;; DESIGN STRATEGY : return a value from the object
    (define/public (get-toys)
      toys)
    
    ;; process-widgets : (SWidget<%> -> Void) -> Void
    ;; GIVEN : a function to be operated on the list of SWidget<%> objects
    ;; EFFECT : updates all the object to a state they should be in after fn is
    ;;          operated on them
    ;; DESIGN STRATEGY : 
    (define (process-widgets fn)
      (for-each fn (cons target toys)))
    
    ;; add-this-toy-in-playground : SWidget<%> -> Void
    ;; GIVEN : a toy to be added in the playground
    ;; EFFECT : updates the list of toys in playground by adding new toy
    ;; DESIGN STRATEGY : update this object
    (define (add-this-toy-in-playground toy)
      (set! toys (cons toy toys)))
    ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; FUNCTIONS :

;;; new-target : -> Target<%>
;;; GIVEN : no arguments
;;; RETURNS : an instance on Target% class
;;; Example : (new-target) = test-img-target
;;; DESIGN STRATEGY : create an instance of Target% class
(define (new-target)
  (new Target%
       [x CANVAS-CENTER-X]
       [y CANVAS-CENTER-Y]
       [selected? false]
       [off-mx 0]
       [off-my 0]))

;;; TESTS :
;;; Tested in the central testing



;;; make-square-toy : PosInt PosInt PosInt -> Toy<%>
;;; GIVEN : x and y position, and a speed
;;; RETURNS : an object representing a square toy at the given position,
;;;          travelling right at the given speed.
;;; EXAMPLES : (make-square-toy CANVAS-CENTER-X CANVAS-CENTER-Y 10) = test-sqr
;;; DESIGN STRATEGY : create an instance of Square% class
(define (make-square-toy tar-x tar-y sqr-speed)
  (new Square%
       [center-x tar-x]
       [center-y tar-y]
       [selected? false]
       [off-mx 0]
       [off-my 0]
       [speed sqr-speed]))

;;; TESTS :
;;; Tested in the central testing



;;; make-throbber : PosInt PosInt -> Toy<%>
;;; GIVEN : x and y position
;;; RETURNS : an object representing a throbber at the given position
;;; EXAMPLES : (make-throbber CANVAS-CENTER-X CANVAS-CENTER-Y) = test-throbber
;;; DESIGN STRATEGY : create an instance of Throbber% class
(define (make-throbber tar-x tar-y)
  (new Throbber%
       [center-x tar-x]
       [center-y tar-y]
       [selected? false]
       [off-mx 0]
       [off-my 0]
       [r INITIAL-THROBBER-SIZE]
       [speed 1]))

;;; TESTS :
;;; Tested in the central testing



;;; make-clock : PosInt PostInt -> Toy<%>
;;; GIVEN : x and y position
;;; RETURNS : an object representing a clock at the given position
;;; EXAMPLES : (make-clock CANVAS-CENTER-X CANVAS-CENTER-Y) = test-clock
;;; DESIGN STRATEGY : create an instance of Clock% class
(define (make-clock tar-x tar-y)
  (new Clock%
       [center-x tar-x]
       [center-y tar-y]
       [selected? false]
       [off-mx 0]
       [off-my 0]
       [val 0]))

;;; TESTS :
;;; Tested in the central testing



;;; make-football : PosInt PostInt -> Toy<%>
;;; GIVEN : x and y position
;;; RETURNS : an object representing a football at the given position
;;; EXAMPLES : (make-football CANVAS-CENTER-X CANVAS-CENTER-Y) = test-football
;;; DESIGN STRATEGY : create an instance of Football% class
(define (make-football tar-x tar-y)
  (new Football%
       [center-x tar-x]
       [center-y tar-y]
       [selected? false]
       [off-mx 0]
       [off-my 0]
       [size INITIAL-FOOTBALL-SIZE]))

;;; TESTS :
;;; Tested in the central testing



;;; make-playground : PosInt -> PlaygroundState<%>
;;; GIVEN : the speed at which square toys in world should move
;;; RETURNS : a world with a target, but no toys, and in which any
;;;           square toys created in the future will travel at the given speed 
;;;           (in pixels/tick)
(define (make-playground sqr-speed)
  (new PlaygroundState%
       [sqr-speed sqr-speed]))



;;; run : PosNum PosInt -> Void
;;; GIVEN: a frame rate (in seconds/tick) and a square-speed (in pixels/tick),
;;;        creates and runs a world in which square toys travel at the given
;;;        speed.
;;; EFFECT : runs the simulation of world
(define (run frame-rate sqr-speed)
  (local
    ((define world (make-world WIDTH HEIGHT))
     (define playground (make-playground sqr-speed)))
    (begin
      (send world add-stateful-widget playground)
      (send world run frame-rate))))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; TESTS :

;;; tests for Square :
(begin-for-test
  (local
    ((define SQ (make-square-toy 250 300 10))
     (define SQ1 (make-square-toy 470 300 50))
     (define SQ2 (make-square-toy 30 300 -50))
     (define PG (make-playground 10)))
    
    (check-equal? (send SQ toy-x)
                  250
                  "toy should initialize at center")
    (check-equal? (send SQ toy-y)
                  300
                  "toy should initialize at center")
    
    (send SQ after-tick)
    (send PG after-key-event "s")
    (send PG after-tick)
    
    (check-equal? (send (first (send PG get-toys)) toy-x)
                  (send SQ toy-x)
                  "toy in playground should match which square in test")
    (check-equal? (send SQ toy-x)
                  260
                  "after tick toy should move by the given speed")
    (check-equal? (send SQ toy-data)
                  10
                  "as it's not bouncing, there is no change in speed")
    
    (send SQ1 after-tick)
    (send SQ2 after-tick)
    
    (check-equal? (send SQ1 toy-x)
                  480
                  "it's a bounce condition, square touches the boundary")
    (check-equal? (send SQ1 toy-data)
                  -50
                  "it's a bounce condition, square reverses it's speed")
    (check-equal? (send SQ2 toy-x)
                  20
                  "it's a bounce condition, square touches the boundary")
    (check-equal? (send SQ2 toy-data)
                  50
                  "it's a bounce condition, square reverses it's speed")))

(begin-for-test
  (local
    ((define SQ (make-square-toy 250 300 10))
     (define PG (make-playground 10)))
    
    (check-equal? (send PG after-key-event "q")
                  -999
                  "gets void indicating no change in state")
    (check-equal? (send SQ after-key-event "q")
                  -999
                  "gets void indicating no change in state")))

(begin-for-test
  (local
    ((define SQ (make-square-toy 250 300 10))
     (define PG (make-playground 10)))
    
    (send PG after-key-event "s")
    (send SQ after-button-down 260 310)
    (send PG after-button-down 260 310)
    
    (check-equal? (send SQ toy-x)
                  250
                  "toy doesn't changes it's co-ordinates")
    (check-equal? (send SQ toy-y)
                  300
                  "toy doesn't changes it's co-ordinates")
    (check-true (send SQ for-test:selected?)
                "toy gets selected")
    (check-true (send (first (send PG get-toys)) for-test:selected?)
                "toy in playground should match square in test")
    (check-equal? (send SQ after-tick)
                  -999
                  "gets void indicating no change in state")
    
    (send SQ after-drag 300 400)
    (send PG after-drag 300 400)
    
    (check-equal? (send SQ toy-x)
                  290
                  "toy gets draged keep the offsets constant")
    (check-equal? (send SQ toy-y) 390
                  "toy gets draged keep the offsets constant")
    (check-true (send SQ for-test:selected?)
                "toy is still selected")
    (check-equal? (send (first (send PG get-toys)) toy-x)
                  290
                  "toy in playground should match toy in tests")
    (check-equal? (send (first (send PG get-toys)) toy-y)
                  390
                  "toy in playground should match toy in tests")
    (check-true (send (first (send PG get-toys)) for-test:selected?)
                "toy in playground should match toy in tests")
    
    (send SQ after-button-up 300 400)
    (send PG after-button-up 300 400)
    
    (check-equal? (send SQ toy-x)
                  290
                  "toy should not change it's coordinates")
    (check-equal? (send SQ toy-y)
                  390
                  "toy should not change it's coordinates")
    (check-false (send SQ for-test:selected?)
                 "gets deselected")
    (check-false (send (first (send PG get-toys)) for-test:selected?)
                 "gets deselected")
    
    (check-equal? (send SQ after-button-down 1 1)
                  -999
                  "gets void")
    (check-equal? (send SQ after-drag 1 1)
                  -999
                  "gets void")))

(begin-for-test
  (local
    ((define SQ (make-square-toy 250 300 10))
     (define PG (make-playground 10))
     (define SQ-IMAGE (square 40 "outline" "red"))
     (define PG-IMAGE (place-image SQ-IMAGE 250 300 EMPTY-CANVAS)))
    (send PG after-key-event "s")
    (check-equal? (send SQ add-to-scene EMPTY-CANVAS)
                  PG-IMAGE
                  "images should by same")))

;;; tests for Throbber :
(begin-for-test
  (local
    ((define TH (make-throbber 250 300))
     (define TH1 (new Throbber%
                      [center-x 250]
                      [center-y 300]
                      [selected? false]
                      [off-mx 0]
                      [off-my 0]
                      [r 20]
                      [speed 1]))
     (define TH2 (new Throbber%
                      [center-x 250]
                      [center-y 300]
                      [selected? false]
                      [off-mx 0]
                      [off-my 0]
                      [r 5]
                      [speed -1])))
    (check-equal? (send TH toy-x)
                  250
                  "toy should initialize at center")
    (check-equal? (send TH toy-y)
                  300
                  "toy should initialize at center")
    
    (send TH after-tick)
    (send TH after-tick)
    
    (check-equal? (send TH toy-data)
                  7
                  "after 2 ticks radius should be 2 more then initial")
    
    (send TH1 after-tick)
    (send TH2 after-tick)
    
    (check-equal? (send TH1 toy-data)
                  19
                  "size starts decresing after reaching 20")
    (check-equal? (send TH2 toy-data)
                  6
                  "size starts increasing after reaching 5")))

(begin-for-test
  (local
    ((define TH (make-throbber 250 300)))
    
    (check-equal? (send TH after-key-event "q")
                  -999
                  "gets void indicating no change in state")))

(begin-for-test
  (local
    ((define TH (make-throbber 250 300)))
    
    (send TH after-button-down 251 301)
    
    (check-equal? (send TH toy-x)
                  250
                  "toy doesn't changes it's co-ordinates")
    (check-equal? (send TH toy-y)
                  300
                  "toy doesn't changes it's co-ordinates")
    (check-true (send TH for-test:selected?)
                "toy gets selected")
    
    (send TH after-drag 300 400)
    
    (check-equal? (send TH toy-x)
                  299
                  "toy gets draged keep the offsets constant")
    (check-equal? (send TH toy-y)
                  399
                  "toy gets draged keep the offsets constant")
    (check-true (send TH for-test:selected?)
                  "gets selected")
    
    (send TH after-button-up 300 400)
    
    (check-equal? (send TH toy-x)
                  299
                  "toy should not change it's coordinates")
    (check-equal? (send TH toy-y)
                  399
                  "toy should not change it's coordinates")
    (check-false (send TH for-test:selected?)
                 "gets deselected")
    
    (check-equal? (send TH after-button-down 1 1)
                  -999
                  "gets void indicating no change in state")
    (check-equal? (send TH after-drag 1 1)
                  -999
                  "gets void indicating no change in state")))

(begin-for-test
  (local
    ((define TH (make-throbber 250 300))
     (define PG (make-playground 10))
     (define TH-IMAGE (circle 5 "solid" "green"))
     (define PG-IMAGE (place-image TH-IMAGE 250 300 EMPTY-CANVAS)))
    (send PG after-key-event "t")
    (check-equal? (send TH add-to-scene EMPTY-CANVAS)
                  PG-IMAGE
                  "images should by same")))

;;; tests for Clock :
(begin-for-test
  (local
    ((define CL (make-clock 250 300)))
    (check-equal? (send CL toy-x) 250)
    (check-equal? (send CL toy-y) 300)
    
    (send CL after-tick)
    (send CL after-tick)
    
    (check-equal? (send CL toy-data)
                  2
                  "after 2 ticks count should be 2 more then initial")))

(begin-for-test
  (local
    ((define CL (make-clock 250 300)))
    
    (check-equal? (send CL after-key-event "q")
                  -999
                  "gets void indicating no change in state")))

(begin-for-test
  (local
    ((define CL (make-clock 250 300)))
    
    (send CL after-button-down 251 301)
    
    (check-equal? (send CL toy-x)
                  250
                  "toy doesn't changes it's co-ordinates")
    (check-equal? (send CL toy-y)
                  300
                  "toy doesn't changes it's co-ordinates")
    (check-true (send CL for-test:selected?)
                "get selected")
    
    (send CL after-drag 300 400)
    
    (check-equal? (send CL toy-x)
                  299
                  "toy gets draged keep the offsets constant")
    (check-equal? (send CL toy-y)
                  399
                  "toy gets draged keep the offsets constant")
    (check-true (send CL for-test:selected?)
                "stays selected")
    
    (send CL after-button-up 300 400)
    
    (check-equal? (send CL toy-x)
                  299
                  "toy should not change it's coordinates")
    (check-equal? (send CL toy-y)
                  399
                  "toy should not change it's coordinates")
    (check-false (send CL for-test:selected?)
                 "get deslected")
    
    (check-equal? (send CL after-button-down 1 1)
                  -999
                  "gets void indicating no change in state")
    (check-equal? (send CL after-drag 1 1)
                  -999
                  "gets void indicating no change in state")))

(begin-for-test
  (local
    ((define CL (make-clock 250 300))
     (define PG (make-playground 10))
     (define CL-IMAGE (text (number->string 0) 20 "black"))
     (define PG-IMAGE (place-image CL-IMAGE 250 300 EMPTY-CANVAS)))
    (send PG after-key-event "w")
    (check-equal? (send CL add-to-scene EMPTY-CANVAS)
                  PG-IMAGE
                  "images should by same")))

;;; test for Football :
(begin-for-test
  (local
    ((define FB (make-football 250 300))
     (define FB1 (new Football%
                      [center-x 250]
                      [center-y 300]
                      [selected? false]
                      [off-mx 0]
                      [off-my 0]
                      [size 1])))
    (check-equal? (send FB toy-x) 250)
    (check-equal? (send FB toy-y) 300)
    
    (send FB after-tick)
    (send FB after-tick)
    
    (check-equal? (send FB toy-data)
                  28
                  "after 2 tick the size should be less by 2")
    
    (send FB1 after-tick)
    
    (check-equal? (send FB1 toy-data)
                  1
                  "once it reaches 1 it should remain constant")))

(begin-for-test
  (local
    ((define FB (make-football 250 300)))
    
    (check-equal? (send FB after-key-event "q") -999)))

(begin-for-test
  (local
    ((define FB (make-football 250 300)))
    
    (send FB after-button-down 251 301)
    
    (check-equal? (send FB toy-x)
                  250
                  "toy doesn't changes it's co-ordinates")
    (check-equal? (send FB toy-y)
                  300
                  "toy doesn't changes it's co-ordinates")
    (check-true (send FB for-test:selected?)
                "get selected")
    
    (send FB after-drag 300 400)
    
    (check-equal? (send FB toy-x)
                  299
                  "toy gets draged keep the offsets constant")
    (check-equal? (send FB toy-y)
                  399
                  "toy gets draged keep the offsets constant")
    (check-true (send FB for-test:selected?)
                "stays selected")
    
    (send FB after-button-up 300 400)
    
    (check-equal? (send FB toy-x)
                  299
                  "toy should not change it's coordinates")
    (check-equal? (send FB toy-y)
                  399
                  "toy should not change it's coordinates")
    (check-false (send FB for-test:selected?)
                 "get deselcted")
    
    (check-equal? (send FB after-button-down 1 1)
                  -999
                  "gets void indicating no change in state")
    (check-equal? (send FB after-drag 1 1)
                  -999
                  "gets void indicating no change in state")))

(begin-for-test
  (local
    ((define FB (make-football 250 300))
     (define PG (make-playground 10))
     (define FB-IMAGE (scale (/ 30 14) (bitmap "football-clipart-14.png")))
     (define PG-IMAGE (place-image FB-IMAGE 250 300 EMPTY-CANVAS)))
    (send PG after-key-event "f")
    (check-equal? (send FB add-to-scene EMPTY-CANVAS)
                  PG-IMAGE
                  "images should by same")))

;;; tests for Target :
(begin-for-test
  (local
    ((define TG (new-target)))
    
    (check-equal? (send TG target-x)
                  250
                  "toy should initialize at center")
    (check-equal? (send TG target-y)
                  300
                  "toy should initialize at center")
    (check-equal? (send TG after-tick)
                  -999
                  "gets void indicating no change in state")))

(begin-for-test
  (local
    ((define TG (new-target)))
    
    (check-equal? (send TG after-key-event "q")
                  -999
                  "gets void indicating no change in state")))

(begin-for-test
  (local
    ((define TG (new-target))
     (define PG (make-playground 10)))
    
    (send TG after-button-down 251 301)
    (send PG after-button-down 251 301)
    
    (check-equal? (send TG target-x)
                  250
                  "toy should initialize at center")
    (check-equal? (send TG target-y)
                  300
                  "toy should initialize at center")
    (check-true (send TG target-selected?)
                "get selected")
    (check-true (send PG target-selected?)
                "get selected")
    
    (send TG after-drag 300 400)
    
    (check-equal? (send TG target-x)
                  299
                  "toy gets draged keep the offsets constant")
    (check-equal? (send TG target-y)
                  399
                  "toy gets draged keep the offsets constant")
    (check-true (send TG target-selected?)
                "gets selected")
    
    (send TG after-button-up 300 400)
    
    (check-equal? (send TG target-x)
                  299
                  "toy should not change it's coordinates")
    (check-equal? (send TG target-y)
                  399
                  "toy should not change it's coordinates")
    (check-false (send TG target-selected?)
                 "gets deselected")
    
    (check-equal? (send TG after-button-down 1 1)
                  -999
                  "gets void indicating no change in state")
    (check-equal? (send TG after-drag 1 1)
                  -999
                  "gets void indicating no change in state")))

(begin-for-test
  (local
    ((define TG (make-football 250 300))
     (define PG (make-playground 10))
     (define TG-IMAGE (circle 10 "outline" "blue"))
     (define PG-IMAGE (place-image TG-IMAGE 250 300 EMPTY-CANVAS)))
    (check-equal? (send PG add-to-scene EMPTY-CANVAS)
                  PG-IMAGE
                  "images should by same")))