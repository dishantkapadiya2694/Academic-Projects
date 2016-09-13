#lang racket
(require rackunit)
(require "extras.rkt")
(require "WidgetWorks.rkt")
(require 2htdp/universe)    
(require 2htdp/image)

(provide
 make-block
 Block<%>)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; CONSTANTS: 


(define BLOCK-KEY "b")

(define MOUSE-BUTTON-DOWN "button-down")

(define MOUSE-BUTTON-UP "button-up")

(define MOUSE-DRAG "drag")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; DATA-DEFINITIONS:

;;; ListOfBlock<%> (LOB<%>) :
;;; A LOB<%> is either :
;;; -- empty                
;;; -- (cons Toy<%> LOT<%>) 
#;(define (lot-fn lot)
    (cond
      [(empty? lot)...]
      [else
       (... (send (first (lob)) ...) 
            (lob-fn (rest (lob))))]))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; Represents a block.  A block may be part of a team of blocks.
(define Block<%>
  (interface (SWidget<%>)
    
    ;; get-team : -> ListOfBlock<%>
    ;; RETURNS: The teammates of this block
    get-team
    
    ;; add-teammate: Block<%> -> Void
    ;; EFFECT: Adds the given block to this block's team
    add-teammate
    
    ;; update-x : Integer -> Void
    ;; update-y : Integer -> Void
    ;; GIVEN: An integer
    ;; EFFECT: Adds the given integer to the current x or y coordinate of a
    ;;         Block
    update-x
    update-y
    
    ;; update-teammates : ListOfBlock -> Void
    ;; udpdate-non-teammates: ListOfBlock -> Void
    ;; GIVEN: A ListOfBlock
    ;; EFFECT: Sets the Blocks teammates or non-teammates attribute to be the
    ;;         given ListOfBlock
    update-teammates
    update-non-teammates
    
    ;; combine-teams : ListOfBlock -> Void
    ;; GIVEN: A ListOfBlock that represents a team
    ;; EFFECT: Combines the given team with this Blocks team
    combine-teams
    
    ;; get-block-image : -> Image
    ;; GIVEN: No arguments
    ;; RETURNS: An image of this Block
    get-block-image
    
    ;; block-x : -> Integer
    ;; block-y : -> Integer
    ;; GIVEN: No arguments
    ;; RETURNS: The x or y coordinate of this Block
    block-x
    block-y
    ))

;;; A PlaygroundState represents the state of all Blocks that have been created
;;; and allows the user to interact with those Blocks.
(define PlaygroundState<%>
  (interface (StatefulWorld<%>)
    
    ;; get-x : -> Integer
    ;; get-y : -> Integer
    ;; GIVEN: no arguments
    ;; RETURNS: the x or y coordinate of the location where the
    ;;          next block will be created
    get-x
    get-y
    
    ;; get-blocks : -> ListOfBlock
    ;; GIVEN: no arguments
    ;; RETURNS: a list of all the Blocks in this PlaygroundState
    get-blocks
    
    ;; add-block : Block -> void
    ;; GIVEN: a Block
    ;; EFFECT: adds the given block to this PlaygroundState
    add-block
    ))

