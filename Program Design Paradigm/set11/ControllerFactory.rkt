#lang racket

(require "Interfaces.rkt")
(require "Controllers.rkt")
(require 2htdp/universe)
(require "Model.rkt")
(require "ParticleWorld.rkt")
(require "PerfectBounce.rkt")
(require rackunit)
(require "extras.rkt")


(provide ControllerFactory%)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; CONSTANT :

;;; Constants for the KeyEvents :
(define ADD-POSITION-CONTROLLER "p")
(define ADD-VELOCITY-CONTROLLER "v")
(define ADD-X-CONTROLLER "x")
(define ADD-Y-CONTROLLER "y")
(define ADD-XY-CONTROLLER "z")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; A ControllerFactory% is (new ControllerFactory% [w World%]
;;;                                                 [m Model%]
;;;                                                 [center-x NonNegInt]
;;;                                                 [center-y NonNegInt])
;;;
;;; A ControllerFactory% represents a class which is responsible to create
;;; various controllers for the model. These controller can manipulate data
;;; stored in the model. User interacts with the system using these controllers.
(define ControllerFactory%
  (class* object% (SWidget<%>)

    ;; the world in which the controllers will live
    (init-field w)   ; World<%>

    ;; the model to which the controllers will be connected
    (init-field m)   ; Model<%>

    ;; the coordinates of the center of the Controller
    (init-field center-x)
    (init-field center-y)

    (super-new)

    ;; after-key-event : KeyEvent -> Void
    ;; GIVEN : a KeyEvent
    ;; EFFECT : adds a controller to the world
    ;; DESIGN STRATEGY : cases on kev
    (define/public (after-key-event kev)
      (cond
        [(key=? kev ADD-POSITION-CONTROLLER) (add-viewer PositionController%)]
        [(key=? kev ADD-VELOCITY-CONTROLLER) (add-viewer VelocityController%)]
        [(key=? kev ADD-X-CONTROLLER) (add-viewer XController%)]
        [(key=? kev ADD-Y-CONTROLLER) (add-viewer YController%)]
        [(key=? kev ADD-XY-CONTROLLER) (add-viewer XYController%)]))

    ;; add-viewer : ClassName -> Void
    ;; GIVEN : name of the class of which the controller is to be created
    ;; EFFECTS : adds a desired controller to the world
    ;; DESIGN STRATEGY : send information to other class
    (define (add-viewer viewer-class)
      (send w add-widget
            (new viewer-class [model m] [center-x center-x] [center-y center-y])))

    ;; add-to-scene : Scene -> Scene
    ;; GIVEN : a base image on which information from this class is painted
    ;; RETURNS : a scene after painting the information from this class
    ;; DETAILS : this class ignores add-to-scene
    ;; DESIGN STRATEGY : return the given Scene
    (define/public (add-to-scene s) s)

    ;; after-tick : -> Void
    ;; GIVEN : no arguments
    ;; EFFECTS : updates this class to a state it should have after a tick
    ;; DETAILS : this class ignores after-tick
    (define/public (after-tick) 'controller-factory-after-tick-trap)

    ;; after-button-down : Integer Intger -> Void
    ;; GIVEN : x and y coordinates of mouse
    ;; EFFECTS : updates this class to a state it should have after button down
    ;; DETAILS : this class ignores after-button-down
    (define/public (after-button-down mx my)
      'controller-factory-after-button-down-trap)

    ;; after-drag : Integer Intger -> Void
    ;; GIVEN : x and y coordinates of mouse
    ;; EFFECTS : updates this class to a state it should have after drag
    ;; DETAILS : this class ignores after-drag
    (define/public (after-drag mx my)
      'controller-factory-after-drag-trap)

    ;; after-drag : Integer Intger -> Void
    ;; GIVEN : x and y coordinates of mouse
    ;; EFFECTS : updates this class to a state it should have after button up
    ;; DETAILS : this class ignores after-button-up
    (define/public (after-button-up mx my)
      'controller-factory-after-button-up-trap)
    ))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; TESTS:

(define TEST-MODEL
  (new Model%))

(define TEST-WORLD (make-world TEST-MODEL 600 500))

(define TEST-FACTORY
  (new ControllerFactory%
       [center-x 300]
       [center-y 250]
       [m TEST-MODEL] 
       [w TEST-WORLD]))

(begin-for-test
  (check-pred not-exn?
              (send TEST-FACTORY after-key-event ADD-POSITION-CONTROLLER))
  (check-pred not-exn?
              (send TEST-FACTORY after-key-event ADD-VELOCITY-CONTROLLER))
  (check-pred not-exn?
              (send TEST-FACTORY after-key-event ADD-X-CONTROLLER))
  (check-pred not-exn?
              (send TEST-FACTORY after-key-event ADD-Y-CONTROLLER))
  (check-pred not-exn?
              (send TEST-FACTORY after-key-event ADD-XY-CONTROLLER))
  (check-pred not-exn?
              (send TEST-FACTORY after-button-down 500 500))
  (check-pred not-exn?
              (send TEST-FACTORY after-button-up 500 500))
  (check-pred not-exn?
            (send TEST-FACTORY after-drag 500 500))
  (check-pred not-exn?
              (send TEST-FACTORY add-to-scene '()))
  (check-pred not-exn?
              (send TEST-FACTORY after-tick)))

(define (not-exn? expr)
  (not (exn? expr)))


