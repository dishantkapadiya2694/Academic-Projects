;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-beginner-reader.ss" "lang")((modname probe) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f () #f)))
(check-location "02" "probe.rkt")

(require rackunit)
(require "extras.rkt")

(provide make-probe
         probe-x
         probe-y
         probe-orientation
         probe?
         probe-at
         valid-range?
         probe-turned-left
         probe-turned-right
         probe-forward
         new-distance
         probe-north?
         probe-south?
         probe-east?
         probe-west?)

(define N "North") 
(define S "South")
(define E "East")
(define W "West")   ;String constants for 4 directions

;;;DATA DEFINATIONS:

(define-struct probe [x y orientation])

;;;A probe is a 
;;;   (make-probe Number Number String)
;;;
;;;Interpretation:
;;;   x is the x coordinate of the probe, which is always between (-153, 153) range
;;;   y is the y coordinate of the probe, which is always between (-153, 153) range
;;;   orientation is the direction in which probe is pointing i.e. North, South, East, West (either of them)
;;;
;;;probe-fn: probe -> ??
#|
(define (probe-fn pb)
  (...
   (probe-x pb)
   (probe-y pb)
   (probe-orientation pb)
   )
  )
|#
;;;
;;;
;;;probe-at: Integer Integer -> Probe
;;;GIVEN: an x-coordinate and a y-coordinate
;;;WHERE: these coordinates leave the probe entirely inside the trap
;;;RETURNS: a probe with its center at those coordinates, facing north.
;;;
;;;EXAPLES: (probe-at 30 -25) = (make-probe 30 -25 "North")
;;;         (probe-at 153 135) = (make-probe 153 135 "North")
;;;         (probe-at 160 190) = "ERROR: Invalid position"
;;;
;;;DESIGN STRATEGY: combine simpler functions
;;;
;;;FUCTION DESIGN:

(define (probe-at x-pos y-pos)
  (if (and (valid-range? x-pos) (valid-range? y-pos))   ;check if the input is valid i.e. within the trap
      (make-probe x-pos y-pos N)
      "ERROR: Invalid position"
      )
  )

;;;
;;;TESTS:

(begin-for-test
  (check-equal? (probe-at 30 -25) (make-probe 30 -25 "North"))
  (check-equal? (probe-at 153 135) (make-probe 153 135 "North"))
  (check-equal? (probe-at 160 190) "ERROR: Invalid position")
  )

;;;
;;;
;;;valid-range?: Number -> Boolean
;;;GIVEN: a number which is a coordinate of probe
;;;RETUENS: true if the coordinate is in the desired range else false
;;;
;;;EXAMPLES: (valid-range? -153) = true
;;;          (valid-range? 0) = true
;;;          (valid-range? 153) = true
;;;          (valid-range? 160) = false
;;;
;;;FUNCTION DESIGN:

(define (valid-range? num)
  (and (>= num -153) (<= num 153))
  )

;;;TESTS:

(begin-for-test
  (check-equal? (valid-range? -153) true)
  (check-equal? (valid-range? 0) true)
  (check-equal? (valid-range? 153) true)
  (check-equal? (valid-range? 160) false)
  )