;;; A PlaygroundState is a (new PlaygroundState%
;;;                             [canvas-width Int]
;;;                             [canvas-height Int])
;;; A PlaygroundState represents the state of all the Blocks the
;;; user has created
(define PlaygroundState%
  (class* object% (PlaygroundState<%>)
    
    ;; the height of the canvas
    (init-field canvas-width )
    
    ;; the width of the canvas
    (init-field canvas-height )
    
    ;; list of the widgets in this PlaygroundState
    (init-field [objs empty])
    
    ;; list of the stateful widgets in this PlaygroundState
    (init-field [sobjs empty])  
    
    ;; list of all the Blocks in this PlaygroundState
    (field [blocks empty])
    
    ;; the x coordinate of the location on the canvas where a new block will
    ;; be added
    (field [new-block-x (/ canvas-width 2)])
    
    ;; the y coordinate of the location on the canvas where a new block will be
    ;; added
    (field [new-block-y (/ canvas-height 2)])
    
    ;; and image of an empty canvas
    (field [EMPTY-CANVAS (empty-scene canvas-width canvas-height)])
    
    (super-new)
    
    ;; METHODS FROM INTERFACE StatefulWorld<%>
    ;; -------------------------------------------------------------------------
    ;; run : PosReal -> World
    ;; GIVEN: a frame rate, in secs/tick
    ;; EFFECT: runs this world at the given frame rate
    ;; RETURNS: the world in its final state of the world
    ;; Note: the (begin (send w ...) w) idiom
    ;; DESIGN STRATEGY : use templete of big-bang
    (define/public (run rate)
      (big-bang this
                (on-tick
                 (lambda (w) (begin (after-tick) w)) 
                 rate)
                (on-draw
                 (lambda (w) (to-scene)))
                (on-key
                 (lambda (w kev)
                   (begin
                     (after-key-event kev)
                     w)))
                (on-mouse
                 (lambda (w mx my mev)
                   (begin
                     (after-mouse-event mx my mev)
                     w)))))
    
    ;; add-widget : Widget<%> -> Void
    ;; GIVEN: a Widget<%>
    ;; EFFECT: adds the given Widget to this PlaygroundStates list of Widget
    ;; DESIGN STRATEGY : update this object
    (define/public (add-widget w)
      (set! objs (cons w objs)))
    
    ;; add-stateful-widget : SWidget<%> -> void
    ;; GIVEN: an SWidget<%>
    ;; EFFECT: addds the given SWidget to this PlaygroundStates list of SWidget
    ;; DESIGN STRATEGY : update this object
    (define/public (add-stateful-widget w)
      (set! sobjs (cons w sobjs)))
    
    ;; METHODS FROM INTERFACE PlaygroundState<%>
    ;; -------------------------------------------------------------------------
    ;; get-blocks : -> ListOfBlock
    ;; GIVEN: No arguments
    ;; RETURNS: A list of all the blocks in this PlaygroundState
    ;; DESIGN STRATEGY : return a value from this object
    (define/public (get-blocks)
      blocks)
    
    ;; get-x : -> Integer
    ;; GIVEN: No arguments
    ;; RETURNS: The x coordinate of the location where the next new
    ;;          Block will be created
    ;; DESIGN STRATEGY : return a value from this object
    (define/public (get-x)
      new-block-x)
    
    ;; get-y : -> Integer
    ;; GIVEN: No arguments
    ;; RETURNS: The y coordinate of the location where the next new
    ;;          Block will be created
    ;; DESIGN STRATEGY: Return a valud from this object
    ;; DESIGN STRATEGY : return a value from this object
    (define/public (get-y)
      new-block-y)
    
    ;; add-block : Block -> Void
    ;; GIVEN: A Block
    ;; EFFECT: Adds the given Block to this PlaygroundStates list of Blocks
    ;;         and alerts all other Blocks in the world to the given Blocks
    ;;         existence
    ;; DESIGN STRATEGY : update this object
    (define/public (add-block new-block)
      (begin
        (publish-new-block new-block)
        (set! blocks (append (list new-block) blocks))))
    
    ;; FUNCTIONS USED IN LOCAL SCOPE :
    ;; -------------------------------------------------------------------------
    ;; (Widget or SWidget -> Void) -> Void 
    ;; GIVEN: a function and a Widget or SWidget
    ;; EFFECT: applies the given function to the given object
    ;; DESIGN STRATEGY : update this object
    (define (process-widgets fn)
      (begin
        (set! objs (map fn objs))
        (for-each fn (append blocks sobjs))))
    
    ;; after-tick : -> Void
    ;; GIVEN: no arguments
    ;; EFFECT: modifies this PlaygroundState to the state it should be in at
    ;;         the next tick of the clock
    ;; DESIGN STRATEGY: Use map on the Widgets in this World; use for-each on
    ;;                  the stateful widgets
    (define (after-tick)
      (process-widgets
       (lambda (obj) (send obj after-tick))))
    
    ;; to-scene : -> Scene
    ;; GIVEN: no arguments
    ;; RETURNS: an image of this PlaygroundState
    ;; DETAILS: the append is inefficient, but clear
    ;; DESIN STRATEGY : use HOF foldr on list of blocks, objs and sobjs
    (define (to-scene)
      (foldr
       (lambda (obj scene)
         (send obj add-to-scene scene))
       EMPTY-CANVAS
       (append blocks sobjs)))
    
    ;; after-key-event : KeyEvent -> Void
    ;; GIVEN: A KeyEvent
    ;; EFFECT: Modifies this PlaygroundState to the state it shoudl be in after
    ;;         the given KeyEvent.
    ;; DESIGN STRATEGY: Pass the KeyEvents on to the objects in the world.
    (define (after-key-event kev)
      (process-widgets
       (lambda (obj) (send obj after-key-event kev))))
    
    ;; publish-new-blocks : Block<%> -> Void
    ;; GIVEN: a Block
    ;; EFFECT: notifies all the other Blocks in the world
    ;;         that the given Block exists
    ;; DESIGN STRATEGY : update the list
    (define (publish-new-block new-block)
      (for-each
       (lambda (b)
         (send b new-block-added new-block)) 
       blocks))
    
    ;; world-after-mouse-event : Integer Integer MouseEvent -> Void
    ;; GIVEN: The representation of a MouseEvent
    ;; EFFECT: modifies this PlaygroundState to the state it should be
    ;;         in after the given MouseEvent
    ;; DESIGN STRATGY: Cases on mev
    (define (after-mouse-event mx my mev)
      (cond
        [(mouse=? mev MOUSE-BUTTON-DOWN)
         (world-after-button-down mx my)]
        [(mouse=? mev MOUSE-DRAG)
         (world-after-drag mx my)]
        [(mouse=? mev MOUSE-BUTTON-UP)
         (world-after-button-up mx my)]
        [else this]))
    
    ;; world-after-button-down : Integer Integer -> Void
    ;; GIVEN: The x and y coordinates of a button-down MouseEvent
    ;; EFFECT: Modifies this PlaygroundState to the state it should be in
    ;;         after a button-down MouseEvent at the given location
    ;; DESIGN STRATEGY : update this object
    (define (world-after-button-down mx my) 
      (begin
        (set! new-block-x mx)
        (set! new-block-y my)
        (process-widgets
         (lambda (obj) (send obj after-button-down mx my)))))
    
    ;; world-after-button-up : Integer Integer -> Void
    ;; GIVEN: The x and y coordinates of a button-up MouseEvent
    ;; EFFECT: Modifies this PlaygroundState to the state it should be in
    ;;         after a button-up MouseEvent at the given location
    ;; DESIGN STRATEGY : update this object
    (define (world-after-button-up mx my)
      (begin
        (set! new-block-x mx)
        (set! new-block-y my)
        (process-widgets
         (lambda (obj) (send obj after-button-up mx my)))))
    
    ;; world-after-button-drag : Integer Integer -> Void
    ;; GIVEN: The x and y coordinates of a drag MouseEvent
    ;; EFFECT: Modifies this PlaygroundState to the state it should be in
    ;;         after a drag MouseEvent at the given location
    ;; DESIGN STRATEGY : call a general function process-widgets
    (define (world-after-drag mx my)
      (process-widgets
       (lambda (obj) (send obj after-drag mx my))))
    
    ;; for-test:after-tick : -> Void
    ;; GIVEN: No arguments
    ;; EFFECT: Calls this PlaygroudStates after-tick function
    ;; DESIGN STRATEGY : combine simpler function
    (define/public (for-test:after-tick) 
      (after-tick))
    
    ;; for-test:after-key-event : KeyEvent -> Void
    ;; GIVEN: No arguments
    ;; EFFECT: Calls this PlaygroudStates after-tick function
    ;; DESIGN STRATEGY : combine simpler function
    (define/public (for-test:after-key-event kev)
      (after-key-event kev))
    
    ;; for-test:after-mouse-event : Integer Integer MouseEvent -> Void
    ;; GIVEN: No arguments
    ;; EFFECT: Calls this PlaygroudStates after-tick function
    ;; DESIGN STRATEGY : combine simpler function
    (define/public (for-test:after-mouse-event mx my mev)
      (after-mouse-event mx my mev))
    
    ;; for-test:to-scene : -> Scene
    ;; GIVEN: No arguments
    ;; EFFECT: Calls this PlaygroudStates after-tick function
    ;; DESIGN STRATEGY : combine simpler function
    (define/public (for-test:to-scene)
      (to-scene))
    )) 

