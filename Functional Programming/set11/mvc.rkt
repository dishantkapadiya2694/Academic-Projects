#lang racket

(require rackunit)
(require "extras.rkt")
(require "Model.rkt")
(require "ParticleWorld.rkt")
(require "ControllerFactory.rkt")
(require "Model-test.rkt")

(provide run)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; CONSTANTS :

;;; canvas constants :
(define CANVAS-WIDTH 600)
(define CANVAS-HEIGHT 500)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; FUNCTIONS :

;;; run : PosReal -> Void
;;; GIVEN : a frame rate, in sec/tick
;;; EFFECT : creates and runs the MVC simulation with the given frame rate
;;; DESIGN STRATEGY : use templete of big-bang
(define (run rate)
  (let* ((m (new Model%))
         (w (make-world m CANVAS-WIDTH CANVAS-HEIGHT)))
    (begin
      (send w add-widget
            (new ControllerFactory%
                 [m m]
                 [w w]
                 [center-x (/ CANVAS-WIDTH 2)]
                 [center-y (/ CANVAS-HEIGHT 2)]))
      (send w run rate))))