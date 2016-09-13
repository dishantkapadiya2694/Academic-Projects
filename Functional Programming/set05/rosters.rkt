;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-intermediate-lambda-reader.ss" "lang")((modname rosters) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f () #f)))
(require rackunit)
(require "extras.rkt")

(provide make-enrollment
         enrollment-student
         enrollment-class
         make-roster
         roster-classname
         roster-students
         check-dup?
         list=?
         roster=?
         is-it-dup?
         rosterset=?
         add-student-to-roster
         add-student-to-rosterlist
         new-class?
         add-record
         enrollments-to-rosters)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; CONSTANTS

;;; Class constants
(define CLASS1 "PDP")
(define CLASS2 "FoAI")

;;; Student constants
(define STUD1 "A")
(define STUD2 "B")
(define STUD3 "C")

;;; Set of Students
(define SOS1 (list STUD1 STUD2 STUD3))
(define SOS2 (list STUD1 STUD3))
(define SOS3 (list STUD1 STUD3 STUD2))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; DATA DEFINATIONS:

;;; A SetOfX is a list of X's without duplication.  Two SetOfX's are
;;; considered equal if they have the same members.

(define-struct enrollment (student class))
;;; an Enrollment is a (make-enrollment Student Class)
;;; Interpretation:
;;; student is an instance which holds value for a student
;;; class is an instance which holds value of class that student is enrolled in
;;;
;;; templete:
;;; enrollment-fn: Enrollment -> ??
#|
(define (enrollment-fn e)
  (...
   (enrollment-student e)
   (enrollment-class e)))
|#

(define-struct roster (classname students))
;;; a Roster is a (make-roster ClassName SetOfStudents)
;;; Interpretation:
;;; classname represents name of a class
;;; students represents a set of student in that particular class
;;; templete:
;;; roster-fn: Roster -> ??
#|
(define (roster-fn r)
  (...
   (roster-classname r)
   (roster-students r)))
|#

;;; ClassRoster constants
(define CLASSROSTER1 (make-roster CLASS1 SOS1))
(define CLASSROSTER2 (make-roster CLASS1 SOS2))
(define CLASSROSTER3 (make-roster CLASS2 SOS1))
(define CLASSROSTER4 (make-roster CLASS1 SOS3))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; FUNCTIONS

;;; check-dup?: Student SetOfStudent -> Boolean
;;; GIVEN: a Student value and a SetOfStudent
;;; RETURNS: true if Student is present in SetOfStudent
;;; EXAMPLES: (check-dup? STUD1 SOS1) = true
;;;           (check-dup? STUD2 SOS2) = false
;;; DESIGN STRATEGY: use HOF ormap on st and setofst
(define (check-dup? st setofst)
  (ormap
   ;;; Student -> Boolean
   (lambda (x) (equal? st x))
   setofst))

;;; TESTS:
(begin-for-test
  (check equal? (check-dup? STUD1 SOS1)
         true
         "STUD1 present in SOS1")
  (check equal? (check-dup? STUD3 SOS2)
         true
         "STUD3 present in SOS2")
  (check equal? (check-dup? STUD2 SOS2)
         false
         "STUD2 not present in SOS2"))

;;; list=?: SetOfStudent SetOfStudent -> Boolean
;;; GIVEN: 2 instances of SetOfStudent
;;; RETURNS: true if both lists are same
;;; EXAMPLES: (list=? SOS1 SOS3) = true
;;; DESIGN STRATEGY: use HOF andmap on sos1 and sos2
(define (list=? sos1 sos2)
  (if (<= (length sos1) (length sos2))
      (andmap
       ;;; Student SetOfStudent -> Boolean
       (lambda (x) (check-dup? x sos1)) sos2)
      (andmap
       ;;; Student SetOfStudent -> Boolean
       (lambda (x) (check-dup? x sos2)) sos1)))

;;; TESTS:
(begin-for-test
  (check equal? (list=? SOS1 SOS3)
         true
         "these lists holds same value but in different order and hence are same")
  (check equal? (list=? SOS1 SOS2)
         false
         "these lists holds different values and hence are different"))

;;; roster=?: ClassRoster ClassRoster -> Boolean
;;; GIVEN: 2 instance of ClassRoster
;;; RETURNS: true if both are equal else false
;;; EXAMPLES: (roster=? CLASSROSTER1 CLASSROSTER2) = false
;;;           (roster=? CLASSROSTER1 CLASSROSTER1) = true
;;; DESIGN STRATEGY: use templete for ClassRoster on cr1 and cr2
(define (roster=? cr1 cr2)
  (if (equal? (roster-classname cr1) (roster-classname cr2))
      (list=? (roster-students cr1) (roster-students cr2))
      false))