;;;
;;;
;;;probe-turned-left: Probe -> Probe
;;;probe-turned-right: Probe -> Probe
;;;GIVEN: a probe whose direction is to be changed by 90° to left/right
;;;RETURN: a probe whose direction is changed by 90° to left/right
;;;
;;;EXAMPLE: (probe-turned-left (probe-at 30 -25)) = (make-probe 3 -25 "West")
;;;         (probe-turned-left (probe-turned-left (probe-at 30 -25))) = (make-probe 3 -25 "South")
;;;         (probe-turned-left (probe-turned-left (probe-turned-left (probe-at 30 -25)) = (make-probe 3 -25 "East")
;;;         (probe-turned-right (probe-at 30 -25)) = (make-probe 3 -25 "East")
;;;         (probe-turned-right (probe-turned-right (probe-at 30 -25))) = (make-probe 3 -25 "South")
;;;         (probe-turned-right (probe-turned-right (probe-turned-right (probe-at 30 -25)) = (make-probe 3 -25 "West")
;;;
;;;DESIGN STRATEGY: use templete for probe on prb
;;;
;;;FUNCTION DESIGN:

(define (probe-turned-left prb)
  (cond
    [(probe-north? prb) (make-probe (probe-x prb)
                                    (probe-y prb)
                                    W)]
    [(probe-south? prb) (make-probe (probe-x prb)
                                    (probe-y prb)
                                    E)]
    [(probe-east? prb) (make-probe (probe-x prb)
                                   (probe-y prb)
                                   N)]
    [(probe-west? prb) (make-probe (probe-x prb)
                                   (probe-y prb)
                                   S)]
    )
  )

(define (probe-turned-right prb)
  (cond
    [(probe-north? prb) (make-probe (probe-x prb)
                                    (probe-y prb)
                                    E)]
    [(probe-south? prb) (make-probe (probe-x prb)
                                    (probe-y prb)
                                    W)]
    [(probe-east? prb) (make-probe (probe-x prb)
                                   (probe-y prb)
                                   S)]
    [(probe-west? prb) (make-probe (probe-x prb)
                                   (probe-y prb)
                                   N)]
    )
  )

;;;
;;;TESTS:

(begin-for-test
  (check-equal? (probe-turned-left (probe-at 30 -25)) (make-probe 30 -25 "West"))
  (check-equal? (probe-turned-left (probe-turned-left (probe-at 30 -25))) (make-probe 30 -25 "South"))
  (check-equal? (probe-turned-left (probe-turned-left (probe-turned-left (probe-at 30 -25)))) (make-probe 30 -25 "East"))
  (check-equal? (probe-turned-right (probe-at 30 -25)) (make-probe 30 -25 "East"))
  (check-equal? (probe-turned-right (probe-turned-right (probe-at 30 -25))) (make-probe 30 -25 "South"))
  (check-equal? (probe-turned-right (probe-turned-right (probe-turned-right (probe-at 30 -25)))) (make-probe 30 -25 "West"))
  )

;;;
;;;
;;;probe-forward: Probe Number -> Probe
;;;GIVENS: a probe which is to be moved forward by specified distance
;;;RETURNS: a probe which is moved forward by specified distance
;;;
;;;EXAMPLE: (probe-forward (probe-at 0 -100) 153) = (make-probe 0 -153 "North")
;;;         (probe-forward (probe-at 0 0) 153) = (make-probe 0 -153 "North")
;;;         (probe-forward (probe-at 0 100) 153) = (make-probe 0 -53 "North")
;;;         (probe-forward (probe-turned-left (probe-turned-left (probe-at 0 -100))) 153) = (make-probe 0 53 "South")
;;;         (probe-forward (probe-turned-left (probe-turned-left (probe-at 0 0))) 153) = (make-probe 0 153 "South")
;;;         (probe-forward (probe-turned-left (probe-turned-left (probe-at 0 100))) 153) = (make-probe 0 153 "South")
;;;         (probe-forward (probe-turned-right (probe-at -100 0)) 153) = (make-probe 53 0 "East")
;;;         (probe-forward (probe-turned-right (probe-at 0 0)) 153) = (make-probe 153 0 "East")
;;;         (probe-forward (probe-turned-right (probe-at 100 0)) 153) = (make-probe 153 0 "East")
;;;         (probe-forward (probe-turned-left (probe-at -100 0)) 153) = (make-probe -153 0 "West")
;;;         (probe-forward (probe-turned-left (probe-at 0 0)) 153) = (make-probe -153 0 "West")
;;;         (probe-forward (probe-turned-left (probe-at 100 0)) 153) = (make-probe -53 0 "West")
;;;
;;;DESIGN STRATEGY: use templete for probe on prb
;;;
;;;FUNCTION DESIGN:

(define (probe-forward prb distance)
  (cond
    [(probe-north? prb)
     (make-probe (probe-x prb)
                 (new-distance (probe-y prb) distance N)   ;new distance will always return a coordinate that is within the trap
                 N
                 )
     ]
    
    [(probe-south? prb)
     (make-probe (probe-x prb)
                 (new-distance (probe-y prb) distance S)
                 S
                 )
     ]
    
    [(probe-east? prb)
     (make-probe (new-distance (probe-x prb) distance E)
                 (probe-y prb)
                 E
                 )
     ]
    
    [(probe-west? prb)
     (make-probe (new-distance (probe-x prb) distance W)
                 (probe-y prb)
                 W
                 )
     ]
    )
  )

;;;
;;;TESTS:

(begin-for-test
  (check-equal? (probe-forward (probe-at 0 -100) 153) (make-probe 0 -153 "North"))
  (check-equal? (probe-forward (probe-at 0 0) 153) (make-probe 0 -153 "North"))
  (check-equal? (probe-forward (probe-at 0 100) 153) (make-probe 0 -53 "North"))
  (check-equal? (probe-forward (probe-turned-left (probe-turned-left (probe-at 0 -100))) 153) (make-probe 0 53 "South"))
  (check-equal? (probe-forward (probe-turned-left (probe-turned-left (probe-at 0 0))) 153) (make-probe 0 153 "South"))
  (check-equal? (probe-forward (probe-turned-left (probe-turned-left (probe-at 0 100))) 153) (make-probe 0 153 "South"))
  (check-equal? (probe-forward (probe-turned-right (probe-at -100 0)) 153) (make-probe 53 0 "East"))
  (check-equal? (probe-forward (probe-turned-right (probe-at 0 0)) 153) (make-probe 153 0 "East"))
  (check-equal? (probe-forward (probe-turned-right (probe-at 100 0)) 153) (make-probe 153 0 "East"))
  (check-equal? (probe-forward (probe-turned-left (probe-at -100 0)) 153) (make-probe -153 0 "West"))
  (check-equal? (probe-forward (probe-turned-left (probe-at 0 0)) 153) (make-probe -153 0 "West"))
  (check-equal? (probe-forward (probe-turned-left (probe-at 100 0)) 153) (make-probe -53 0 "West"))
  )

;;;
;;;
;;;new-distance: Number Number String -> Number
;;;GIVEN: information regarding current position, amount of distance to be moved forward and direction
;;;RETURNS: the distance which is within the maximum allowed limits (between -153 to 153)
;;;
;;;EXAMPLES: (new-distance 35 100 N) = -65
;;;          (new-distance 4 150 S) = 153
;;;          (new-distance -78 100 E) = 22
;;;          (new-distance 153 153 W) = 0
;;;
;;;DESIGN STRATEGY: combine simpler functions
;;;
;;;FUNCTION DESIGN:

(define (new-distance current distance dir)
  (cond
    [(string=? dir N)
     (if (< (- current distance) -153) -153 (- current distance))]   ;if the new distance goes out of trap then -153 (maximum allowed) else the new distance
    
    [(string=? dir S)
     (if (> (+ current distance) 153) 153 (+ current distance))]   ;if the new distance goes out of trap then 153 (maximum allowed) else the new distance
    
    [(string=? dir E)
     (if (> (+ current distance) 153) 153 (+ current distance))]
    
    [(string=? dir W)
     (if (< (- current distance) -153) -153 (- current distance))]
    )
  )

;;;
;;;TESTS:

(begin-for-test
  (check-equal? (new-distance 35 100 N) -65)
  (check-equal? (new-distance 4 150 S) 153)
  (check-equal? (new-distance -78 100 E) 22)
  (check-equal? (new-distance 153 153 W) 0)
  )

;;;
;;;
;;;probe-north?: Probe -> Boolean
;;;probe-south?: Probe -> Boolean
;;;probe-east?: Probe -> Boolean
;;;probe-west?: Probe -> Boolean
;;;GIVEN: a probe
;;;RETURNS: whether the probe is facing in the specified direction.
;;;
;;;EXAMPLES: (probe-north? (probe-at 30 10)) = true
;;;          (probe-south? (probe-turned-left (probe-at -100 0))) = false
;;;          (probe-west? (probe-turned-left (probe-at -59 30))) = true
;;;          (probe-east? (probe-turned-right (probe-at 49 -48))) = true
;;;
;;;FUNCTION DESIGN:

(define (probe-north? prb)
  (string=? (probe-orientation prb) N))

(define (probe-south? prb)
  (string=? (probe-orientation prb) S))

(define (probe-east? prb)
  (string=? (probe-orientation prb) E))

(define (probe-west? prb)
  (string=? (probe-orientation prb) W))

;;;
;;;TEST:

(begin-for-test
  (check-equal? (probe-north? (probe-at 30 10)) true)
  (check-equal? (probe-south? (probe-turned-left (probe-at -100 0))) false)
  (check-equal? (probe-west? (probe-turned-left (probe-at -59 30))) true)
  (check-equal? (probe-east? (probe-turned-right (probe-at 49 -48))) true)
  )

;;;PROGRAM REVIEW: This program works for all the valid inputs. Here, valid input would be any pair of coodrdinates which are inside the trap.
;;;                Below are some tests on full system

(begin-for-test
  (check-equal? (probe-west? (probe-forward (probe-turned-right
                                             (probe-forward (probe-turned-left (probe-forward
                                                                                (probe-forward (probe-turned-left (probe-forward (probe-at 0 0) 153)) 10) 90)) 80)) 70))
                true)
  
  (check-equal? (probe-forward (probe-turned-right (probe-forward
                                                    (probe-turned-left (probe-forward (probe-forward
                                                                                  (probe-turned-left (probe-forward (probe-at 0 0) 153)) 10) 90)) 80)) 70)
                (make-probe -153 -73 "West"))
  )