;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-beginner-reader.ss" "lang")((modname class-lists) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f () #f)))
(require rackunit)
(require "extras.rkt")

(check-location "04" "class-lists.rkt")

(provide slip-color
         slip-name1
         slip-name2
         felleisen-roster
         shivers-roster
         remove-dup
         is-it-distinct?
         is-it-dup?)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; CONSTANTS:

;;; slip colors by professor
(define FELLESIEN-COLOR "yellow")
(define SHIVERS-COLOR "blue")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; DATA DEFINATIONS:

;;; A Color is one of
;;; -- "yellow"
;;; -- "blue"
;;;
;;; Interpretation:
;;; "yellow" is the color of slip used by prof. felleisen
;;; "blue" is the color of slip used by prof. shivers
;;; templete:
#|(define (color-fn c)
  (cond
    [(string=? FELLESIEN-COLOR c)...]
    [(string=? SHIVERS-COLOR c)...]))
|#

(define-struct slip (color name1 name2))

;;; a slip is (make-slip String String String)
;;; Interpretations:
;;; color is the color of the slip
;;; name1 is the first/last name of the student
;;; name2 is the first/last name of the student
;;;
;;; templete:
;;; slip-fn: Slip -> ??
#|
(define (slip-fn s)
  (...
   (slip-color s)
   (slip-name1 s)
   (slip-name2 s)
   )
  )
|#
;;; examples used for testing,
(define STUD0 (make-slip FELLESIEN-COLOR  "Dishant" "Kapadiya"))
(define STUD1 (make-slip FELLESIEN-COLOR  "Paulomi" "Mahidharia"))
(define STUD2 (make-slip FELLESIEN-COLOR  "Sanil" "Jain"))
(define STUD3 (make-slip FELLESIEN-COLOR  "Sudeep" "Kulkarni"))
(define STUD4 (make-slip FELLESIEN-COLOR  "Sushant" "Mimani"))
(define STUD5 (make-slip SHIVERS-COLOR "Naomi" "Joshi"))
(define STUD6 (make-slip SHIVERS-COLOR "Nitish" "Surana"))
(define STUD7 (make-slip SHIVERS-COLOR "Shraddha" "Satish"))
(define STUD8 (make-slip SHIVERS-COLOR  "Anvita" "Surpaneni"))
(define STUD9 (make-slip FELLESIEN-COLOR  "Kapadiya" "Dishant"))

;;; A List of Slip (LOS) is one of:
;;; -- empty
;;; -- (cons Slip LOS)
;;; list-fn : ListOfX -> ??
#|(define (list-fn lst)
  (cond
    [(empty? lst) ...]
    [else
     (...
      (first lst)
      (list-fn (rest lst)))]))
|#
;;; list of students
(define STUDENTLIST (list STUD0 STUD0 STUD1 STUD2 STUD1 STUD2 STUD3 STUD4 STUD1
                          STUD5 STUD6 STUD7 STUD8 STUD9 STUD0 STUD1 STUD2 STUD3
                          STUD4 STUD5 STUD6 STUD7 STUD8 STUD9))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; FUNCTIONS:

;;; felleisen-roster : ListOfSlip -> ListOfSlip
;;; GIVEN: a list of slips
;;; RETURNS: a list of slips containing all the students in Professor
;;;          Felleisen's class, without duplication.
;;; EXAMPLES: (felleisen-roster (list STUD0 STUD1 STUD7 STUD8 STUD0))
;;;           = (list STUD1 STUD0)
;;;           (felleisen-roster (list STUD0 STUD9)) = (list STUD9)
;;; DESIGN STRATEGY: use templete for ListOfSlip on los
(define (felleisen-roster los)
  (cond
    [(empty? los) empty]
    [else
     (if (string=? (slip-color (first los)) FELLESIEN-COLOR )
         (remove-dup (cons (first los) (felleisen-roster (rest los))))
         (felleisen-roster (rest los)))]))

;;;
;;; TESTS:
(begin-for-test
  (check-equal? (felleisen-roster (list STUD0 STUD1 STUD7 STUD8 STUD0))
                (list STUD1 STUD0)
                "Removed duplicates and student not in Felleisen's class")
  (check-equal? (felleisen-roster (list STUD0 STUD9))
                (list STUD9)
                "Removed duplicates in Felleisen's class"))


