;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-beginner-reader.ss" "lang")((modname coffee-machine) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f () #f)))
(check-location "02" "coffee-machine.rkt")

(require rackunit)
(require "extras.rkt")

(provide make-Machine
         Machine-coffee
         Machine-h-choco
         Machine-bank
         Machine-deposit
         Machine?
         initial-machine
         machine-next-state
         machine-output
         machine-remaining-coffee
         machine-remaining-chocolate
         machine-bank
         )

;;;DATA DEFINATIONS:

(define-struct Machine
  [coffee h-choco bank deposit])

;;;Machine is a
;;;   (make-Machine coffee h-choco bank deposit)
;;;
;;;Interpretation
;;;   coffee is the number of coffees left
;;;   h-choco is the number of hot chocolates left
;;;   bank is the amount of money received by processing order
;;;   deposit is the amount of unused money, typically, for unprocessed orders or change
;;;
;;;Machine-fn: Machine -> ??
#|(define (Machine-fn machine)
  (...
   (machine-coffee machine)
   (machine-h-choco machine)
   (machine-bank machine)
   (machine-deposit machine)
   )
  )
|#
;;;
;;;
;;;A CustomerInput is one of
;;;-- a PosInt          interpret: insert the specified amount of money, in cents
;;;-- "coffee"          interpret: request a coffee
;;;-- "hot chocolate"   interpret: request a hot chocolate
;;;-- "change"          interpret: return all the unspent money that the customer has inserted
;;;
;;;A MachineOutput is one of
;;;-- "coffee"          interpret: machine dispenses a cup of coffee
;;;-- "hot chocolate"   interpret: machine dispenses a cup of hot chocolate
;;;-- "Out of Item"     interpret: machine displays "Out of Item"
;;;-- a PosInt          interpret: machine releases the specified amount of money, in cents
;;;-- "Nothing"         interpret: the machine does nothing
;;;
;;;
;;;initial-machine: NonNegInt NonNegInt -> MachineState
;;;GIVEN: a number of cups of coffee and of hot chocolate
;;;RETURNS: the state of a machine loaded with the given number of cups of coffee and of hot chocolate, with an empty bank.
;;;
;;;EXAMPLES: (initial-machine 5 4) = (make-Machine 5 4 0 0)
;;;          (initial-machine 5 0) = (make-Machine 5 0 0 0)
;;;          (initial-machine 0 4) = (make-Machine 0 4 0 0)
;;;
;;;DESIGN STRATEGY: combine simple function
;;;
;;;FUNCTION DESIGN:

(define (initial-machine no-of-coffee no-of-h-chocolate)
  (make-Machine no-of-coffee no-of-h-chocolate 0 0)   ;initialize with 0 balance in bank and deposits
  ) 

;;;
;;;TESTS:

(begin-for-test
  (check-equal? (initial-machine 5 4) (make-Machine 5 4 0 0))
  (check-equal? (initial-machine 5 0) (make-Machine 5 0 0 0))
  (check-equal? (initial-machine 0 4) (make-Machine 0 4 0 0))
  )

;;;
;;;
;;;machine-next-state : MachineState CustomerInput -> MachineState
;;;GIVEN: a machine state and a customer input
;;;RETURNS: the state of the machine that should follow the customer's input
;;;
;;;EXAMPLES: (machine-next-state (initial-machine 5 4) 500) = (make-Machine 5 4 0 500)
;;;          (machine-next-state (make-Machine 3 6 0 500) "coffee") = (make-Machine 2 6 150 350)
;;;          (machine-next-state (make-Machine 9 6 100 500) "hot chocolate") = (make-Machine 9 5 160 440)
;;;          (machine-next-state (make-Machine 2 6 0 40) "change") = (make-Machine 2 6 0 0)
;;;
;;;DESIGN STRATEGY: use templete for Machine on m-state
;;;
;;;FUNCTION DESIGN:

(define (machine-next-state m-state c-input)
  (cond
    [(integer? c-input)   ;if it's an integer then customer must have inserted money. Add it to deposit.
     (make-Machine (Machine-coffee m-state)
                   (Machine-h-choco m-state)
                   (machine-bank m-state)
                   (+ (Machine-deposit m-state) c-input))]
    
    [(string=? c-input "coffee")   ;if it's coffee, check that customer have paid for it, we have coffee available
     (if (>= (Machine-deposit m-state) 150)
         (if (= (machine-remaining-coffee m-state) 0)
             (machine-output m-state "Out of Item")
             (make-Machine (- (Machine-coffee m-state) 1)   ;if yes, then reduce available coffee by 1 and transfer 150 to bank from deposit
                           (Machine-h-choco m-state)
                           (+ (machine-bank m-state) 150)
                           (- (Machine-deposit m-state) 150))
             )
         (machine-output m-state "nothing")
         )
     ]
    
    [(string=? c-input "hot chocolate")   ;if it's hot chocolate, check that customer have paid for it, we have hot chocolate available
     (if (>= (Machine-deposit m-state) 60)
         (if (= (machine-remaining-chocolate m-state) 0)
             (machine-output m-state "Out of Item")
             (make-Machine (Machine-coffee m-state)   ;if yes, then reduce available hot chocolate by 1 and transfer 60 to bank from deposit
                           (- (Machine-h-choco m-state) 1)
                           (+ (machine-bank m-state) 60)
                           (- (Machine-deposit m-state) 60))
             )
         (machine-output m-state "nothing")
         )
     ]
    
    [(string=? c-input "change")   ;if customer wants change, refund all the amount left in deposit
     (make-Machine (Machine-coffee m-state)
                   (Machine-h-choco m-state)
                   (machine-bank m-state)
                   (- (Machine-deposit m-state) (Machine-deposit m-state)))
     ]
    
    [else (machine-output m-state "nothing")]
    )
  )

;;;
;;;TESTS:

(begin-for-test
  (check-equal? (machine-next-state (initial-machine 5 4) 500) (make-Machine 5 4 0 500))
  (check-equal? (machine-next-state (make-Machine 3 6 0 500) "coffee") (make-Machine 2 6 150 350))
  (check-equal? (machine-next-state (make-Machine 9 6 100 500) "hot chocolate") (make-Machine 9 5 160 440))
  (check-equal? (machine-next-state (make-Machine 2 6 0 40) "change") (make-Machine 2 6 0 0))
  )

;;;
;;;
;;;machine-output : MachineState CustomerInput -> MachineOutput
;;;GIVEN: a machine state and a customer input
;;;RETURNS: a MachineOutput that describes the machine's response to the customer input
;;;
;;;EXAMPLES: (machine-output (make-Machine 5 4 0 40) "coffee") = "nothing"
;;;          (machine-output (make-Machine 5 4 0 150) "coffee") = "coffee"
;;;          (machine-output (make-Machine 5 0 70 100) "hot chocolate") = "Out of Item"
;;;          (machine-output (make-Machine 5 1 70 100) "hot chocolate") = "hot chocolate"
;;;          (machine-output (make-Machine 4 6 150 50) "change") = 50

(define (machine-output m-state c-input)
  (cond
    [(string=? c-input "coffee")   ;if it's coffee, check that customer have paid for it, we have coffee available
     (if (>= (Machine-deposit m-state) 150)
         (if (= (machine-remaining-coffee m-state) 0)
             (machine-output m-state "Out of Item")
             "coffee"   ;if yes, output coffee
             )
         (machine-output m-state "nothing")
         )]
    
    [(string=? c-input "hot chocolate")   ;if it's hot chocolate, check that customer have paid for it, we have hot chocolate available
     (if (>= (Machine-deposit m-state) 60)
         (if (= (machine-remaining-chocolate m-state) 0)
             (machine-output m-state "Out of Item")
             "hot chocolate"   ;if yes, output hot chocolate
             )
         (machine-output m-state "nothing")
         )]
    
    [(string=? c-input "change") (Machine-deposit m-state)]   ;refund all in deposit
    
    [(string=? c-input "Out of Item") "Out of Item"]   ;flash Out of Item on screen
    
    [(string=? c-input "nothing") "nothing"]   ;flash nothing on screen
    )
  )

;;;
;;;TESTS:

(begin-for-test
  (check-equal? (machine-output (make-Machine 5 4 0 40) "coffee") "nothing")
  (check-equal? (machine-output (make-Machine 5 4 0 150) "coffee") "coffee")
  (check-equal? (machine-output (make-Machine 5 0 70 100) "hot chocolate") "Out of Item")
  (check-equal? (machine-output (make-Machine 5 1 70 100) "hot chocolate") "hot chocolate")
  (check-equal? (machine-output (make-Machine 4 6 150 50) "change") 50)
  )

