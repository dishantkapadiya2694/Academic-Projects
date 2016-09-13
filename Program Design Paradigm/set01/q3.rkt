;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-beginner-reader.ss" "lang")((modname q3) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f () #f)))
(require rackunit)
(require "extras.rkt")
(require 2htdp/image)
(provide image-area)
;;;DATA DESIGN: no data design required
;;;
;;;image-area: Image -> Natural Number
;;;GIVEN: an image whose area is supposed to be found 
;;;RETURNS: area of the image (total number of pixels in it)
;;;
;;;          (image-area (circle 100 "solid" "blue")) = 400
;;;          (image-area (star 30 "outline" "red")) = 2254
;;;          (image-area (empty-scene 130 90)) = 11700
;;;
;;;DESIGN STRATEGY: combine simpler functions
;;;
;;;FUNCTION DESIGN :-
(define (image-area img)
  (* (image-width img) (image-height img))) ;'image-width' and 'image-height' return values in pixels. Multiplying these gives us total number of pixels i.e. Area
;;;
;;;TESTS:-
(begin-for-test
  (check-equal? (image-area (circle 100 "solid" "blue")) 40000)
  (check-equal? (image-area (star 30 "outline" "red")) 2254)
  (check-equal? (image-area (empty-scene 130 90)) 11700)
  )
;;;
;;;PROGRAM REVIEW: the function computes the area in pixels using the pre-defined functions