;;; shivers-roster: ListOfSlip -> ListOfSlip
;;; GIVEN: a list of slips
;;; RETURNS: a list of slips containing all the students in Professor
;;;         Shivers' class, without duplication.
;;; EXAMPLES: (shivers-roster (list STUD0 STUD7 STUD1 STUD7 STUD8 STUD0))
;;;           = (list STUD7 STUD8)
;;;           (shivers-roster (list STUD0 STUD9)) = empty
;;; DESIGN STRATEGY: use templete for ListOfSlip on los
(define (shivers-roster los)
  (cond
    [(empty? los) empty]
    [else
     (if (string=? (slip-color (first los)) SHIVERS-COLOR)
         (remove-dup (cons (first los) (shivers-roster (rest los))))
         (shivers-roster (rest los)))]))

;;;
;;; TESTS:
(begin-for-test
  (check-equal? (shivers-roster (list STUD0 STUD7 STUD1 STUD7 STUD8 STUD0))
                (list STUD7 STUD8)
                "Removed duplicates and student not in Shivers's class")
  (check-equal? (shivers-roster (list STUD0 STUD9))
                empty
                "Removed duplicates in Shivers's class"))

;;; find-duplicates: ListOfSlip -> ListOfSlip
;;; GIVEN: a list of students in same class
;;; RETURNS: a list of students in which there are no duplicates
;;; EXAMPLES: (remove-dup (list STUD0 STUD1 STUD1 STUD2 STUD3) =
;;;           = (list STUD0 STUD1 STUD2 STUD3)
;;; DESIGN STRATEGY: use templete for ListOfSlip on los
(define (remove-dup los)
  (cond
    [(empty? los) empty]
    [else
     (if (is-it-distinct? (first los) (rest los))
         (cons (first los) (remove-dup (rest los)))
         (remove-dup (rest los)))]))

;;;
;;; TESTS:
(begin-for-test
  (check-equal? (remove-dup (list STUD0 STUD1 STUD1 STUD2 STUD3))
                (list STUD0 STUD1 STUD2 STUD3)
                "all the duplicates should be removed")
  (check-equal? (remove-dup (list STUD0 STUD1 STUD1 STUD2 STUD9))
                (list STUD1 STUD2 STUD9)
                "all the duplicates should be removed"))

;;; is-it-distinct?: Slip ListOfSlip : Boolean
;;; GIVEN: a slip and a list of slip
;;; RETURNS: true if there is no duplicate of slip in the list else false
;;; EXAMPLES: (is-it-distinct? STUD0 (list STUD6 STUD3 STUD4)) = true
;;;           (is-it-distinct? STUD0 (list STUD6 STUD3 STUD9)) = false
;;; DESIGN STRATEGY: use templete for ListOfSlip on los
(define (is-it-distinct? s los)
  (cond
    [(empty? los) true]
    [else
     (and (not (is-it-dup? s (first los)))
          (is-it-distinct? s (rest los)))]))

;;;
;;; TESTS:
(begin-for-test
  (check-equal? (is-it-distinct? STUD0 (list STUD6 STUD3 STUD4))
                 true
                 "the list has no duplicates")
  (check-equal? (is-it-distinct? STUD0 (list STUD6 STUD3 STUD9))
                 false
                 "the list has duplicates"))

;;; is-it-dup?: Slip Slip -> Boolean
;;; GIVEN: two Slip instances
;;; RETURNS: true if both slip represents same student else false
;;; EXAMPLES: (is-it-dup? STUD0 STUD0) = true
;;;           (is-it-dup? STUD0 STUD2) = false
;;;           (is-it-dup? STUD0 STUD9) = true
;;; DESIGN STRATEGY: combine simpler functions
(define (is-it-dup? s1 s2)
  (or (and (string=? (slip-name1 s1) (slip-name1 s2))
           (string=? (slip-name2 s1) (slip-name2 s2)))
      (and (string=? (slip-name1 s1) (slip-name2 s2))
           (string=? (slip-name2 s1) (slip-name1 s2)))))

;;;
;;; TESTS:
(begin-for-test
  (check-equal? (is-it-dup? STUD0 STUD0)
                 true
                 "It is a duplicate")
  (check-equal? (is-it-dup? STUD0 STUD2)
                 false
                 "It is not a duplicate")
  (check-equal? (is-it-dup? STUD0 STUD9)
                 true
                 "It is a duplicate"))