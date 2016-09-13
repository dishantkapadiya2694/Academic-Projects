#lang racket
(require rackunit)
(require "extras.rkt")
(require 2htdp/universe)   
(require 2htdp/image)

(provide make-world
         run
         make-square-toy
         make-throbber
         make-clock
         make-football
         Widget<%>
         WorldState<%>
         Toy<%>
         PlaygroundState<%>
         Target<%>)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

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
(define FOOTBALL-IMAGE (bitmap "football-clipart-14.png"))
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
       (...(send (first (lot))...)
           (lot-fn (rest (lot))))]))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; INTERFACES :

;;; Widget<%> is used as a base for Toy<%> and Target<%> for this program. It
;;; enumerate various events which can happen at widget level when user interacts
;;; with the system
(define Widget<%>
  (interface ()
    
    ;; after-tick : -> Widget<%>
    ;; GIVEN : no arguments
    ;; RETURNS : the state of this object after the tick
    after-tick          
    
    ;; after-button-down : NonNegInt NonNegInt -> Widget<%>
    ;; after-button-up : NonNegInt NonNegInt -> Widget<%>
    ;; after-drag : NonNegInt NonNegInt -> Widget<%>
    ;; GIVEN : x and y coordinates of mouse location
    ;; RETURNS : the state of this object that should follow the specified mouse 
    ;;           event at the given location
    after-button-down
    after-button-up
    after-drag
    
    ;; after-key-event : KeyEvent -> Widget<%>
    ;; GIVEN : a key event
    ;; RETURNS : the state of this object that should follow the given key event
    after-key-event
    
    ;; add-to-scene : Scene -> Scene
    ;; GIVEN : a scene
    ;; RETURNS : a scene like the given one, but with this object painted on it
    add-to-scene
    ))

;;; WorldState<%> is used as a base for PlaygroundState<%> for this program. It
;;; enumerate various events which can happen at World level when user interacts
;;; with the system
(define WorldState<%>
  (interface ()
    
    ;; after-tick : -> WorldState<%>
    ;; GIVEN : no arguments
    ;; RETURNS : the state of the world at the next tick
    after-tick
    
    ;; after-mouse-event : NonNegInt NonNegInt MouseEvent -> WorldState<%>
    ;; GIVEN : x and y coordinate of mouse location and a MouseEvent
    ;; RETURNS : the state of the world that should follow the given mouse event
    ;;           at the given location
    after-mouse-event
    
    
    ;; after-key-event : KeyEvent -> WorldState<%>
    ;; GIVEN : a key event
    ;; RETURNS : the state of the world that should follow the given key event
    after-key-event
    
    ;; to-scene : -> Scene
    ;; GIVEN : no arguments
    ;; RETURNS : a scene that depicts this World
    to-scene
    ))