;;;
;;;
;;;machine-remaining-coffee : MachineState -> NonNegInt
;;;GIVEN: a machine state
;;;RETURNS: the number of cups of coffee left in the machine
;;;
;;;EXAMPLES: (machine-remaining-coffee (initial-machine 5 5)) = 5
;;;          (machine-remaining-coffee (initial-machine 37 0)) = 37
;;;          (machine-remaining-coffee (initial-machine 0 4)) = 0
;;;
;;;DESIGN STRATEGY: use templete for Machine on m-state
;;;
;;;FUNCTION DESIGN:

(define (machine-remaining-coffee m-state)
  (Machine-coffee m-state))

;;;
;;;TESTS:

(begin-for-test
  (check-equal? (machine-remaining-coffee (initial-machine 5 5)) 5)
  (check-equal? (machine-remaining-coffee (initial-machine 37 0)) 37)
  (check-equal? (machine-remaining-coffee (initial-machine 0 4)) 0)
  )

;;;
;;;
;;;machine-remaining-chocolate : MachineState -> NonNegInt
;;;GIVEN: a machine state
;;;RETURNS: the number of cups of hot chocolate left in the machine
;;;
;;;EXAMPLES: (machine-remaining-chocolate (initial-machine 5 5)) = 5
;;;          (machine-remaining-chocolate (initial-machine 37 0)) = 0
;;;          (machine-remaining-chocolate (initial-machine 0 4)) = 4
;;;
;;;DESIGN STRATEGY: use templete for Machine on m-state
;;;
;;;FUNCTION DESIGN:

(define (machine-remaining-chocolate m-state)
  (Machine-h-choco m-state))

;;;
;;;TEST:

(begin-for-test
  (check-equal? (machine-remaining-chocolate (initial-machine 5 5)) 5)
  (check-equal? (machine-remaining-chocolate (initial-machine 37 0)) 0)
  (check-equal? (machine-remaining-chocolate (initial-machine 0 4)) 4)
  )

;;;
;;;
;;;machine-bank : MachineState -> NonNegInt
;;;GIVEN: a machine state
;;;RETURNS: the amount of money in the machine's bank, in cents
;;;
;;;EXAMPLES: (machine-bank (initial-machine 5 7)) = 0
;;;          (machine-bank (make-Machine 5 7 100 0)) = 100
;;;
;;;DESIGN STRATEGY: use templete for Machine on m-state
;;;
;;;FUNCTION DESIGN:

(define (machine-bank m-state)
  (Machine-bank m-state))

;;;
;;;TESTS:

(begin-for-test
  (check-equal? (machine-bank (initial-machine 5 7)) 0)
  (check-equal? (machine-bank (make-Machine 5 7 100 0)) 100)
  )

;;;PROGRAM REVIEW: The program meets all the specification mentioned in the question and produce a valid output on a valid input. Below are some full system tests.
(begin-for-test
  (check-equal? (machine-output (machine-next-state (machine-next-state (initial-machine 5 7) 200) "coffee") "change") 50)
  (check-equal? (machine-next-state (machine-next-state (initial-machine 5 7) 100) "coffee") "nothing")
  (check-equal? (machine-next-state (machine-next-state (initial-machine 0 7) 150) "coffee") "Out of Item")
  (check-equal? (machine-output (machine-next-state (machine-next-state (initial-machine 5 7) 500) "coffee") "hot chocolate") "hot chocolate")
  (check-equal? (machine-output (machine-next-state (machine-next-state (machine-next-state (initial-machine 5 7) 500) "coffee") "hot chocolate") "change") 290)
  (check-equal? (machine-output (machine-next-state (machine-next-state (initial-machine 5 0) 500) "coffee") "hot chocolate") "Out of Item")
  (check-equal? (machine-next-state (machine-next-state (initial-machine 5 7) 50) "hot chocolate") "nothing")
  (check-equal? (machine-next-state (machine-next-state (initial-machine 0 0) 150) "hot chocolate") "Out of Item")
  (check-equal? (machine-next-state (machine-next-state (initial-machine 0 0) 150) "pepsi") "nothing")
  (check-equal? (machine-output (machine-next-state (machine-next-state (initial-machine 1 6) 300) "coffee") "coffee") "Out of Item")
  (check-equal? (machine-output (machine-next-state (machine-next-state (initial-machine 5 7) 200) "coffee") "hot chocolate") "nothing")
  )