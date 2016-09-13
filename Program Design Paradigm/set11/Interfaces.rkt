#lang racket
;;; This file enumerates all the interfaces needed for implementation of various
;;; classes across the program. It also contains structures which are used to
;;; exchange values between classes.
(provide SWidget<%>
         Controller<%>
         Model<%>
         (struct-out set-position) 
         (struct-out incr-velocity)
         (struct-out report-position)
         (struct-out report-velocity)
         (struct-out set-paused))

;;; Every stable (stateful) object that lives in the world must implement the
;;; SWidget<%> interface.
(define SWidget<%>
  (interface ()
    ;; -> Void
    ;; GIVEN : no arguments
    ;; EFFECT : updates this widget to the state it should have
    ;; following a tick.
    after-tick          

    ;; Integer Integer -> Void
    ;; GIVEN : a location
    ;; EFFECT : updates this widget to the state it should have
    ;; following the specified mouse event at the given location.
    after-button-down
    after-button-up
    after-drag

    ;; KeyEvent : KeyEvent -> Void
    ;; GIVEN : a key event
    ;; EFFECT : updates this widget to the state it should have
    ;; following the given key event
    after-key-event     

    ;; Scene -> Scene
    ;; GIVEN : a scene
    ;; RETURNS : a scene like the given one, but with this object
    ;; painted on it.
    add-to-scene
    ))

;;; Extends SWidget<%>, every controller must implements this interface
(define Controller<%>    
  (interface (SWidget<%>)
    
    ;; Signal -> Void
    ;; GIVEN : a Signal
    ;; EFFECT : receive a signal from the model and adjust controller
    ;;          accordingly 
    receive-signal
    ))

;;; Enumerates various methods needed to send/fetch data to/from model.
(define Model<%>
  (interface ()
    
    ;; -> Void
    ;; GIVEN : no arguments
    ;; EFFECT : updates Model to the state it should have
    ;;          following a tick.
    after-tick        
    
    ;; Controller<%> -> Void
    ;; GIVEN : a newly created controller to be registered
    ;; EFFECT : Registers the given controller to receive signal
    register          
    
    ;; Command -> Void
    ;; GIVEN : a command to be executed
    ;; EEFECT : Executes the given command
    execute-command   
    ))

;;; protocol: 
;;; model sends the controller an initialization signal as soon as it registers.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; DATA DEFINITIONS FOR COMMUNICATING WITH MODEL

;;; A Command is either of :
;;;   --(make-set-position pos-x pos-y)
;;;   --(make-incr-velocity dv-x dv-y)
;;; Interpretations :
;;; (make-set-position Integer Integer) : an instance of set-position structure
;;;                                       used to pass new values of the position
;;; (make-incr-velocity Integer Integer): an instance of incr-velocity structure
;;;                                       used to pass values by which the velocity
;;;                                       should change
;;; DESTRUCTOR TEMPLETE :
#;(define (command-fn cmd)
    (cond
      [(set-position? cmd)...]
      [(incr-velocity? cmd)...]))

;;; A Signal is one of
;;;    -- (make-report-position pos-x pos-y)
;;;    -- (make-report-velocity vel-x vel-y)
;;; Interpretations :
;;; (make-report-position pos-x pos-y) : an instance of report-position structure
;;;                                      used to pass new values of the position
;;; (make-report-velocity vel-x vel-y) : an instance of report-velocity structure
;;;                                      used to pass new values of the velocity
;;; DESTRUCTOR TEMPLETE :
#;(define (signal-fn sig)
    (cond
      [(report-position? sig)...]
      [(report-velocity? sig)...]))

(define-struct set-position (pos-x pos-y) #:transparent)
;;; A Set-Position is a (make-set-position Integer Integer)
;;; Intrepretation:
;;; pos-x is the new x-coordinate of the particle
;;; pos-y is the new y-coordinate of the particle
;;;
;;; DESTRUCTOR TEMPLETE :
#;(define (set-position-fn sp)
    (...
     (set-position-pos-x sp)
     (set-position-pos-y sp)))

(define-struct incr-velocity (dv-x dv-y) #:transparent)
;;; A Incr-Velocity is a (make-incr-velocity Integer Integer)
;;; Intrepretation:
;;; vel-x is the new x velocity of the particle
;;; vel-y is the new y velocity of the particle
;;;
;;; DESTRUCTOR TEMPLETE :
#;(define (incr-velocity-fn sv)
    (...
     (incr-velocity-pos-x sv)
     (incr-velocity-pos-y sv)))

(define-struct report-position (pos-x pos-y) #:transparent)
;;; A Report-Position is a (make-report-position Integer Integer)
;;; Intrepretation:
;;; pos-x is the current x-coordinate of the particle
;;; pos-y is the current y-coordinate of the particle
;;;
;;; DESTRUCTOR TEMPLETE :
#;(define (report-position-fn rp)
    (...
     (report-position-pos-x rp)
     (report-position-pos-y rp)))

(define-struct report-velocity (vel-x vel-y) #:transparent)
;;; A Report-Velocity is a (make-report-velocity Integer Integer)
;;; Intrepretation:
;;; vel-x is the current x-velocity of the particle
;;; vel-y is the current y-velocity of the particle
;;;
;;; DESTRUCTOR TEMPLETE :
#;(define (report-velocity-fn rv)
    (...
     (report-velocity-pos-x rv)
     (report-velocity-pos-y rv)))

(define-struct set-paused (paused?) #:transparent)
;;; A Set-Paused is a (make-set-paused Boolean)
;;; Interpretation:
;;; paused? states wether the particle is paused or not
;;;
;;; DESTRUCTOR TEMPLETE :
#;(define (set-paused sp)
    (...
     (set-paused sp)))