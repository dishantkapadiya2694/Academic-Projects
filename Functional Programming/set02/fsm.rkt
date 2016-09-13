;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-beginner-reader.ss" "lang")((modname fsm) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f () #f)))
(check-location "02" "fsm.rkt")

(require rackunit)
(require "extras.rkt")

(provide initial-state
         next-state
         accepting-state?
         error-state?)

;;;DATA DEFINATION: a MachineState (state) is one of the following
;;;                       ---"q0"
;;;                       ---"q1"
;;;                       ---"q2"
;;;                       ---"q3"
;;;
;;;INTERPRETATION: "q0" -> starting state where acceptable inputs are a, b & c
;;;                "q1" -> intermediate state where acceptable inputs are a, b & d
;;;                "q2" -> final state where acceptable inputs are e & f
;;;                "q3" -> error state which is reached when an invalid input is encountered
;;;
;;;state-fn: State -> ??
#|
(define (state-fn state)
  (cond
    [(string=? state "q0") ...]
    [(string=? state "q1") ...]
    [(string=? state "q2") ...]
    [(string=? state "q3") ...]
    )
  )
|#
;;;
;;;
;;;initial-state : Number -> State
;;;GIVEN: a number
;;;RETURNS: a representation of the initial state of your machine.  The given number is ignored.
;;;
;;;EXAMPLES: (initial-state 24) = "q0"
;;;          (initial-state 0) = "q0"
;;;          (initial-state -21) = "q0"
;;;
;;;DESIGN STRATEGY: combine simpler functions
;;;
;;;FUNCTION DESIGN:

(define (initial-state num)
  "q0")   ;Ignore the number

;;;
;;;TESTS:

(begin-for-test
  (check-equal? (initial-state 24) "q0")
  (check-equal? (initial-state 0) "q0")
  (check-equal? (initial-state -21) "q0")
  )

;;;
;;;
;;;next-state : State MachineInput -> State
;;;GIVEN: a current state of the machine and a machine input
;;;RETURNS: the state that should follow the given input.
;;;
;;;EXAMPLE: (next-state "q0" "a") = "q0"
;;;         (next-state "q0" "b") = "q0"
;;;         (next-state "q0" "c") = "q1"
;;;         (next-state "q0" "e") = "q3"
;;;         (next-state "q0" "d") = "q3"
;;;         (next-state "q1" "a") = "q1"
;;;         (next-state "q1" "b") = "q1"
;;;         (next-state "q1" "d") = "q2"
;;;         (next-state "q1" "q") = "q3"
;;;         (next-state "q1" "z") = "q3"
;;;         (next-state "q2" "e") = "q2"
;;;         (next-state "q2" "f") = "q2"
;;;         (next-state "q2" "a") = "q3"
;;;
;;;DESIGN STRATEGY: use templete for MachineState on state
;;;
;;;FUNCTION DESIGN:

(define (next-state state machine-input)
  (cond
    [(string=? state "q0")   ;Machine outputs for state "q0" based on inputs
     (cond
       [(string=? machine-input "a") "q0"]
       [(string=? machine-input "b") "q0"]
       [(string=? machine-input "c") "q1"]
       [else "q3"])]
    
    [(string=? state "q1")   ;Machine outputs for state "q1" based on inputs
     (cond
       [(string=? machine-input "a") "q1"]
       [(string=? machine-input "b") "q1"]
       [(string=? machine-input "d") "q2"]
       [else "q3"])]
    
    [(string=? state "q2")   ;Machine outputs for state "q2" based on inputs
     (cond
       [(string=? machine-input "e") "q2"]
       [(string=? machine-input "f") "q2"]
       [else "q3"])]
    )
  )

;;;
;;;TESTS:

(begin-for-test
  (check-equal? (next-state "q0" "a") "q0")
  (check-equal? (next-state "q0" "b") "q0")
  (check-equal? (next-state "q0" "c") "q1")
  (check-equal? (next-state "q0" "e") "q3")
  (check-equal? (next-state "q0" "d") "q3")
  (check-equal? (next-state "q1" "a") "q1")
  (check-equal? (next-state "q1" "b") "q1")
  (check-equal? (next-state "q1" "d") "q2")
  (check-equal? (next-state "q1" "q") "q3")
  (check-equal? (next-state "q1" "z") "q3")
  (check-equal? (next-state "q2" "e") "q2")
  (check-equal? (next-state "q2" "f") "q2")
  (check-equal? (next-state "q2" "a") "q3")
  )

;;;
;;;
;;;accepting-state? : State -> Boolean
;;;GIVEN: a state of the machine
;;;RETURNS: true iff the given state is a final (accepting) state
;;;
;;;EXAMPLE: (accepting-state? "q0") = false
;;;         (accepting-state? "q1") = false
;;;         (accepting-state? "q2") = true
;;;         (accepting-state? "q3") = false
;;;
;;;DESIGN STRATEGY: combine simpler function
;;;
;;;FUNCTION DESIGN:

(define (accepting-state? state)
  (string=? state "q2")   ;returns true if the current state is "q2" (accepting state)
  )

;;;
;;;TESTS:

(begin-for-test
  (check-equal? (accepting-state? "q0") false)
  (check-equal? (accepting-state? "q1") false)
  (check-equal? (accepting-state? "q2") true)
  (check-equal? (accepting-state? "q3") false)
  )

;;;
;;;
;;;error-state? : State -> Boolean
;;;GIVEN: a state of the machine
;;;RETURNS: true iff there is no path (empty or non-empty) from the given state to an accepting state
;;;
;;;EXAMPLE: (error-state? "q0") = false
;;;         (error-state? "q1") = false
;;;         (error-state? "q2") = false
;;;         (error-state? "q3") = true
;;;
;;;DESIGN STRATEGY: combine simpler function
;;;
;;;FUNCTION DESIGN:

(define (error-state? state)
  (string=? state "q3")      ;returns true if the current state is "q3" (error state)
  )

;;;
;;;TEST:

(begin-for-test
  (check-equal? (error-state? "q0") false)
  (check-equal? (error-state? "q1") false)
  (check-equal? (error-state? "q2") false)
  (check-equal? (error-state? "q3") true)
  )

;;;
;;;PROGRAM REVIEW: It shows correct output for all the valid inputs. Accepts all the valid strings. Below are some tests of full system.

(begin-for-test
  (check-equal? (accepting-state? (next-state (next-state (initial-state 45) "c") "d")) true)
  (check-equal? (error-state? (next-state (next-state (initial-state 45) "a") "d")) true)
  (check-equal? (error-state? (next-state (next-state (next-state (next-state (initial-state 36) "a") "b") "c") "d")) false)
  (check-equal? (accepting-state? (next-state (next-state (next-state (next-state (initial-state 36) "c") "d") "e") "f")) true)
  (check-equal? (accepting-state? (next-state (next-state (next-state (next-state (next-state (initial-state 36) "c") "d") "e") "f") "a")) false)
  (check-equal? (accepting-state? (next-state (next-state (next-state (next-state (next-state (initial-state 36) "a") "c") "b") "d") "e")) true)
  )