;;; TESTS:
(begin-for-test
  (check equal? (roster=? CLASSROSTER1 CLASSROSTER2)
         false
         "different rosters")
  (check equal? (roster=? CLASSROSTER2 CLASSROSTER1)
         false
         "different rosters")
  (check equal? (roster=? CLASSROSTER2 CLASSROSTER3)
         false
         "different rosters")
  (check equal? (roster=? CLASSROSTER1 CLASSROSTER4)
         true
         "same rosters"))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; is-it-dup?: ClassRoster SetOfClassRoster -> Boolean
;;; GIVEN: a ClassRoster and a SetOfClassRoster
;;; RETURNS: true if there an instance in SetOfClassRoster simillar to given ClassRoster
;;; EXAMPLES: (is-it-dup? CLASSROSTER1 LISTROS1) = true
;;;           (is-it-dup? CLASSROSTER2 LISTROS1) = false
;;; DESIGN STRATEGY: use HOF ormap on rs
(define (is-it-dup? cr rs)
  (ormap
   ;;; ClassRoster ClassRoster -> Boolean
   (lambda (x) (roster=? cr x)) rs))

;;; TESTS:
(begin-for-test
  (check equal? (is-it-dup? CLASSROSTER1 LISTROS1)
         true
         "there is an instance like CLASSROSTER1 in LISTROS1")
  (check equal? (is-it-dup? CLASSROSTER2 LISTROS1)
         false
         "there is no instance like CLASSROSTER2 in LISTROS1"))

;;; rosterset=?: SetOfClassRoster SetOfClassRoster -> Boolean
;;; GIVEN: 2 instance of SetOfClassRoster
;;; RETURNS: true if both the SetOfClassRoster are same
;;; EXAMPLES: (rosterset=? LISTROS1 LISTROS2) = false
;;;           (rosterset=? LISTROS3 LISTROS1) = true
;;; DESIGN STRATEGY: use HOF andmap on rs1 and rs2
(define (rosterset=? rs1 rs2)
  (if (<= (length rs1) (length rs2))
      (andmap
       ;;; ClassRoster SetOfClassRoster -> Boolean
       (lambda (x) (is-it-dup? x rs1)) rs2)
      (andmap
       ;;; ClassRoster SetOfClassRoster -> Boolean
       (lambda (x) (is-it-dup? x rs2)) rs1)))

;;; Constants for tests
(define LISTROS1 (list CLASSROSTER1 CLASSROSTER3))
(define LISTROS2 (list CLASSROSTER2 CLASSROSTER1))
(define LISTROS3 (list CLASSROSTER3 CLASSROSTER4))
(define LISTROS4 (list CLASSROSTER1 CLASSROSTER2 CLASSROSTER3))
(define LISTROS5 (list CLASSROSTER2 CLASSROSTER1 CLASSROSTER3))
(define LISTROS6 (list CLASSROSTER4 CLASSROSTER2 CLASSROSTER3))

;;; TESTS:
(begin-for-test
  (check equal? (rosterset=? LISTROS1 LISTROS2)
         false
         "different class rosters")
  (check equal? (rosterset=? LISTROS2 LISTROS3)
         false
         "different class rosters")
  (check equal? (rosterset=? LISTROS3 LISTROS1)
         true
         "similar class rosters")
  (check equal? (rosterset=? LISTROS4 LISTROS1)
         false
         "different class rosters")
  (check equal? (rosterset=? LISTROS4 LISTROS5)
         true
         "similar class rosters")
  (check equal? (rosterset=? LISTROS4 LISTROS6)
         true
         "similar class rosters"))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; add-student-to-roster: Enrollment Roster -> Roster
;;; GIVEN: an instance of Enrollment and Roster
;;; RETURNS: a Roster in which has the student
;;; EXAMPLES: (add-student-to-roster (make-enrollment STUD2 CLASS1) CLASSROSTER2)
;;;           = (make-roster "PDP" (list "B" "A" "C"))
;;; DESIGN STRATEGY: use templete for roster & enrollment on r & s resp.
(define (add-student-to-roster s r)
  (make-roster (roster-classname r)
               (cons (enrollment-student s) (roster-students r))))