;;; PlaygroundState<%> is built upon the WorldState<%>. Class for World must
;;; implement this.
(define PlaygroundState<%>
  (interface (WorldState<%>)
    ;; this includes all the methods in WorldState<%>
    
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

;;; This is built upon the the Widget<%>. Every object in World must implement
;;; this interface
(define Toy<%> 
  (interface (Widget<%>)
    ;; this includes all the methods in Widget<%>
    
    ;; toy-x : -> Int
    ;; toy-y : -> Int
    ;; GIVEN : no arguments
    ;; RETURNS: the x or y position of the center of the toy
    toy-x
    toy-y
    
    ;; toy-data : -> Int
    ;; GIVEN : no arguments
    ;; RETURNS : some data related to the toy.  The interpretation of this data 
    ;;          depends on the class of the toy.
    ;;           (i) square   : it is the velocity of the square (rightward is
    ;;                          positive)
    ;;          (ii) throbber : it is the current radius of the throbber
    ;;         (iii) clock    : it is the current value of the clock
    ;;          (iv) football : it is the current size of the football (in
    ;;                          arbitrary units, bigger is more)
    toy-data
    ))

;;; This is built upon the the Widget<%>. This is implemented by the Target Class
(define Target<%> 
  (interface (Widget<%>)
    ;; this includes all the methods in Widget<%>
    
    ;; target-x : -> Int
    ;; target-x : -> Int
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

;;; CLASSES :

;;; A Target is a (new Target% [x Integer]
;;;                            [y Integer]
;;;                            [off-mx Integer]
;;;                            [off-my Integer]
;;;                            [selected? Boolean])
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
    ;; after-tick : -> Target<%>
    ;; GIVEN : no arguments
    ;; RETURNS : the state of this object after the tick
    ;; DETAILS : target ignores after-tick
    ;; DESIGN STRATEGY : return the same object
    (define/public (after-tick)
      this)
    
    ;; after-key-event : KeyEvent -> Target<%>
    ;; GIVEN : a key event
    ;; RETURNS : the state of this object that should follow the given key event
    ;; DETAILS : target ignores after-key-event
    ;; DESIGN STRATEGY : return the same object
    (define/public (after-key-event kev)
      this)
    
    ;; after-button-down : NonNegInt NonNegInt -> Target<%>
    ;; GIVEN : x and y coordinates of mouse location
    ;; RETURNS : the state of this object that should follow the specified mouse 
    ;;           event at the given location
    ;; DETAILS : target gets selected if mouse is inside the target
    ;; DESIGN STRATEGY : divide cases based on wether mouse is in target or not
    (define/public (after-button-down mx my)
      (if (in-target? mx my)
          (new Target%
               [x x][y y]
               [selected? true]
               [off-mx (- mx x)]
               [off-my (- my y)])
          this))
    
    ;; after-button-up : NonNegInt NonNegInt -> Target<%>
    ;; GIVEN : x and y coordinates of mouse location
    ;; RETURNS : the state of this object that should follow the specified mouse 
    ;;           event at the given location
    ;; DETAILS : a selected target is unselected after a button-up
    ;; DESIGN STRATEGY : create an instance of this class
    (define/public (after-button-up mx my)
      (new Target%
           [x x][y y]
           [selected? false]
           [off-mx 0]
           [off-my 0]))
    
    ;; after-drag : NonNegInt NonNegInt -> Target<%>
    ;; GIVEN : x and y coordinates of mouse location
    ;; RETURNS : the state of this object that should follow the specified mouse 
    ;;           event at the given location
    ;; DETAILS : If it is selected, move it so that the vector from the center 
    ;;           to the drag event is equal to (mx, my)
    ;; DESIGN STRATEGY : divide cases based on wether target is selected or not
    (define/public (after-drag mx my)
      (if selected?
          (new Target%
               [x (- mx off-mx)]
               [y (- my off-my)]
               [selected? true]
               [off-mx off-mx]
               [off-my off-my])
          this))   
    
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
    
    ;; METHODS USED FOR TESTING :
    ;; -------------------------------------------------------------------------
    ;; for-test:x : -> Integer
    ;; GIVEN : no arguments
    ;; RETURNS : value of x for this object
    ;; DESIGN STRATEGY : return a value from the object
    (define/public (for-test:x) x)
    
    ;; for-test:y : -> Integer
    ;; GIVEN : no arguments
    ;; RETURNS : value of y for this object
    ;; DESIGN STRATEGY : return a value from the object
    (define/public (for-test:y) y)
    
    ;; for-test:selected? : -> Boolean
    ;; GIVEN : no arguments
    ;; RETURNS : value of selected? for this object
    ;; DESIGN STRATEGY : return a value from the object
    (define/public (for-test:selected?) selected?)
    ))

;;; A WorldState is a (new WorldState% [target Target<%>]
;;;                                    [toys ListOfToy<%>]
;;;                                    [sqr-speed Integer]
;;;
;;; A WorldState represents the current state of the world and all the toys in it
(define WorldState%
  (class* object% (PlaygroundState<%>)
    
    ;; the WorldState's target where new toys are placed
    (init-field target)
    
    ;; a ListOfToys in the world
    (init-field toys)
    
    ;; the speed of all Square Toys in the world
    (init-field sqr-speed)
    
    (super-new)
    
    ;; METHODS FROM INTERFACE PlaygroundState<%> :
    ;; -------------------------------------------------------------------------
    ;; after-tick : -> PlaygroundState<%>
    ;; GIVEN : no arguments
    ;; RETURNS : the state of the world at the next tick
    ;; DESIGN STRATEGY : combine aimpler functions
    (define/public (after-tick)
      (create-world
       (send target after-tick)
       (map
        ;; Toy<%> -> Toy<%>
        (lambda (toy) (send toy after-tick))
        toys)
       sqr-speed))
    
    ;; after-mouse-event : NonNegInt NonNegInt MouseEvent -> PlaygroundState<%>
    ;; GIVEN : x and y coordinate of mouse location and a MouseEvent
    ;; RETURNS : the state of the world that should follow the given mouse event
    ;;           at the given location
    ;; DESIGN STRATGY: Cases on mev
    (define/public (after-mouse-event mx my mev)
      (cond
        [(mouse=? mev MOUSE-BUTTON-DOWN)
         (world-after-button-down mx my)]
        [(mouse=? mev MOUSE-BUTTON-DRAG)
         (world-after-drag mx my)]
        [(mouse=? mev MOUSE-BUTTON-UP)
         (world-after-button-up mx my)]
        [else this]))
    
    ;; after-key-event : KeyEvent -> PlaygroundState<%>
    ;; GIVEN : a key event
    ;; RETURNS : the state of the world that should follow the given key event
    ;; DESIGN STRATEGY: Cases on kev   
    (define/public (after-key-event kev)
      (cond
        [(key=? kev SQUARE-KEY)
         (world-after-square-key)]
        [(key=? kev THROBBER-KEY)
         (world-after-throbber-key)]
        [(key=? kev CLOCK-KEY)
         (world-after-clock-key)]
        [(key=? kev FOOTBALL-KEY)
         (world-after-football-key)]
        [else
         (world-after-other-key kev)]))
    
    ;; to-scene : -> Scene
    ;; GIVEN : no arguments
    ;; RETURNS : a scene that depicts this World
    ;; DESIGN STRATEGY : use HOF foldr on the toys in this WorldState
    (define/public (to-scene)
      (foldr
       (lambda (obj scene)
         ;; Toy<%> Image -> Image
         (send obj add-to-scene scene))
       EMPTY-CANVAS
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
    
    ;; METHODS USED IN LOCAL SCOPE :
    ;; -------------------------------------------------------------------------
    ;; world-after-button-down : NonNegInt NonNegInt -> PlaygroundState<%>
    ;; GIVEN: the location of a button-down MouseEvent
    ;; RETURNS: this WorldState after a button-down MouseEvent
    ;; DESIGN STRATEGY : combine simpler functions
    (define (world-after-button-down mx my)
      (create-world
       (send target after-button-down mx my)
       (map
        ;; Toy<%> -> Toy<%>
        (lambda (obj) (send obj after-button-down mx my))
        toys)
       sqr-speed))
    
    ;; world-after-button-up : NonNegInt NonNegInt -> PlaygroundState<%>
    ;; GIVEN: the location of a button-up MouseEvent
    ;; RETURNS: this WorldState after a button-up MouseEvent
    ;; DESIGN STRATEGY : combine simpler functions
    (define (world-after-button-up mx my)
      (create-world
       (send target after-button-up mx my)
       (map
        ;; Toy<%> -> Toy<%>
        (lambda (obj) (send obj after-button-up mx my))
        toys)
       sqr-speed))
    
    ;; world-after-drag : NonNegInt NonNegInt -> PlaygroundState<%>
    ;; GIVEN: the location of a drag MouseEvent
    ;; RETURNS: this WorldState after a drag MouseEvent
    ;; DESIGN STRATEGY : combine simpler functions
    (define (world-after-drag mx my)
      (create-world
       (send target after-drag mx my)
       (map
        ;; Toy<%> -> Toy<%>
        (lambda (obj) (send obj after-drag mx my))
        toys)
       sqr-speed))
    
    ;; world-after-square-key : -> PlaygroundState<%>
    ;; GIVEN : no arguments
    ;; RETURNS : the state of the world that should follow the square-key event
    ;; DESIGN STRATEGY : combine simpler functions
    (define (world-after-square-key)
      (create-world
       target
       (cons (make-square-toy (target-x) (target-y) sqr-speed) toys)
       sqr-speed))
    
    ;; world-after-throbber-key : -> PlaygroundState<%>
    ;; GIVEN : no arguments
    ;; RETURNS : the state of the world that should follow the throbber-key event
    ;; DESIGN STRATEGY : combine simpler functions
    (define (world-after-throbber-key)
      (create-world
       target
       (cons (make-throbber (target-x) (target-y)) toys)
       sqr-speed))
    
    ;; world-after-clock-key : -> PlaygroundState<%>
    ;; GIVEN : no arguments
    ;; RETURNS : the state of the world that should follow the clock-key event
    ;; DESIGN STRATEGY : combine simpler functions
    (define (world-after-clock-key)
      (create-world
       target
       (cons (make-clock (target-x) (target-y)) toys)
       sqr-speed))
    
    ;; world-after-football-key : -> PlaygroundState<%>
    ;; GIVEN : no arguments
    ;; RETURNS : the state of the world that should follow the football-key event
    ;; DESIGN STRATEGY : combine simpler functions
    (define (world-after-football-key)
      (create-world
       target
       (cons (make-football (target-x) (target-y)) toys)
       sqr-speed))
    
    ;; world-after-other-key : KeyEvent -> PlaygroundState<%>
    ;; GIVEN : KeyEvent
    ;; RETURNS : the state of the world that should follow the other key events
    ;; DESIGN STRATEGY : combine simpler functions
    (define (world-after-other-key kev)
      (create-world
       target
       (map
        ;; Toy<%> -> Toy<%>
        (lambda (obj) (send obj after-key-event kev))
        toys)
       sqr-speed))))
 
;;; A Square is a (new Square% [center-x Integer]
;;;                            [center-y Integer]
;;;                            [off-mx Integer]
;;;                            [off-my Integer]
;;;                            [selected? Boolean]
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
    ;; after-tick : Time -> Toy<%>
    ;; GIVEN: no arguments
    ;; RETURNS: A Square like this one, but as it should be after a tick
    ;;          a selected Square doesn't move.
    ;; DESIGN STRATEGY: Cases on selected?
    (define/public (after-tick)
      (if selected?
          this
          (unselected-sqr-after-tick))) 
    
    ;; after-key-event : KeyEvent -> Toy<%>
    ;; GIVEN: a KeyEvent
    ;; RETURNS: the state of this Square after the given KeyEvent
    ;; DETAILS: a Square ignores key events
    ;; DESIGN STRATEGY: return the same object
    (define/public (after-key-event kev)
      this)
    
    ;; after-button-down : NonNegInt NonNegInt -> Toy<%>
    ;; GIVEN: the x and y coordinates of a button-down event
    ;; RETURNS : the state of this Square that should follow the button-down
    ;;           event at the given location
    ;; DETAILS : Square gets selected if mouse is inside the Square
    ;; DESIGN STRATEGY: Cases on whether the event is in the Square
    (define/public (after-button-down mx my)
      (if (in-sqr? mx my)
          (new Square%
               [center-x center-x][center-y center-y]
               [selected? true]
               [off-mx (- mx center-x)]
               [off-my (- my center-y)]
               [speed speed])
          this))
    
    ;; after-button-up : NonNegInt NonNegInt -> Toy<%>
    ;; GIVEN:  x and y coordinates of mouse location
    ;; RETURNS : the state of this Square that should follow the button-up 
    ;;           MouseEvent at the given location
    ;; DETAILS : a selected Square is unselected after a button-up
    ;; DESIGN STRATEGY : create an instance of this class
    (define/public (after-button-up mx my)
      (new Square%
           [center-x center-x][center-y center-y]
           [selected? false]
           [off-mx 0]
           [off-my 0]
           [speed speed]))
    
    ;; after-drag : NonNegInt NonNegInt -> Toy<%>
    ;; GIVEN : x and y coordinates of mouse location
    ;; RETURNS : the state of this Square that should follow the drag 
    ;;           MouseEvent at the given location
    ;; DETAILS : If it is selected, move it so that the vector from the center to
    ;;           the drag event is equal to (mx, my)
    ;; DESIGN STRATEGY: Cases on whether the Square is selected.
    (define/public (after-drag mx my)
      (if selected?
          (new Square%
               [center-x (- mx off-mx)]
               [center-y (- my off-my)]
               [selected? true]
               [off-mx off-mx]
               [off-my off-my]
               [speed speed])
          this))
    
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
    
    ;; toy-y : -> Intger
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
    ;; unselected-sqr-after-tick : -> Toy<%>
    ;; GIVEN: no arguments
    ;; RETURNS: an unselected Square like this one but after
    ;;          one tick of the clock
    ;; DETAILS: if this Square will hit a boundary at the next tick then this
    ;;          Square will be placed at that boundary with the direction of
    ;;          its speed reversed.  Otherwise the speed of this Square will
    ;;          be added to the current x coordinate of its center
    ;; DESIGN STRATEGY : create an instance of this class
    (define (unselected-sqr-after-tick)
      (new Square%
           [center-x (new-x)]
           [center-y center-y]
           [selected? selected?]
           [off-mx off-mx]
           [off-my off-my]
           [speed (new-speed)]))
    
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
;;;                                [off-mx Integer]
;;;                                [off-my Integer]
;;;                                [selected? Boolean]
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
    ;; after-tick : -> Toy<%>
    ;; GIVEN : no arguments
    ;; RETURNS : A Throbber like this one, but as it should be after a tick
    ;; DETAILS : at each tick of the clock the radius of this Throbber will
    ;;           increase or decrease by one pixel
    ;; DESIGN STRATEGY : create an instance of this class
    (define/public (after-tick)
      (new Throbber%
           [center-x center-x]
           [center-y center-y]
           [selected? selected?]
           [off-mx off-mx]
           [off-my off-my]
           [r (+ r (new-speed))]
           [speed (new-speed)]))
    
    ;; after-key-event : KeyEvent -> Toy<%>
    ;; GIVEN : a KeyEvent
    ;; RETURNS : A Throbber like this one, but as it should be after the
    ;;           given key event.
    ;; DETAILS : a Throbber ignores key events
    ;; DESIGN STRATEGY : return the same object
    (define/public (after-key-event kev)
      this)      
    
    ;; after-button-down : Integer Integer -> Toy<%>
    ;; GIVEN : the x and y coordinates of a button-down event
    ;; RETURNS : the state of this Throbber that should follow the button
    ;;           down event at the specified location
    ;; DETAILS : Throbber gets selected if mouse is inside the Throbber
    ;; DESIGN STRATEGY: Cases on whether the event is in the Throbber
    (define/public (after-button-down mx my)
      (if (in-throbber? mx my)
          (new Throbber%
               [center-x center-x]
               [center-y center-y]
               [selected? true]
               [off-mx (- mx center-x)]
               [off-my (- my center-y)]
               [r r]
               [speed speed])
          this))
    
    ;; after-button-up : Integer Integer -> Toy<%>
    ;; GIVEN: the x and y coordinates of a button-up event
    ;; RETURNS: the state of this Throbber after a button-up MouseEvent
    ;;          at the given location
    ;; DETAILS: If the Throbber is selected, then unselect it
    ;; DESIGN STRATEGY : create an instance of this class
    (define/public (after-button-up mx my)
      (new Throbber%
           [center-x center-x]
           [center-y center-y]
           [selected? false]
           [off-mx 0]
           [off-my 0]
           [r r]
           [speed speed]))   
    
    ;; after-drag : Integer Integer -> Toy<%>
    ;; GIVEN : the x and y coordinates of a drag event
    ;; RETURNS : the state of this Throbber that should follow a drag MouseEvent
    ;;           at the given location
    ;; DETAILS : if this Throbber is selected, move it so that the vector from
    ;;           the center to the drag event is equal to (mx, my)
    ;; DESIGN STRATEGY: Cases on whether the Throbber is selected.
    (define/public (after-drag mx my)
      (if selected?
          (new Throbber%
               [center-x (- mx off-mx)]
               [center-y (- my off-my)]
               [selected? true]
               [off-mx off-mx]
               [off-my off-my]
               [r r]
               [speed speed])
          this))
    
    ;; add-to-scene : Scene -> Scene
    ;; GIVEN : a scene
    ;; RETURNS : a scene like the given one, but with this object painted on it
    ;; DETAILS : places the throbber image on the scene
    ;; DESIGN STRATEGY : combine simpler functions
    (define/public (add-to-scene scene)
      (place-image (get-throbber-image) center-x center-y scene))
    
    ;; METHODS FROM INTERFACE Toy<%>
    ;; -------------------------------------------------------------------------
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
    
    ;; METHODS USED IN LOCAL SCOPE :
    ;; -------------------------------------------------------------------------
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
;;;                          [off-mx Integer]
;;;                          [off-my Integer]
;;;                          [selected? Boolean]
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
    ;; after-tick : -> Toy<%>
    ;; GIVEN : no arguments
    ;; RETURNS : a Clock like this one, but as it should be after a tick
    ;; DETAILS : the Clock's val will be incremented by one
    ;; DESIGN STRATEGY : create an instance of this class
    (define/public (after-tick)
      (new Clock%
           [center-x center-x]
           [center-y center-y]
           [selected? selected?]
           [off-mx off-mx]
           [off-my off-my]
           [val (+ val 1)]))
    
    ;; after-key-event : KeyEvent -> Toy<%>
    ;; GIVEN : a KeyEvent
    ;; RETURNS : a Clock like this one, but as it should be after the
    ;;           given key event.
    ;; DETAILS : a Clock ignores key events
    ;; DESIGN STRATEGY : return the same object
    (define/public (after-key-event kev)
      this)
    
    ;; after-button-down : Integer Integer -> Toy<%>
    ;; GIVEN : x and y coordinates of mouse location
    ;; RETURNS : the state of this Clock that should follow a button-down
    ;;           MouseEvent at the given location
    ;; DETAILS : this Clock is slected if the mouse is inside the Clock when
    ;;           the button-down occurs
    ;; DESIGN STRATEGY: Cases on whether the event is in the Clock
    (define/public (after-button-down mx my)
      (if (in-clock? mx my)
          (new Clock%
               [center-x center-x]
               [center-y center-y]
               [selected? true]
               [off-mx (- mx center-x)]
               [off-my (- my center-y)]
               [val val])
          this))
    
    ;; after-button-up : Integer Integer -> Toy<%>
    ;; GIVEN : x and y coordinates of mouse location
    ;; RETURNS : the state of this Clock that should follow a button-up event
    ;;           at the given location
    ;; DETAILS : a selected Clock is unselected after a button-up
    ;; DESIGN STRATEGY : create an instance of this class
    (define/public (after-button-up mx my)
      (new Clock%
           [center-x center-x]
           [center-y center-y]
           [selected? false]
           [off-mx 0]
           [off-my 0]
           [val val]))   
    
    ;; after-drag : Integer Integer -> Toy<%>
    ;; GIVEN : x and y coordinates of mouse location
    ;; RETURNS : the state of this Clock that should follow a drag MouseEvent
    ;;          at the given location
    ;; DETAILS: if this Clock is selected, move it so that the vector
    ;;          from the center to the drag event is equal to (mx, my)
    ;; DESIGN STRATEGY: cases on whether the Clock is selected.
    (define/public (after-drag mx my)
      (if selected?
          (new Clock%
               [center-x (- mx off-mx)]
               [center-y (- my off-my)]
               [selected? true]
               [off-mx off-mx]
               [off-my off-my]
               [val val])
          this))
    
    
    ;; add-to-scene : Scene -> Scene
    ;; GIVEN : a scene
    ;; RETURNS : a scene like the given one, but with this object painted on it
    ;; DETAILS : places the Clock image on the scene
    ;; DESIGN STRATEGY : combine simpler functions
    (define/public (add-to-scene scene)
      (place-image (get-clock-image) center-x center-y scene))
    
    ;; METHODS FROM INTERFACE Toy<%>
    ;; ------------------------------------------------------------------------
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
    
    (super-new)
    
    ;; METHODS FROM INTERFACE Toy<%>
    ;; -------------------------------------------------------------------------
    ;; after-tick : -> Toy<%>
    ;; GIVEN : no arguments
    ;; RETURNS : the state of this object after the tick
    ;; DESIGN STRATEGY : combine simpler function
    (define/public (after-tick)
      (new Football%
           [center-x center-x]
           [center-y center-y]
           [selected? selected?]
           [off-mx off-mx]
           [off-my off-my]
           [size (get-new-size)]))
    
    ;; after-key-event : KeyEvent -> Toy<%>
    ;; GIVEN : a key event
    ;; RETURNS : the state of this object that should follow the given key event
    ;; DETAILS : Football ignores KeyEvents
    ;; DESIGN STRATEGY : return the same object
    (define/public (after-key-event kev)
      this)      
    
    ;; after-button-down : NonNegInt NonNegInt -> Toy<%>
    ;; GIVEN : x and y coordinates of mouse location
    ;; RETURNS : the state of this object that should follow the specified mouse
    ;;           event at the given location
    ;; DETAILS : when the event happens inside football, the football gets selected
    ;; STRATEGY : cases on whether the event is in the football
    (define/public (after-button-down mx my)
      (if (in-football? mx my)
          (new Football%
               [center-x center-x]
               [center-y center-y]
               [selected? true]
               [off-mx (- mx center-x)]
               [off-my (- my center-y)]
               [size size])
          this))
    
    ;; after-button-up : NonNegInt NonNegInt -> Toy<%>
    ;; GIVEN : x and y coordinates of mouse location
    ;; RETURNS : the state of this object that should follow the specified mouse
    ;;           event at the given location
    ;; DETAILS : when the event happens inside football, the football gets unselected
    ;; STRATEGY : cases on whether the event is in the football
    (define/public (after-button-up mx my)
      (new Football%
           [center-x center-x]
           [center-y center-y]
           [selected? false]
           [off-mx 0]
           [off-my 0]
           [size size]))
    
    ;; after-drag : NonNegInt NonNegInt -> Toy<%>
    ;; GIVEN : x and y coordinates of mouse location
    ;; RETURNS : the state of this object that should follow the specified mouse
    ;;           event at the given location
    ;; DETAILS : If it is selected, move it so that the vector from the center to
    ;;           the drag event is equal to (mx, my)
    ;; STRATEGY: Cases on whether the football is selected.
    (define/public (after-drag mx my)
      (if selected?
          (new Football%
               [center-x (- mx off-mx)]
               [center-y (- my off-my)]
               [selected? true]
               [off-mx off-mx]
               [off-my off-my]
               [size size])
          this))
    
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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; run : PosNum PosInt -> PlaygroundState<%> 
;;; GIVEN : a frame rate (in seconds/tick) and a square-speed (in pixels/tick),
;;;        creates and runs a world in which square toys travel at the given
;;;        speed.
;;; EFFECT : runs an initial world at the given frame rate
;;; RETURNS : the final state of the world
;;; DESIGN STRATEGY : use templete for big bang
(define (run rate sqr-speed)
  (big-bang (make-world sqr-speed)
            (on-tick (lambda (w) (send w after-tick)) rate)
            (on-draw (lambda (w) (send w to-scene)))
            (on-key (lambda (w kev) (send w after-key-event kev)))
            (on-mouse (lambda (w mx my mev)
                        (send w after-mouse-event mx my mev)))))



;;; make-world : PosInt -> PlaygroundState<%>
;;; GIVEN : desired speed of the square moving in the canvas. Positive value
;;;         indicates sqaure moving towards right
;;; RETURNS : a world with a target, but no toys, and in which any
;;;           square toys created in the future will travel at the given speed
;;;           (in pixels/tick)
;;; EXAMPLES : (make-world 10) = test-sqr-world
;;; DESIGN STRATEGY : combine simpler functions
(define (make-world sqr-speed)
  (create-world (new-target) empty sqr-speed))

;;; TESTS :
;;; Tested in the central testing



;;; create-world : Toy<%> ListOfToy<%> Integer -> PlaygroundState<%>
;;; GIVEN : an object of Target% class, list of toys and the speed of squares in
;;;         world
;;; RETURNS : an object of class WorldState% consisting of the given values
;;; EXAMPLES : (create-world test-img-target toys-after-tick1 10) = world-after-tick1 
;;; DESIGN STRATEGY : create an instance of WorldState% class
(define (create-world target toys sqr-speed)
  (new WorldState%
       [target target]
       [toys toys]
       [sqr-speed sqr-speed]))

;;; TESTS :
;;; Tested in the central testing



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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; CENTRAL TESTS:

;;; tests for Square:

(define TEST-SQR (make-square-toy CANVAS-CENTER-X CANVAS-CENTER-Y 10))
(define TEST-SQR-WORLD (make-world 10)) 

(define WORLD-AFTER-S (send TEST-SQR-WORLD after-key-event "s"))
(define SQUARE-AFTER-S (first (send WORLD-AFTER-S get-toys)))


(define SQR-WORLD-AFTER-TICK (send WORLD-AFTER-S after-tick))
(define SQUARE-AFTER-TICK (first (send SQR-WORLD-AFTER-TICK get-toys)))

(define SQR-WORLD-AFTER-BUTTON-DOWN
  (send WORLD-AFTER-S after-mouse-event 250 300 MOUSE-BUTTON-DOWN))
(define SQUARE-AFTER-BUTTON-DOWN
  (first (send SQR-WORLD-AFTER-BUTTON-DOWN get-toys)))

(define SQR-WORLD-AFTER-BUTTON-UP
  (send SQR-WORLD-AFTER-BUTTON-DOWN after-mouse-event 250 300 MOUSE-BUTTON-UP))
(define SQUARE-AFTER-BUTTON-UP
  (first (send SQR-WORLD-AFTER-BUTTON-UP get-toys)))

(define SQR-WORLD-AFTER-DRAG
  (send SQR-WORLD-AFTER-BUTTON-DOWN after-mouse-event 475 400 MOUSE-BUTTON-DRAG))
(define SQUARE-AFTER-DRAG
  (first (send SQR-WORLD-AFTER-DRAG get-toys)))

(define SQR-WORLD-AFTER-DRAG-BUTTON-UP
  (send SQR-WORLD-AFTER-DRAG after-mouse-event 475 400 MOUSE-BUTTON-UP))

(define SQR-WORLD-AFTER-MOVE
  (send SQR-WORLD-AFTER-BUTTON-UP after-mouse-event 300 300 "move"))
(define SQUARE-AFTER-MOVE
  (first (send SQR-WORLD-AFTER-MOVE get-toys)))


(define SQR-WORLD-AFTER-BOUNCE (send SQR-WORLD-AFTER-DRAG-BUTTON-UP after-tick))
(define SQUARE-AFTER-BOUNCE (first (send SQR-WORLD-AFTER-BOUNCE get-toys)))

(define SELECTED-SQUARE
  (new Square%
       [center-x 100]
       [center-y 100]
       [off-mx 0]
       [off-my 0]
       [selected? true]
       [speed 10]))
(define SELECTED-SQR-X (send SELECTED-SQUARE toy-x))
(define SELECTED-SQR-Y (send SELECTED-SQUARE toy-y))
(define SELECTED-SQR-SPEED (send SELECTED-SQUARE toy-data))
(define SELECTED-SQR-SELECTED (send SELECTED-SQUARE for-test:selected?))
(define SELECTED-SQR-AFTER-TICK (send SELECTED-SQUARE after-tick))
(define X-AFTER-TICK (send SELECTED-SQR-AFTER-TICK toy-x))
(define Y-AFTER-TICK (send SELECTED-SQR-AFTER-TICK toy-y))
(define SPEED-AFTER-TICK (send SELECTED-SQR-AFTER-TICK toy-data))
(define SELECTED-AFTER-TICK (send SELECTED-SQR-AFTER-TICK for-test:selected?))

(define SQUARE-AFTER-BUTTON-DOWN2 (send TEST-SQR after-button-down 100 100))
(define SQUARE-AFTER-DRAG2 (send TEST-SQR after-drag 100 100))

(define SQUARE-BEFORE-BOUNCE
  (new Square%
       [center-x 25]
       [center-y 100]
       [off-mx 0]
       [off-my 0]
       [selected? false]
       [speed -10]))

(define SQUARE-AFTER-BOUNCE2 (send SQUARE-BEFORE-BOUNCE after-tick))

(begin-for-test
  (check-equal? (send SQUARE-AFTER-S toy-x) 250
                "The initial x position of the square is 250")
  (check-equal? (send SQUARE-AFTER-S toy-y) 300
                "The initial y position of the square is 300")
  (check-equal? (send SQUARE-AFTER-BUTTON-DOWN for-test:selected?) true
                "The square should be selected after the given button-down")
  (check-equal? (send SQUARE-AFTER-BUTTON-UP for-test:selected?) false
                "The square should not be selected after a button-up")
  (check-equal? (send SQUARE-AFTER-DRAG toy-x) 475
                "After the drag the x position of the square shuold be 475")
  (check-equal? (send SQUARE-AFTER-DRAG toy-y) 400
                "After the drag the y position of the square should be 400")
  (check-equal? (send SQUARE-AFTER-BOUNCE toy-x) 480 
                "After bounce the x position of the square should be 480")
  (check-equal? (send SQUARE-AFTER-BOUNCE toy-y) 400
                "After bounce the y position of the square should be 400")
  (check-equal? (send SQUARE-AFTER-BOUNCE toy-data) -10
                "The speed of the square should be -10")
  (check-equal? (send SQUARE-AFTER-MOVE toy-x) 250
                "there is no effect after move which is not included")
  (check-equal? (send SQUARE-AFTER-MOVE toy-y) 300
                "there is no effect after move which is not included")
  (check-equal? (send SQUARE-AFTER-MOVE toy-data) 10
                "there is no effect after move which is not included")  
  (check-equal? (send SQUARE-AFTER-BOUNCE2 toy-x) 20
                "The x coordinate of the Square should be 20")
  (check-equal? (send SQUARE-AFTER-BOUNCE2 toy-y) 100
                "The y coordinate of the Square should be 100")
  (check-equal? (send SQUARE-AFTER-BOUNCE2 toy-data) 10
                "The speed of the Square should be 10")
  (check-equal? X-AFTER-TICK 100
                "The Square doesn't move because it's selected")
  (check-equal? Y-AFTER-TICK 100
                "The Square doesn't move because it's selected")
  (check-equal? SPEED-AFTER-TICK 10
                "The speed of the Square is unchanged")
  (check-equal? SELECTED-AFTER-TICK true
                "The Square is still selected after a tick")
  (check-equal? (send SQUARE-AFTER-BUTTON-DOWN2 toy-x) 250
                "The x coordinate of the Square should be 250")
  (check-equal? (send SQUARE-AFTER-BUTTON-DOWN2 toy-y) 300
                "The y coordinate of the Square should be 300")
  (check-equal? (send SQUARE-AFTER-DRAG2 toy-x) 250
                "The x coordinate of the Square should be 250")
  (check-equal? (send SQUARE-AFTER-DRAG2 toy-y) 300
                "The y coordinate of the Square should be 300"))

;; tests for Throbber

(define TEST-THROBBER (make-throbber CANVAS-CENTER-X CANVAS-CENTER-Y))
(define TEST-THROBBER-WORLD (make-world 10))

(define WORLD-AFTER-T (send TEST-THROBBER-WORLD after-key-event "t"))
(define THROBBER-AFTER-T (first (send WORLD-AFTER-T get-toys)))

(define THROBBER-WORLD-AFTER-TICK (send WORLD-AFTER-T after-tick))
(define THROBBER-AFTER-TICK (first (send THROBBER-WORLD-AFTER-TICK get-toys)))

(define THROBBER-WORLD-AFTER-BUTTON-DOWN
  (send WORLD-AFTER-T after-mouse-event 250 300 MOUSE-BUTTON-DOWN))
(define THROBBER-AFTER-BUTTON-DOWN
  (first (send THROBBER-WORLD-AFTER-BUTTON-DOWN get-toys)))

(define THROBBER-WORLD-AFTER-BUTTON-UP
  (send THROBBER-WORLD-AFTER-BUTTON-DOWN after-mouse-event 250 300 MOUSE-BUTTON-UP))
(define THROBBER-AFTER-BUTTON-UP
  (first (send THROBBER-WORLD-AFTER-BUTTON-UP get-toys)))

(define THROBBER-WORLD-AFTER-DRAG
  (send THROBBER-WORLD-AFTER-BUTTON-DOWN after-mouse-event 475 400 MOUSE-BUTTON-DRAG))
(define THROBBER-AFTER-DRAG
  (first (send THROBBER-WORLD-AFTER-DRAG get-toys)))

(define TEST-THROBBER2
  (new Throbber%
       [center-x 100]
       [center-y 100]
       [selected? false]
       [off-mx 0]
       [off-my 0]
       [r 15]
       [speed 1]))
(define THROBBER2-AFTER-TICK (send TEST-THROBBER2 after-tick))

(define TEST-THROBBER3
  (new Throbber%
       [center-x 100]
       [center-y 100]
       [selected? false]
       [off-mx 0]
       [off-my 0]
       [r 20]
       [speed 1]))
(define THROBBER3-AFTER-TICK (send TEST-THROBBER3 after-tick ))
(define THROBBER3-AFTER-BD (send TEST-THROBBER3 after-button-down 200 200))
(define THROBBER3-AFTER-DRAG (send TEST-THROBBER3 after-drag 200 200))
(define THROBBER3-AFTER-KE (send TEST-THROBBER3 after-key-event "j"))

(begin-for-test
  (check-equal? (send THROBBER-AFTER-T toy-x) 250
                "The x position of the throbber should be 250")
  (check-equal? (send THROBBER-AFTER-T toy-y) 300
                "The y position of the throbber should be 300")
  (check-equal? (send THROBBER-AFTER-T toy-data) 5
                "The initial radius of the throbber should be 5")
  (check-equal? (send THROBBER-AFTER-TICK toy-data) 6
                "After 1 tick the radius of the throbber should be 6")
  (check-equal? (send THROBBER-AFTER-BUTTON-DOWN for-test:selected?) true
                "After the button-down the throbber should be selected")
  (check-equal? (send THROBBER-AFTER-BUTTON-UP for-test:selected?) false
                "After the button-up the throbber should not be selected")
  (check-equal? (send THROBBER-AFTER-DRAG toy-x) 475
                "After drag the x position of the throbber should be 475")
  (check-equal? (send THROBBER-AFTER-DRAG toy-y) 400
                "After drag the y position of the throbber should be 400")
  (check-equal? (send THROBBER2-AFTER-TICK toy-data) 16
                "The radius of the Throbber should be 16")
  (check-equal? (send THROBBER3-AFTER-TICK toy-data) 19
                "The radius of the Throbber should be 19")
  (check-equal? (send THROBBER3-AFTER-BD toy-x) 100
                "The x coordinate of the Throbber should be 100")
  (check-equal? (send THROBBER3-AFTER-BD toy-y) 100
                "The y coordinate of the Throbber should be 100")
  (check-equal? (send THROBBER3-AFTER-BD toy-data) 20
                "The radius of the Throbber should be 20")
  (check-equal? (send THROBBER3-AFTER-BD for-test:selected?) false
                "The Throbber should not be selected")
  (check-equal? (send THROBBER3-AFTER-DRAG toy-x) 100
                "The x coordinate of the Throbber should be 100")
  (check-equal? (send THROBBER3-AFTER-DRAG toy-y) 100
                "The y coordinate of the Throbber should be 100")
  (check-equal? (send THROBBER3-AFTER-DRAG toy-data) 20
                "The radius of the Throbber should be 20")
  (check-equal? (send THROBBER3-AFTER-DRAG for-test:selected?) false
                "The Throbber should not be selected")
  (check-equal? (send THROBBER3-AFTER-KE toy-x) 100
                "The x coordinate of the Throbber should be 100")
  (check-equal? (send THROBBER3-AFTER-KE toy-y) 100
                "The y coordinate of the Throbber should be 100")
  (check-equal? (send THROBBER3-AFTER-KE toy-data) 20
                "The radius of the Throbber should be 20")
  (check-equal? (send THROBBER3-AFTER-KE for-test:selected?) false
                "The Throbber should not be selected"))

;; tests for clock

(define TEST-CLOCK (make-clock CANVAS-CENTER-X CANVAS-CENTER-Y))
(define TEST-CLOCK-WORLD (make-world 10))

(define WORLD-AFTER-W (send TEST-CLOCK-WORLD after-key-event "w"))
(define CLOCK-AFTER-W (first (send WORLD-AFTER-W get-toys)))

(define CLOCK-WORLD-AFTER-TICK (send WORLD-AFTER-W after-tick))
(define CLOCK-AFTER-TICK (first (send CLOCK-WORLD-AFTER-TICK get-toys)))

(define CLOCK-WORLD-AFTER-BUTTON-DOWN
  (send WORLD-AFTER-W after-mouse-event 250 300 MOUSE-BUTTON-DOWN))
(define CLOCK-AFTER-BUTTON-DOWN
  (first (send CLOCK-WORLD-AFTER-BUTTON-DOWN get-toys)))

(define CLOCK-WORLD-AFTER-BUTTON-UP
  (send CLOCK-WORLD-AFTER-BUTTON-DOWN after-mouse-event 250 300 MOUSE-BUTTON-UP))
(define CLOCK-AFTER-BUTTON-UP
  (first (send CLOCK-WORLD-AFTER-BUTTON-UP get-toys)))

(define CLOCK-WORLD-AFTER-DRAG
  (send CLOCK-WORLD-AFTER-BUTTON-DOWN after-mouse-event 475 400 MOUSE-BUTTON-DRAG))
(define CLOCK-AFTER-DRAG
  (first (send CLOCK-WORLD-AFTER-DRAG get-toys)))

(define TEST-CLOCK-AFTER-KE (send TEST-CLOCK after-key-event "j"))
(define TEST-CLOCK-AFTER-BD (send TEST-CLOCK after-button-down 100 100))
(define TEST-CLOCK-AFTER-DRAG (send TEST-CLOCK after-drag 100 100))

(begin-for-test
  (check-equal? (send CLOCK-AFTER-W toy-x) 250
                "The x position of the clock should be 250")
  (check-equal? (send CLOCK-AFTER-W toy-y) 300
                "The y position of the clock should be 300")
  (check-equal? (send CLOCK-AFTER-TICK toy-data) 1
                "The clock should read 1 after 1 tick")
  (check-equal? (send CLOCK-AFTER-BUTTON-DOWN for-test:selected?) true
                "The clock should be selected after the button-down")
  (check-equal? (send CLOCK-AFTER-BUTTON-UP for-test:selected?) false
                "The clock should not be selected after the button-up")
  (check-equal? (send CLOCK-AFTER-DRAG toy-x) 475
                "The x position of the clock should be 475 after the drag")
  (check-equal? (send CLOCK-AFTER-DRAG toy-y) 400
                "The y position of the clock should be 400 after the drag")
  (check-equal? (send TEST-CLOCK-AFTER-KE toy-x) 250
                "The x coordinate of the Clock should be 250")
  (check-equal? (send TEST-CLOCK-AFTER-KE toy-y) 300
                "The y coordinate of the Clock should be 300")
  (check-equal? (send TEST-CLOCK-AFTER-KE toy-data) 0
                "The Clock should be at time 0")
  (check-equal? (send TEST-CLOCK-AFTER-BD toy-x) 250
                "The x coordinate of the Clock should be 250")
  (check-equal? (send TEST-CLOCK-AFTER-BD toy-y) 300
                "The y coordinate of the Clock should be 300")
  (check-equal? (send TEST-CLOCK-AFTER-BD toy-data) 0
                "The Clock should be at time 0")
  (check-equal? (send TEST-CLOCK-AFTER-DRAG toy-x) 250
                "The x coordinate of the Clock should be 250")
  (check-equal? (send TEST-CLOCK-AFTER-DRAG toy-y) 300
                "The y coordinate of the Clock should be 300")
  (check-equal? (send TEST-CLOCK-AFTER-DRAG toy-data) 0
                "The Clock should be at time 0"))

;; tests for Football

(define TEST-FOOTBALL (make-football CANVAS-CENTER-X CANVAS-CENTER-Y))
(define TEST-FOOTBALL-WORLD (make-world 10))

(define WORLD-AFTER-F (send TEST-FOOTBALL-WORLD after-key-event "f"))
(define FOOTBALL-AFTER-F (first (send WORLD-AFTER-F get-toys)))

(define FOOTBALL-WORLD-AFTER-TICK (send WORLD-AFTER-F after-tick))
(define FOOTBALL-AFTER-TICK (first (send FOOTBALL-WORLD-AFTER-TICK get-toys)))

(define FOOTBALL-WORLD-AFTER-BUTTON-DOWN
  (send WORLD-AFTER-F after-mouse-event 250 300 MOUSE-BUTTON-DOWN))
(define FOOTBALL-AFTER-BUTTON-DOWN
  (first (send FOOTBALL-WORLD-AFTER-BUTTON-DOWN get-toys)))

(define SELECTED-FOOTBALL-AFTER-TICK
  (send FOOTBALL-AFTER-BUTTON-DOWN after-tick))

(define FOOTBALL-WORLD-AFTER-BUTTON-UP
  (send FOOTBALL-WORLD-AFTER-BUTTON-DOWN after-mouse-event 250 300 MOUSE-BUTTON-UP))
(define FOOTBALL-AFTER-BUTTON-UP
  (first (send FOOTBALL-WORLD-AFTER-BUTTON-UP get-toys)))

(define FOOTBALL-WORLD-AFTER-DRAG
  (send FOOTBALL-WORLD-AFTER-BUTTON-DOWN after-mouse-event 475 400 MOUSE-BUTTON-DRAG))
(define FOOTBALL-AFTER-DRAG
  (first (send FOOTBALL-WORLD-AFTER-DRAG get-toys)))

(define DEFLATED-BALL
  (new Football%
       [center-x 100]
       [center-y 100]
       [selected? false]
       [off-mx 0]
       [off-my 0]
       [size 1]))

(define DEFLATED-BALL-AFTER-TICK (send DEFLATED-BALL after-tick))
(define DEFLATED-BALL-AFTER-KE (send DEFLATED-BALL after-key-event "j"))
(define DEFLATED-BALL-AFTER-BD (send DEFLATED-BALL after-button-down 200 200))
(define DEFLATED-BALL-AFTER-DRAG (send DEFLATED-BALL after-drag 200 200))

(begin-for-test
  (check-equal? (send FOOTBALL-AFTER-F toy-x) 250
                "The x position of the football should be 250")
  (check-equal? (send FOOTBALL-AFTER-F toy-y) 300
                "The y position of the football should be 300")
  (check-equal? (send FOOTBALL-AFTER-TICK toy-data) 29
                "The football size is 13, the commissioner is pleased")
  (check-equal? (send FOOTBALL-AFTER-BUTTON-DOWN for-test:selected?) true
                "The football should be selected after the button-down")
  (check-equal? (send FOOTBALL-AFTER-BUTTON-UP for-test:selected?) false
                "The football should not be selected after the button-up")
  (check-equal? (send FOOTBALL-AFTER-DRAG toy-x) 475
                "The x position of the football should be 475 after the drag")
  (check-equal? (send FOOTBALL-AFTER-DRAG toy-y) 400
                "The y position of the football should be 400 after the drag")
  (check-equal? (send DEFLATED-BALL-AFTER-TICK toy-data) 1
                "The Football size is 1, the commissioner is displeased")
  (check-equal? (send DEFLATED-BALL-AFTER-KE toy-x) 100
                "The x coordinate of the Football should be 100")
  (check-equal? (send DEFLATED-BALL-AFTER-KE toy-y) 100
                "The y coordinate of the Football should be 100")
  (check-equal? (send DEFLATED-BALL-AFTER-KE toy-data) 1
                "The Football size is 1, the commissioner is displeased")
  (check-equal? (send DEFLATED-BALL-AFTER-BD toy-x) 100
                "The x coordinate of the Football should be 100")
  (check-equal? (send DEFLATED-BALL-AFTER-BD toy-y) 100
                "The y coordinate of the Football should be 100")
  (check-equal? (send DEFLATED-BALL-AFTER-BD toy-data) 1
                "The Football size is 1, the commissioner is displeased")
  (check-equal? (send DEFLATED-BALL-AFTER-DRAG toy-x) 100
                "The x coordinate of the Football should be 100")
  (check-equal? (send DEFLATED-BALL-AFTER-DRAG toy-y) 100
                "The y coordinate of the Football should be 100")
  (check-equal? (send DEFLATED-BALL-AFTER-DRAG toy-data) 1
                "The Football size is 1, the commissioner is displeased"))

;; tests for WorldState

(define EMPTY-WORLD (make-world 10))
(define EMPTY-WORLD-TARGET-X (send EMPTY-WORLD target-x))
(define EMPTY-WORLD-TARGET-Y (send EMPTY-WORLD target-y))
(define EMPTY-WORLD-TARGET-SELECTED (send EMPTY-WORLD target-selected?))
(define EMPTY-WORLD-TOYS (send EMPTY-WORLD get-toys))
(define WORLD-AFTER-J (send EMPTY-WORLD after-key-event "j"))
(define WORLD-AFTER-J-TARGET-X (send WORLD-AFTER-J target-x))
(define WORLD-AFTER-J-TARGET-Y (send WORLD-AFTER-J target-y))
(define WORLD-AFTER-J-TARGET-SELECTED (send WORLD-AFTER-J target-selected?))
(define WORLD-AFTER-J-TOYS (send WORLD-AFTER-J get-toys))
(define WORLD-WITH-SQUARE (send EMPTY-WORLD after-key-event "s"))
(define WORLD-WITH-SQUARE-AFTER-J
  (send WORLD-WITH-SQUARE after-key-event "j"))
(define SQUARE-AFTER-J (first (send WORLD-WITH-SQUARE-AFTER-J get-toys)))
(define SQUARE-X-AFTER-J (send SQUARE-AFTER-J toy-x))
(define SQUARE-Y-AFTER-J (send SQUARE-AFTER-J toy-y))
(define SQUARE-SPEED-AFTER-J (send SQUARE-AFTER-J toy-data))

(begin-for-test
  (check-equal?
   EMPTY-WORLD-TARGET-X
   WORLD-AFTER-J-TARGET-X
   "The x positions of the targets in the two worlds should be the same")
  (check-equal?
   EMPTY-WORLD-TARGET-Y
   WORLD-AFTER-J-TARGET-Y
   "The y positions of the targets in the two worlds should be the same")
  (check-equal?
   EMPTY-WORLD-TARGET-SELECTED
   WORLD-AFTER-J-TARGET-SELECTED
   "Neither target should be selected")
  (check-equal?
   EMPTY-WORLD-TOYS
   WORLD-AFTER-J-TOYS
   "Both lists should be empty")
  (check-equal?
   SQUARE-X-AFTER-J
   250
   "The x coordinate of the Square should be 250")
  (check-equal?
   SQUARE-Y-AFTER-J
   300
   "The y coordinate of the Square should be 300")
  (check-equal?
   SQUARE-SPEED-AFTER-J
   10
   "The speed of the Square should be 10px/s"))

;; tests for Target

(define TEST-TARGET
  (new Target%
       [x 100]
       [y 100]
       [selected? false]
       [off-mx 0]
       [off-my 0]))
(define TEST-TARGET-X (send TEST-TARGET for-test:x))
(define TEST-TARGET-Y (send TEST-TARGET for-test:y))
(define TEST-TARGET-SELECTED (send TEST-TARGET for-test:selected?))
(define TARGET-AFTER-KEY (send TEST-TARGET after-key-event "s"))
(define TARGET-AFTER-KEY-X (send TARGET-AFTER-KEY for-test:x))
(define TARGET-AFTER-KEY-Y (send TARGET-AFTER-KEY for-test:y))
(define TARGET-AFTER-KEY-SELECTED (send TARGET-AFTER-KEY for-test:selected?))
(define TARGET-AFTER-BUTTON-DOWN (send TEST-TARGET after-button-down 200 200))
(define TARGET-SELECTED-AFTER-BD
  (send TARGET-AFTER-BUTTON-DOWN for-test:selected?))
(define TARGET-AFTER-DRAG (send TEST-TARGET after-drag 200 200))
(define TARGET-X-AFTER-DRAG (send TARGET-AFTER-DRAG for-test:x))
(define TARGET-Y-AFTER-DRAG (send TARGET-AFTER-DRAG for-test:y))

(begin-for-test
  (check-equal?
   TEST-TARGET-X
   TARGET-AFTER-KEY-X
   "The x coordinates of the Targets should be equal")
  (check-equal?
   TEST-TARGET-Y
   TARGET-AFTER-KEY-Y
   "The y coordinates of the Targets should be equal")
  (check-equal?
   TEST-TARGET-SELECTED
   TARGET-AFTER-KEY-SELECTED
   "Neither Target should be selected")
  (check-equal?
   TEST-TARGET-SELECTED
   TARGET-SELECTED-AFTER-BD
   "Neither Target should be seleceted")
  (check-equal?
   TEST-TARGET-X
   TARGET-X-AFTER-DRAG
   "The x coordinates of the Targets should be equal")
  (check-equal?
   TEST-TARGET-Y
   TARGET-Y-AFTER-DRAG
   "The y coordinates of the Targets should be equal"))



;; tests for Image functions

(define TARGET-IMG (circle 10 "outline" "blue"))
(define SQUARE-IMG (rectangle 40 40 "outline" "red"))
(define THROBBER-IMG (circle 5 "solid" "green"))
(define CLOCK-IMG (text (number->string 13) 20 "black"))
(define FOOTBALL-IMG FOOTBALL-IMAGE)

(define WORLD-IMG1 (place-image TARGET-IMG 250 300 EMPTY-CANVAS))
(define WORLD-IMG2 (place-image SQUARE-IMG 150 150 WORLD-IMG1))
(define WORLD-IMG3 (place-image THROBBER-IMG 200 200 WORLD-IMG2))
(define WORLD-IMG4 (place-image CLOCK-IMG 350 350 WORLD-IMG3))
(define WORLD-IMG5 (place-image FOOTBALL-IMG 450 450 WORLD-IMG4))

(define TEST-IMG-TARGET (new-target))
(define TEST-IMG-SQUARE (make-square-toy 150 150 10))
(define TEST-IMG-THROBBER (make-throbber 200 200))
(define TEST-IMG-CLOCK
  (new Clock%
       [center-x 350]
       [center-y 350]
       [selected? false]
       [off-mx 0]
       [off-my 0]
       [val 13]))
(define TEST-IMG-FOOTBALL
  (new Football%
       [center-x 450]
       [center-y 450]
       [selected? false]
       [off-mx 0]
       [off-my 0]
       [size 14]))
(define TEST-IMG-TOYS
  (list
   TEST-IMG-SQUARE
   TEST-IMG-THROBBER
   TEST-IMG-FOOTBALL
   TEST-IMG-CLOCK))

(define TEST-IMG-WORLD
  (new WorldState%
       [target TEST-IMG-TARGET]
       [toys TEST-IMG-TOYS]
       [sqr-speed 10]))

(begin-for-test
  (check-equal? (send TEST-IMG-WORLD to-scene) WORLD-IMG5))
