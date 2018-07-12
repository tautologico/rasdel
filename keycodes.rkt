;;
;; keycodes.rkt
;;
;; Codes for keyboard events
;;

#lang racket

(provide (all-defined-out))

;; scancodes
(define SDL-SCANCODE-RIGHT 79)
(define SDL-SCANCODE-LEFT  80)
(define SDL-SCANCODE-DOWN  81)
(define SDL-SCANCODE-UP    82)

(define SDL-SCANCODE-1 30)
(define SDL-SCANCODE-2 31)
(define SDL-SCANCODE-3 32)
(define SDL-SCANCODE-4 33)
(define SDL-SCANCODE-5 34)
(define SDL-SCANCODE-6 35)
(define SDL-SCANCODE-7 36)
(define SDL-SCANCODE-8 37)
(define SDL-SCANCODE-9 38)
(define SDL-SCANCODE-0 39)

(define SDL-SCANCODE-LCTRL  224)
(define SDL-SCANCODE-LSHIFT 225)
(define SDL-SCANCODE-LALT   226)
(define SDL-SCANCODE-LGUI   227)
(define SDL-SCANCODE-RCTRL  228)
(define SDL-SCANCODE-RSHIFT 229)
(define SDL-SCANCODE-RALT   230)
(define SDL-SCANCODE-RGUI   231)
