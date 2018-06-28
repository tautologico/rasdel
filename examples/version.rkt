;;
;; version.rkt
;; An example querying the SDL version information
;;

#lang racket

(require "../base.rkt")

(define (main)
  (define version (sdl-get-version))
  (printf "Linked to SDL version ~a.~a.~a\n"
          (sdl-version-major version)
          (sdl-version-minor version)
          (sdl-version-patch version))
  (printf "Revision number: ~a\n" sdl-revision-number)
  (printf "Full revision specification: ~a\n" (sdl-get-revision)))

(module+ main
  (main))
