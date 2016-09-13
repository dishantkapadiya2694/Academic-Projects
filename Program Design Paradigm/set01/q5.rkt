;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-beginner-reader.ss" "lang")((modname q5) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f () #f)))
(require rackunit)
(require "extras.rkt")
(provide string-delete)
;;;DATA DESIGN: no data design required
;;;
;;;string-delete: String Int -> String
;;;GIVEN: string and postion of the character to be deleted
;;;RETURNS: string with character deleted at the given position
;;;
;;;EXAMPLES: (string-delete "NorthZeastern" 5) = "Northeastern"
;;;          (string-delete "ZUniversity" 0) = "Univesity"
;;;          (string-delete "BostonZ" 6) = "Boston"
;;;
;;;DESIGN STRATEGY: combine simpler functions
;;;
;;;FUNCTION DESIGN :-
(define (string-delete str i)
  (if (= (string-length str) 0) ;Check if the string is empty
      "ERROR: String is empty!" ;Display an error message as deletion in empty string is not possible
      (string-append (substring str 0 i) (substring str (+ i 1)))));Else delete the desired character by dividing the string before and after the character and then append it.
;;;
;;;TESTS:-
(begin-for-test
  (check-equal? (string-delete "NorthZeastern" 5) "Northeastern")
  (check-equal? (string-delete "ZUniversity" 0) "University")
  (check-equal? (string-delete "BostonZ" 6) "Boston")
  (check-equal? (string-delete "" 0) "ERROR: String is empty!")
  )
;;;
;;;PROGRAM REVIEW: The program handles empty strings by displaying an error message 