;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-beginner-reader.ss" "lang")((modname editor) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f () #f)))
(check-location "02" "editor.rkt")

(require 2htdp/universe)
(require rackunit)
(require "extras.rkt")

(provide
 make-editor
 editor-pre
 editor-post
 editor?
 edit
 string-first
 string-last
 string-remove-first
 string-remove-last
 )

;;;DATA DEFINATIONS:

(define-struct editor [pre post])

;;;An editor is a 
;;;   (make-editor String String)
;;;
;;;Interpretation:
;;;   pre is the text before cursor
;;;   post is the text after cursor
;;;
;;;editor-fn : editor -> ??
#|
(define (editor-fn ed)
  (...
   (editor-pre ed)
   (editor-post ed)
   )
  )
|#
;;;
;;;
;;;string-first: String -> 1String
;;;string-last: String -> 1String
;;;GIVEN: a string in whose first/last character is to be extracted
;;;WHERE: String is not empty
;;;RETURNS: 1String extracted from first/last
;;;
;;;EXAMPLES: (string-first "DrRacket") = "D"
;;;          (string-last "DrRacket") = "T"
;;;
;;;DESIGN STRATEGY: combine simpler functions
;;;
;;;FUNCTION DESIGN:

(define (string-first str)
  (string-ith str 0)
  )

(define (string-last str)
  (string-ith str (- (string-length str) 1))
  )

;;;
;;;TESTS:

(begin-for-test
  (check-equal? (string-first "DrRacket") "D")
  (check-equal? (string-last "DrRacket") "t")
  )

;;;
;;;
;;;string-remove-first: String -> String
;;;string-remove-last: String -> String
;;;GIVEN: string whose first/last character is to be removed
;;;WHERE: string is not empty
;;;RETURNS: string whose first/last charcter is removed
;;;
;;;EXAMPLES: (string-remove-first "DrRacket") = "rRacket"
;;;          (string-remove-last "DrRacket") = "DrRacke"
;;;
;;;DESIGN STRATEGY: combine simpler functions
;;;
;;;FUNCTION DESIGN:

(define (string-remove-first str)
  (substring str 1 (string-length str)))

(define (string-remove-last str)
  (substring str 0 (- (string-length str) 1)))

;;;
;;;TESTS:

(begin-for-test
  (check-equal? (string-remove-first "DrRacket") "rRacket")
  (check-equal? (string-remove-last "DrRacket") "DrRacke")
  )

;;;
;;;
;;;edit: Editor KeyEvent -> Editor
;;;GIVEN: an editor instance and a keyevent from user
;;;WHERE: a KeyEvent is either a character from keyboard, '\b' (backspace), 'left' (move cursor to left) or 'right' (move cursor to right).
;;;RETURNS: an editor which reflects the change due to keyevent
;;;
;;;EXAMPLES: (edit (make-editor "Northeastern" "University") "z") = make-editor "Northeasternz" "University"
;;;          (edit (make-editor "Northeastern" "") "z") = make-editor "Northeasternz" ""
;;;          (edit (make-editor "" "University") "z") = make-editor "z" "University"
;;;          (edit (make-editor "Northeastern" "University") "z") = make-editor "Northeasternz" "University"
;;;          (edit (make-editor "Northeastern" "") "z") = make-editor "Northeasternz" ""
;;;          (edit (make-editor "" "University") "z") = make-editor "z" "University"
;;;          (edit (make-editor "Northeastern" "University") "\b") = make-editor "Northeaster" "University"
;;;          (edit (make-editor "Northeastern" "") "\b") = make-editor "Northeaster" ""
;;;          (edit (make-editor "" "University") "\b") = make-editor "" "University"
;;;          (edit (make-editor "Northeastern" "University") "left") = make-editor "Northeaster" "nUniversity"
;;;          (edit (make-editor "Northeastern" "") "left") = make-editor "Northeaster" "n"
;;;          (edit (make-editor "" "University") "left") = make-editor "" "University"
;;;          (edit (make-editor "Northeastern" "University") "right") = make-editor "NortheasternU" "niversity"
;;;          (edit (make-editor "Northeastern" "") "right") = make-editor "Northeastern" ""
;;;          (edit (make-editor "" "University") "right") = make-editor "U" "niversity"
;;;
;;;DESIGN STRATEGY: use templete for editor on ed
;;;
;;;FUNCTION DESIGN:

(define (edit ed ke)
  (cond
    [(key=? ke "\b")
     (if (string=? (editor-pre ed) "")   ;if pre is empty, there wont be any change
         ed
         (make-editor
          (string-remove-last (editor-pre ed))   ;remove the last character from pre
          (editor-post ed)
          )
         )
     ]
    
    [(key=? ke "left")
     (if (string=? (editor-pre ed) "")   ;if pre is empty, there wont be any change
         ed
         (make-editor
          (string-remove-last (editor-pre ed))   ;remove the last character from pre
          (string-append (string-last (editor-pre ed)) (editor-post ed))   ;last character from pre + post
          )
         )
     ]
    
    [(key=? ke "right")
     (if (string=? (editor-post ed) "")   ;if post is empty, there wont be any change
         ed
         (make-editor
          (string-append (editor-pre ed) (string-first (editor-post ed)))   ;pre + first character from post
          (string-remove-first (editor-post ed))   ;removes first character from post
          )
         )
     ]
    
    [(= (string-length ke) 1)   ;accepts onlt 1Strings (valid keyboard characters)
     (make-editor (string-append (editor-pre ed) ke) (editor-post ed))]   ;pre + ke
    
    )
  )

;;;
;;;TESTS:

(begin-for-test
  (check-equal? (edit (make-editor "Northeastern" "University") "z") (make-editor "Northeasternz" "University"))
  (check-equal? (edit (make-editor "Northeastern" "") "z") (make-editor "Northeasternz" ""))
  (check-equal? (edit (make-editor "" "University") "z") (make-editor "z" "University"))
  (check-equal? (edit (make-editor "Northeastern" "University") "\b") (make-editor "Northeaster" "University"))
  (check-equal? (edit (make-editor "Northeastern" "") "\b") (make-editor "Northeaster" ""))
  (check-equal? (edit (make-editor "" "University") "\b") (make-editor "" "University"))
  (check-equal? (edit (make-editor "Northeastern" "University") "left") (make-editor "Northeaster" "nUniversity"))
  (check-equal? (edit (make-editor "Northeastern" "") "left") (make-editor "Northeaster" "n"))
  (check-equal? (edit (make-editor "" "University") "left") (make-editor "" "University"))
  (check-equal? (edit (make-editor "Northeastern" "University") "right") (make-editor "NortheasternU" "niversity"))
  (check-equal? (edit (make-editor "Northeastern" "") "right") (make-editor "Northeastern" ""))
  (check-equal? (edit (make-editor "" "University") "right") (make-editor "U" "niversity"))
  )

;;;PROGRAM REVIEW: This program works for all valid inputs. Valid inputs here are all the keyboard characters,
;;;                '\b' (backspace), 'left' (move cursor to left), 'right' (move cursor to right)
