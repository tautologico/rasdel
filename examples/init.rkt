;;
;; init.rkt
;; Initialization and subsystems
;;

#lang racket

(require "../base.rkt")

(define (print-subsystem-init-status sub)
  (printf "~a was initialized? ~a\n"
          (string-titlecase (symbol->string sub))
          (if (sdl-was-init? sub) "yes" "no")))

(define (main)
  (sdl-init #:video? #t #:audio? #f)
  (printf "SDL Initialized\n")
  (print-subsystem-init-status 'video)
  (print-subsystem-init-status 'audio)
  (print-subsystem-init-status 'control)
  (print-subsystem-init-status 'timer)
  (print-subsystem-init-status 'haptic)

  (printf "\nInitializing control and haptic subsystems...\n")
  (sdl-init-subsystems 'control 'haptic)
  (print-subsystem-init-status 'control)
  (print-subsystem-init-status 'haptic)

  (printf "\nNow finalizing SDL systems\n")
  (sdl-quit))

(module+ main
  (main))
