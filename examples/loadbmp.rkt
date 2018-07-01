;;
;; loadbmp.rkt
;; Load an image and render it to a window
;; Use a timer to close the window
;;

#lang racket

(require "../base.rkt")
(require "../video.rkt")

(define width 560)
(define height 560)

(define img-path "racket-logo.bmp")

(define (main)
  (define img (sdl-load-bmp img-path))
  (unless img (error 'loadbmp (format "Could not load image ~a: ~a"
                                      img-path (sdl-get-error))))
  (sdl-init #:video? #t #:audio? #f)
  (define win (sdl-create-window "Load BMP" width height))
  (define win-sfc (sdl-get-window-surface win))
  (unless (and win win-sfc)
    (error 'create-window
           (format "Could not create SDL window or get surface: ~a" (sdl-get-error))))
  (sdl-blit-surface img win-sfc)
  (sdl-update-window-surface win)
  (sleep 5)
  (sdl-quit))

(module+ main
  (main))
