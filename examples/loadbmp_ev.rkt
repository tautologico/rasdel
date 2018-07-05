;;
;; loadbmp_ev.rkt
;; Load an image and render it to a window
;; Use event polling to watch for a quit event
;;

#lang racket

(require "../base.rkt")
(require "../video.rkt")
(require "../events.rkt")

(define width 560)
(define height 560)

(define img-path "racket-logo.bmp")

;; event-polling loop.
;; returns #t when all events processed and no quit event received,
;; #f when quit event was processed
(define (poll-loop)
  (define e (sdl-next-event))
  (cond [(and e (sdl-event-has-type? e SDL-QUIT)) #f]
        [else #t]))       ;; has no event -> return to main loop, not quit

;; rendering loop
;; while a quit event is not received, render image to the window
(define (render-loop win img scr)
  (when (poll-loop)
    (sdl-blit-surface img scr)
    (sdl-update-window-surface win)
    (render-loop win img scr)))

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
  (render-loop win img win-sfc)
  (sdl-quit))

(module+ main
  (main))