;;; A Block is a (new Block%
;;;                   [center-x Int]
;;;                   [center-y Int]
;;;                   [off-mx Int]
;;;                   [off-my Int]
;;;                   [selected? Boolean]
;;;                   [teammates ListOfBlock]
;;;                   [non-teammates ListOfBlock]
;;; A Block is a stateful widget that is selectable and draggable.  Blocks
;;; may be part of teams.  If a selected Block is dragged into another Block
;;; those Blocks and all of their teammates become teammates.
(define Block%
  (class* object% (Block<%>)
    
    ;; x coordinate of the center of this Block
    (init-field center-x)
    
    ;; y coordinate of the center of this Block
    (init-field center-y)
    
    ;; x distance from the x coordinates of the center of this Block 
    ;; to the x coordinate of a mouse click when mouse is inside this Block
    (init-field off-mx)
    
    ;; y distance from the y coordinates of the center of this Block 
    ;; to the y coordinate of a mouse click when mouse is inside this Block
    (init-field off-my)
    
    ;; true if this Block is selected, false otherwise
    (init-field selected?)
    
    ;; a list of this Blocks teammates
    (init-field teammates)
    
    ;; a list of the Blocks in the PlaygroundState that are not teammates with
    ;; this block
    (init-field non-teammates)
    
    ;; length of a side of this Block
    (field [SIDE-LEN 20])
    
    ;; half the length of a side of this Block
    (field [HALF-SIDE-LEN (/ SIDE-LEN 2)])
    
    ;; color of a selected block
    (field [SELECTED-COLOR "red"])
    
    ;; color of an unselected block
    (field [UNSELECTED-COLOR "green"])
    
    (super-new)
    
    
    ;; METHODS FROM INTERFACE SWidget<%>
    ;; -------------------------------------------------------------------------
    ;; after-tick : -> Void
    ;; GIVEN: No arguments
    ;; EFFECT: Updates this Block to the state it should have
    ;;         following a tick.
    ;; DESIGN STRATEGY: Return this object
    ;; DETAILS: A tick has no effect on this Block
    (define/public (after-tick)
      this)
    
    ;; after-button-down : Integer Integer -> Void
    ;; GIVEN: An x and a y coordinate
    ;; EFFECT: Updates this Block to the state it should have
    ;;         following a button-down mouse event at the given location.
    ;; DESIGN STRATEGY : cases on wether mouse is inside block
    (define/public (after-button-down mx my) 
      (if (in-block? mx my)
          (begin
            (set! off-mx (- mx center-x))
            (set! off-my (- my center-y))
            (set! selected? true))
          this))
    
    ;; after-button-up : Integer Integer -> Void
    ;; GIVEN: An x and a y coordinate
    ;; EFFECT: Updates this Block to the state it should have
    ;;         following a button-up mouse event at the given location.
    ;; DESIGN STRATEGY : update this object
    (define/public (after-button-up mx my)
      (set! selected? false))
    
    ;; after-drag : Integer Integer -> Void
    ;; GIVEN: An x and a y coordinate
    ;; EFFECT: Updates this Block to the state it should have
    ;;         following a drag mouse event at the given location.
    ;; DESIGN STRATEGY : cases on wether the block is selected
    (define/public (after-drag mx my)
      (if selected?
          (selected-block-after-drag mx my)
          this))
    
    ;; after-key-event : KeyEvent -> Void
    ;; GIVEN: a key event
    ;; EFFECT: updates this widget to the state it should have
    ;;         following the given key event
    (define/public (after-key-event kev)
      this)
    
    ;; add-to-scene : Scene -> Scene
    ;; GIVEN: a scene
    ;; RETURNS: a scene like the given one, but with this object
    ;;          painted on it.
    ;; DESIGN STRATEGY : cmobine simpler function
    (define/public (add-to-scene scene)
      (place-image (get-block-image) center-x center-y scene))
    
    ;; METHODS FROM INTERFACE Block<%>
    ;; -------------------------------------------------------------------------
    ;; update-x : Integer -> Void
    ;; GIVEN: A displacement in the x direction
    ;; EFFECT: Adds the given displacement to this Blocks center-x attribute
    ;; DESIGN STRATEGY : update this object
    (define/public (update-x dx)
      (set! center-x (+ center-x dx)))
    
    ;; update-y : Integer -> Void
    ;; GIVEN: A displacement in the x direction
    ;; EFFECT: Adds the given displacement to this Blocks center-x attribute
    ;; DESIGN STRATEGY : update this object
    (define/public (update-y dy)
      (set! center-y (+ center-y dy)))
    
    ;; update-non-teammates : ListOfBlock<%> -> Void
    ;; GIVEN: A ListOfBlock
    ;; EFFECT: Sets this Blocks lists of non-teammates to be the given
    ;;         ListOfBlock
    ;; DESIGN STRATEGY : update this object
    (define/public (update-non-teammates new-non-teammates)
      (set! non-teammates new-non-teammates))
    
    ;; new-block-added : Block<%> -> Void
    ;; GIVEN: A Block
    ;; EFFECT: Appends the given Block to this Blocks list of non-teammates
    ;; DESIGN STRATEGY : update this object
    (define/public (new-block-added new-block)
      (set! non-teammates (append (list new-block) non-teammates)))
    
    ;; get-team : -> ListOfBlock<%>
    ;; GIVEN: No arguments
    ;; RETURNS: the teammates of this block
    ;; DESIGN STRATEGY : return a value from this object
    (define/public (get-team)
      teammates)
    
    ;; add-teammate: Block<%> -> Void
    ;; GIVEN: No arguments
    ;; EFFECT: adds the given block to this block's team
    ;; DESIGN STRATEGY : call a general function combine-teams
    (define/public (add-teammate other-block)
      (combine-teams
       (append
        (list other-block)
        (send other-block get-team)))) 
    
    ;; update-teammates : ListOfBlock<%> -> Void
    ;; GIVEN: A ListOfBlock
    ;; EFFECT: Sets this Blocks teammates attribute to be the given ListOfBlock
    ;; DESIGN STRATEGY : update this object
    (define/public (update-teammates new-teammates)
      (set! teammates (append teammates new-teammates)))
    
    ;; combine-teams : ListOfBlock<%> -> Void
    ;; GIVEN: A ListOfBlock that represents a team that is not this Blocks
    ;;        team
    ;; EFFECT: Combines this blocks team with the given team
    ;; DESIGN STRATEGY : update this object
    (define/public (combine-teams that-team)
      (local ((define current-teammates teammates)
              (define this-team (append (list this) current-teammates)))
        (begin
          (update-list-of-teams that-team this-team)
          (update-list-of-teams (append (list this) current-teammates) that-team))))

    ;; update-list-of-teams : ListOfBlock<%> ListOfBlock<%> -> Void
    ;; GIVEN : two distinct teams to be combined
    ;; EFFECT : updates the list of teams by adding every block from team2 to team1
    ;; DESIGN STRATEGY : update the list
    (define (update-list-of-teams team1 team2)
      (for-each
           (lambda (t)
             (send t update-teammates team1))
           team2))

    
    ;; block-x : -> Integer
    ;; GIVEN: No arguments
    ;; RETURNS: The x coordinate of the center of this Block
    ;; DESIGN STRATEGY : return a value from this object
    (define/public (block-x)
      center-x)
    
    ;; block-y : -> Integer
    ;; GIVEN: No arguments
    ;; RETURNS: The y coordinate of the center of this Block
    ;; DESIGN STRATEGY : return a value from this object
    (define/public (block-y)
      center-y)
    
    ;; get-block-image : -> Image
    ;; GIVEN: No arguments.
    ;; RETURNS: An image of this Block
    ;; DESIGN STRATEGY : combine simpler function
    (define/public (get-block-image)
      (if selected?
          (rectangle SIDE-LEN SIDE-LEN "outline" SELECTED-COLOR )
          (rectangle SIDE-LEN SIDE-LEN "outline" UNSELECTED-COLOR )))
    
    ;; FUNCTIONS USED IN LOCAL SCOPE :
    ;; -------------------------------------------------------------------------
    ;; selected-block-after-drag : Integer Integer -> Void
    ;; GIVEN: An x and a y coordinate
    ;; WHERE: This Block is selected
    ;; EFFECT: Updates this block to the state it should have
    ;;         following a drag mouse event at the given location
    ;; DETAILS: The displacement of this Block resulting from the drag
    ;;          is broadcast to all teammates of this Block so they can
    ;;          have their locations altered by the same displacement and the
    ;;          team will move in rigid motion.
    ;; DESIGN STRATEGY : update this object
    (define (selected-block-after-drag mx my)
      (begin
        (update-teammates-x (- (- mx off-mx) center-x))
        (update-teammates-y (- (- my off-my) center-y))
        (set! center-x (- mx off-mx))
        (set! center-y (- my off-my))
        (new-teammates-after-drag)
        (non-teammates-after-drag)
        (publish-non-teammates)))
    
    ;; update-teammates-x : Integer -> Void
    ;; GIVEN: A displacement in the x direction
    ;; EFFECT: Broadcasts this displacement to all of this Blocks teammates
    ;; DESIGN STRATEGY : update the list teammates
    (define (update-teammates-x dx)
      (for-each
       (lambda (b)
         (send b update-x dx))
       teammates))
    
    ;; update-teammates-y : Integer -> Void
    ;; GIVEN: A displacement in the y direction
    ;; EFFECT: Broadcasts this displacement to all of this Blocks teammates
    ;; DESIGN STRATEGY : update the list teammates
    (define (update-teammates-y dy)
      (for-each
       (lambda (b)
         (send b update-y dy))
       teammates))
    
    ;; new-teammates-after-drag : -> Void
    ;; GIVEN: No arguments
    ;; EFFECT: Iterates through this Blocks list of non-teammates and adds any
    ;;         that it intersects with to this Blocks team
    ;; DESIGN STRATEGY : update the list non-teammates
    (define (new-teammates-after-drag)
      (for-each
       (lambda (b)
         (add-if-intersects b))
       non-teammates))
    
    ;; add-if-intersects : Block<%> -> Void
    ;; GIVEN: A Block
    ;; EFFECT: If the given Block intersects with this Block
    ;;         then the given Block is added to this Blocks team.  Otherwise
    ;;         it has no effect.
    ;; DESIGN STRATEGY : cases on wether the block intersects or not
    (define (add-if-intersects that-block)
      (if (intersects? that-block)
          (add-teammate that-block)
          this))
    
    ;; intersects? : Block<%> -> Boolean
    ;; GIVEN: A Block
    ;; RETURNS: True if this Block intersects the given Block, false otherwise
    ;; DESIGN STRATEGY : combine simpler function
    (define (intersects? that-block)
      (local ((define that-block-x (send that-block block-x))
              (define that-block-y (send that-block block-y)))              
        (and (<= (abs (- that-block-x center-x)) SIDE-LEN)
             (<= (abs (- that-block-y center-y)) SIDE-LEN)))) 
    
    ;; non-teammates-after-drag : -> Void
    ;; GIVEN: No arguments
    ;; EFFECT: Modifies this Blocks list of non-teammates to the state it
    ;;         should be in after a drag event.
    ;; DESIGN STRATGEY : update this object
    (define (non-teammates-after-drag)
      (set! non-teammates
            (foldl
             add-non-teammates-after-drag
             empty 
             non-teammates)))
    
    ;; add-non-teammates-after-drag : Block<%> ListOfBlock<%> -> ListOfBlock<%>
    ;; GIVEN : a Block and a List of blocks in which given block is to be added
    ;; RETURNS : the original list with given block appended if it's not a member
    ;;           of this block's team
    ;; DESIGN STRATEGY : case on wether given block is in team
    (define (add-non-teammates-after-drag b lst)
      (if (not (member b teammates))
          (append (list b) lst)
          lst))
    
    ;; publish-non-teammates : -> Void
    ;; GIVEN : No arguments
    ;; EFFECT : Broadcasts this Blocks list of non-teammates to all of its
    ;;          teammates
    ;; DETAILS : All Blocks on the same team have the same list of non-teammates
    ;; DESIGN STRATEGY : update the list teammates
    (define (publish-non-teammates)
      (for-each
       (lambda (b)
         (send b update-non-teammates non-teammates))
       teammates))
    
    ;; in-block : Integer Integer -> Boolean
    ;; GIVEN: An x and a y coordinate
    ;; RETURNS: True if the given coordinates are inside this Block
    ;; DESIGN STRATEGY : combine simpler functions
    (define (in-block? mx my)
      (and (<= (- center-x HALF-SIDE-LEN)
               mx
               (+ center-x HALF-SIDE-LEN))
           (<= (- center-y HALF-SIDE-LEN)
               my 
               (+ center-y HALF-SIDE-LEN))))
    
    ;; for-test:selected? : -> Boolean
    ;; GIVEN: No arguments
    ;; RETURNS: True if this block is selected, false otherwise
    ;; DESIGN STRATEGY : return value from object
    (define/public (for-test:selected?)
      selected?)
    ))

(define BlockFactory%
  (class* object% (SWidget<%>)
    
    ;; the world to which the factory adds blocks
    (init-field world)  
    
    (super-new)
    
    ;; METHODS FROM INTERFACE SWidget<%>
    ;; -------------------------------------------------------------------------
    ;; after-key-event : KeyEvent -> Void
    ;; GIVEN: The representation of a KeyEvent
    ;; EFFECT: if the given KeyEvent is the BLOCK-KEY then a new block
    ;;         is added to this BlockFactory's world.  All other KeyEvents
    ;;         are ignored
    ;; DESIGN STRATEGY : divide into cases based on kev
    (define/public (after-key-event kev)
      (cond
        [(key=? kev BLOCK-KEY)
         (local
           ((define current-blocks (send world get-blocks))
            (define x (send world get-x))
            (define y (send world get-y))
            (define new-block (make-block x y current-blocks)))
           (send world add-block new-block))]
        [else this]))
    
    ;; the BlockFactory has no other behavior
    
    ;; after-tick : -> Void
    ;; GIVEN: No arguments
    ;; EFFECT: Updates this BlockFactory to the state it should be in after a
    ;;         tick of the clock.
    ;; DETAILS: A BlockFactory is unchanged by a tick of the clock
    (define/public (after-tick) this)
    
    ;; after-button-down : -> Void
    ;; GIVEN: An x and a y coordinate
    ;; EFFECT: Updates this BlockFactory to the state it should be in after a
    ;;         button-down MouseEvent
    ;; DETAILS: A BlockFactory is unchanged by a button-down MouseEvent
    (define/public (after-button-down mx my) this)
    
    ;; after-button-down : -> Void
    ;; GIVEN: An x and a y coordinate
    ;; EFFECT: Updates this BlockFactory to the state it should be in after a
    ;;         button-up MouseEvent
    ;; DETAILS: A BlockFactory is unchanged by a button-up MouseEvent
    (define/public (after-button-up mx my) this)
    
    ;; after-button-down : -> Void
    ;; GIVEN: An x and a y coordinate
    ;; EFFECT: Updates this BlockFactory to the state it should be in after a
    ;;         drag MouseEvent
    ;; DETAILS: A BlockFactory is unchanged by a drag MouseEvent
    (define/public (after-drag mx my) this)
    
    ;; add-to-scene : Image -> Image
    ;; GIVEN: An Image
    ;; RETURNS: The given Image with an Image of this BlockFactory painted
    ;;          onto it
    ;; DETAILS: There is no Image of a BlockFactory so the ginen Image is
    ;;           returned unaltered
    (define/public (add-to-scene s) s)
    ))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; make-block : Integer Integer ListOfBlock<%> -> Block<%>
;; GIVEN: The x and y coordinates of the Block and a ListOfBlock containing
;;        all the Blocks currently in the world
;; RETURNS: A new Block at the given position
(define (make-block x y lob)
  (new Block%
       [center-x x]
       [center-y y]
       [off-mx 0]
       [off-my 0]
       [selected? false]
       [teammates empty]
       [non-teammates lob]))

;; make-playground : -> PlaygroundState<%>
;; GIVEN: No arguments
;; RETURNS: A PlaygroundState with an initially empty blocks attribute
;;          and a BlockFactory
(define (make-playground)
  (local
    ((define the-world
       (new PlaygroundState%
            [canvas-width 500]
            [canvas-height 600]))
     (define the-factory
       (new BlockFactory%
            [world the-world])))
    (begin
      (send the-world add-stateful-widget the-factory)
      the-world)))



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; TESTS:

(define TEST-WORLD (make-playground))
(send TEST-WORLD for-test:after-key-event "c")
(send TEST-WORLD for-test:after-key-event BLOCK-KEY)
(send TEST-WORLD for-test:after-tick)
(define INITIAL-BLOCK-X (send (first (send TEST-WORLD get-blocks)) block-x))
(define INITIAL-BLOCK-Y (send (first (send TEST-WORLD get-blocks)) block-y))
(send TEST-WORLD for-test:after-mouse-event 10 10 MOUSE-BUTTON-UP)
(send TEST-WORLD for-test:after-key-event BLOCK-KEY)
(define SECOND-BLOCK-X (send (first (send TEST-WORLD get-blocks)) block-x))
(define SECOND-BLOCK-Y (send (first (send TEST-WORLD get-blocks)) block-y))
(send TEST-WORLD for-test:after-mouse-event 400 400 MOUSE-BUTTON-UP)
(send TEST-WORLD for-test:after-key-event BLOCK-KEY)
(send TEST-WORLD for-test:after-mouse-event 10 10 MOUSE-BUTTON-DOWN)
(define SELECTED-AFTER-BUTTON-DOWN
  (send (second (send TEST-WORLD get-blocks)) for-test:selected?))
(send TEST-WORLD for-test:after-mouse-event 241 291 MOUSE-DRAG)
(send TEST-WORLD for-test:after-mouse-event 300 300 MOUSE-DRAG)
(send TEST-WORLD for-test:after-mouse-event 300 300 "move")
(define TEAM-LENGTH
  (length (send (second (send TEST-WORLD get-blocks)) get-team)))

(begin-for-test
  (check-equal? INITIAL-BLOCK-X 250
                "The x coordinate of the block should be 250")
  (check-equal? INITIAL-BLOCK-Y 300
                "The y coordinate of the block should be 300")
  (check-equal? SECOND-BLOCK-X 10
                "The x coordinate of the block should be 250")
  (check-equal? SECOND-BLOCK-Y 10
                "The x coordinate of the block should be 250")
  (check-equal? SELECTED-AFTER-BUTTON-DOWN true
                "The block should be selected after the button down")
  (check-equal? TEAM-LENGTH 1
                "The length of the blocks team should be one"))

;; Tests for image functions

(define IMG-TEST-WORLD (make-playground))
(define IMG-TEST-WORLD-2 (make-playground))
(send IMG-TEST-WORLD for-test:after-key-event BLOCK-KEY)
(define TEST-IMG-1
  (place-image
   (rectangle
    20
    20
    "outline"
    "green")
   250
   300
   (empty-scene 500 600)))

(begin-for-test
  (check-equal? (send IMG-TEST-WORLD for-test:to-scene) TEST-IMG-1
                "The two images should be the same"))

(define TEST-IMG-2
  (place-image
   (rectangle
    20
    20
    "outline"
    "red")
   250
   300
   (empty-scene 500 600)))

(send IMG-TEST-WORLD-2 for-test:after-key-event BLOCK-KEY)
(send IMG-TEST-WORLD-2 for-test:after-mouse-event 250 300 MOUSE-BUTTON-DOWN)

(begin-for-test
  (check-equal? (send IMG-TEST-WORLD-2 for-test:to-scene) TEST-IMG-2
                "The two images should be the same"))