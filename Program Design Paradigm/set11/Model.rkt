#lang racket

;;; The model consists of a particle, bouncing within a box of 150 X 100.
;;; It accepts commands and reports state of particle when its status changes.
(require rackunit)
(require "extras.rkt")
(require "PerfectBounce.rkt")
(require "Interfaces.rkt")

(provide Model%)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; DATA DEFINATIONS :

;;; A ListOfController<%> is:
;;;   --empty
;;;   --(cons Controller<%> ListOfController<%>)
;;;
;;; Interpretations:
;;; empty                                    : an empty list of controllers
;;; (cons Controller<%> ListOfController<%>) : a controller followed by a list
;;;                                            of controller
#;(define (loc-fn loc)
    (cond
      [(empty? loc)...]
      [else ...]))

;;; A Particle is an instance of the struct particle provided by the file
;;; "PerfectBounce.rkt". This struct stores information like coordinates and
;;; Velocities of particle in both the axes.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; CLASSES :

;;; A Model is a (new Model%)
;;;
;;; A Model represents an entity where all the information regarding particle
;;; can be found. It also has a list of controllers who have subscribed to all the
;;; information of particle.
(define Model%
  (class* object% (Model<%>)
    
    ;; rectangle in which particle moves
    (field [boundary (make-rect 0 150 0 100)])
    
    ;; the initial position of the particle
    (field [INITIAL-X (/ (+ (rect-xmin boundary) (rect-xmax boundary)) 2)])
    (field [INITIAL-Y (/ (+ (rect-ymin boundary) (rect-ymax boundary)) 2)])
    
    ;; particle in the model
    (field [particle (make-particle INITIAL-X INITIAL-Y 0 0)])
    
    ;; list of controllers who watches the behaviour of the particle
    (field [controllers empty])
    
    ;; field which indicates wether the model is paused or not
    (field [paused? false])
    
    (super-new)
    
    ;; after-tick : -> Void
    ;; GIVEN : No arguments
    ;; EFFECT : updates the object to a state it should follow after-tick
    ;; DETAILS : moves the particle by the velocity it has and then reports
    ;;           position and velocity
    ;; DESIGN STRATEGY : cases on paused?
    (define/public (after-tick)
      (if paused?
          (begin
            (publish-position controllers)
            (publish-velocity controllers))
          (begin
            (set! particle (particle-after-tick particle boundary))
            (publish-position controllers)
            (publish-velocity controllers))))
    
    ;; register : Controller<%> -> Void
    ;; GIVEN : a controller to be registerd in this model
    ;; EFFECT : register the new controller and send it data about current state
    ;;          of the particle
    ;; DESIGN STRATEGY : update this object and send data to another object
    (define/public (register c)
      (begin
        (set! controllers (cons c controllers))
        (publish-position (list c))
        (publish-velocity (list c))))
    
    ;; execute-command : Command -> Void
    ;; GIVEN : a command which helps in making right updates to the object
    ;; EFFECT : decodes the command, executes it, and sends updates to the
    ;;          controllers
    ;; DESIGN STRATEGY : divide cases on cmd
    (define/public (execute-command cmd)
      (cond
        [(set-position? cmd)
         (begin
           (set! particle (particle-after-set-position cmd))
           (publish-position controllers))]
        [(incr-velocity? cmd)
         (begin
           (set! particle (particle-after-incr-velocity cmd))
           (publish-velocity controllers))]
        [(set-paused? cmd)
         (set! paused? (set-paused-paused? cmd))]))
    
    ;; particle-after-set-position : Command -> Particle
    ;; GIVEN : a command which helps in making object with new values
    ;; RETURNS : an instance of Particle with new position
    ;; DESIGN STRATEGY : combine simpler functions
    (define (particle-after-set-position cmd)
      (make-particle (next-pos (set-position-pos-x cmd) (rect-xmax boundary))
                     (next-pos (set-position-pos-y cmd) (rect-ymax boundary))
                     (particle-vx particle)
                     (particle-vy particle)))
    
    ;; next-pos : Integer NonNegInt -> NonNegInt
    ;; GIVEN : the value of next position according to controllers
    ;; RETURNS : a particle with valid positions
    ;; DETAILS : any position which is outside the boundary is not valid
    ;; DESIGN STRATEGY : cases on val
    (define (next-pos val max)
      (cond
        [(< val 0) 0]
        [(> val max) max]
        [else val]))
    
    ;; particle-after-set-position : Command -> Particle
    ;; GIVEN : a command which helps in making object with new values
    ;; RETURNS : an instance of Particle with new velocity
    ;; DESIGN STRATEGY : combine simpler functions
    (define (particle-after-incr-velocity cmd)
      (make-particle (particle-x particle)
                     (particle-y particle)
                     (+ (particle-vx particle) (incr-velocity-dv-x cmd))
                     (+ (particle-vy particle) (incr-velocity-dv-y cmd))))
    
    ;; publish-position : ListOfController<%> -> Void
    ;; GIVEN : no arguments
    ;; EFFECT : no effect to this object
    ;; DETAILS : publishes the current position of the particle to all the controllers
    ;; DESIGN STRATEGY : send data to all the controllers
    (define (publish-position controllers)
      (let ((msg (make-report-position (particle-x particle) (particle-y particle))))
        (for-each
         (lambda (obs) (send obs receive-signal msg))
         controllers)))
    
    ;; publish-velocity : ListOfController<%> -> Void
    ;; GIVEN : no arguments
    ;; EFFECT : no effect to this object
    ;; DETAILS : publishes the current velocity of the particle to all the controllers
    ;; DESIGN STRATEGY : send data to all the controllers
    (define (publish-velocity controllers)
      (let ((msg (make-report-velocity (particle-vx particle) (particle-vy particle))))
        (for-each
         (lambda (obs) (send obs receive-signal msg))
         controllers)))
    
    ;; for-test:particle : -> Particle
    ;; GIVEN : no arguments
    ;; RETURNS : current instance of particle
    ;; DESIGN STRATEGY : return a value of this object
    (define/public (for-test:particle)
      particle)
    
    ;; for-test:controllers : -> ListOfController<%>
    ;; GIVEN : no arguments
    ;; RETURNS : a list of all the controllers in the world
    ;; DESIGN STRATEGY : return a value of this object
    (define/public (for-test:controllers)
      controllers)
    
    ;; for-test:paused? : -> Boolean
    ;; GIVEN : no arguments
    ;; RETURNS : true if the particle is in paused state
    ;; DESIGN STRATEGY : return a value of this object
    (define/public (for-test:paused?)
      paused?)
    ))