;;; TESTS:
(begin-for-test
  (check equal? (add-student-to-roster (make-enrollment STUD2 CLASS1) CLASSROSTER2)
         (make-roster "PDP" (list "B" "A" "C"))
         "adds a student to roster"))

;;; add-student-to-rosterlist: Enrollment SetofClassRoster -> SetOfClassRoster
;;; GIVEN: an Enrollment and a SetOfClassRoster
;;; RETURN: an updated SetOfClassRoster with the student in his/her class
;;; EXAMPLES: (add-student-to-rosterlist (make-enrollment STUD1 CLASS1) LISTROS1) =
;;;           = (list (make-roster "PDP" (list "A" "A" "B" "C"))
;;;                   (make-roster "FoAI" (list "A" "B" "C")))
;;; DESIGN STRATEGY:
(define (add-student-to-rosterlist s locr)
  (map
   ;;; ClassRoster -> ClassRoster
   (lambda (x) (if (equal? (enrollment-class s) (roster-classname x))
                   (add-student-to-roster s x)
                   x))
   locr))

;;; new-class?: Class SetOfClassRoster -> Boolean
;;; GIVEN: a class and a set of ClassRoster
;;; RETURNS: true if the class is not previously added to SetOfClassRoster else false
;;; EXAMPLES: (new-class? "PDP" LISTROS1) = false
;;; DESIGN STRATEGY: use HOF filter on locr
(define (new-class? c locr)
  (empty? (filter
           ;;; Roster -> Boolean
           (lambda (x) (equal? c (roster-classname x))) locr)))

;;;TESTS:
(begin-for-test
  (check equal? (new-class? CLASS1 LISTROS1)
         false
         "CLASS1 already exists in LISTROS1")
  (check equal? (new-class? "DBMS" LISTROS1)
         true
         "DBMS does not exist in LISTROS1"))

;;; add-record: Enrollment SetOfClassRoster -> SetOfClassRoster
;;; GIVEN: an Enrollment and a SetOfClassRoster
;;; RETURN: an updated SetOfClassRoster with the student in his/her class
;;; EXAMPLES: (add-record (make-enrollment STUD1 CLASS1) LISTROS1) =
;;;           = (list (make-roster "PDP" (list "A" "A" "B" "C"))
;;;                   (make-roster "FoAI" (list "A" "B" "C")))
;;; DESIGN STRATEGY: use templete for enrollment on s
(define (add-record s locr)
  (if (new-class? (enrollment-class s) locr)
      (cons (make-roster (enrollment-class s) (list (enrollment-student s))) locr)
      (add-student-to-rosterlist s locr)))

;;; TESTS:
(begin-for-test
  (check equal? (add-record (make-enrollment STUD1 CLASS1) LISTROS1)
         (list (make-roster CLASS1 (list STUD1 STUD1 STUD2 STUD3))
               (make-roster CLASS2 (list STUD1 STUD2 STUD3)))
         "STUD1 added to CLASS1"))


;;; enrollments-to-rosters: SetOfEnrollment -> SetOfClassRoster
;;; GIVEN: a set of enrollments
;;; RETURNS: the set of class rosters for the given enrollments
;;; EXAMPLES: (enrollments-to-rosters (list (make-enrollment STUD1 CLASS1)
;;;                                         (make-enrollment STUD2 CLASS2)))
;;;           = (list (make-roster CLASS1 (list STUD1))
;;;                   (make-roster CLASS2 (list STUD2)))
;;; DESIGN STRATEGY: use HOF foldr on soe
(define (enrollments-to-rosters soe)
  (foldr add-record empty soe))

;;; TESTS:
(begin-for-test
  (check rosterset=? (enrollments-to-rosters (list (make-enrollment STUD1 CLASS1)
                                                   (make-enrollment STUD2 CLASS1)
                                                   (make-enrollment STUD3 CLASS2)
                                                   (make-enrollment STUD1 CLASS2)))
         (list (make-roster CLASS1 (list STUD1 STUD2))
               (make-roster CLASS2 (list STUD3 STUD1)))
         "a list of rosters segregated by the Class")
  
  (check rosterset=? (enrollments-to-rosters
                      (list (make-enrollment "John" "PDP")
                            (make-enrollment "Kathryn" "Networks")
                            (make-enrollment "Feng" "PDP")
                            (make-enrollment "Amy" "PDP")
                            (make-enrollment "Amy" "Networks")))            
         (list (make-roster "PDP" (list "John" "Feng" "Amy"))
               (make-roster "Networks" (list "Kathryn" "Amy")))
         "a list of rosters segregated by the Class"))