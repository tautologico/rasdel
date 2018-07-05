;;
;; rendertexture.rkt
;;
;; Render by filling a texture and copying it to
;; a renderer
;;

#lang racket

(require ffi/unsafe)

(require (rename-in racket/unsafe/ops
                    (unsafe-fx+ r+)
                    (unsafe-fxlshift shift-left)
                    (unsafe-fxrshift shift-right)
                    (unsafe-fxand band)))

(require "../base.rkt")
(require "../video.rkt")
(require "../events.rkt")

(define width 560)
(define height 560)

;; event-polling loop.
;; returns #t when all events processed and no quit event received,
;; #f when quit event was processed
(define (poll-loop)
  (define e (sdl-next-event))
  (cond [(and e (sdl-event-has-type? e SDL-QUIT)) #f]
        [else #t]))       ;; has no event -> return to main loop, not quit

(define (render-to-texture texture)
  (define-values (p pitch) (sdl-lock-texture texture #f))
  (for ([i (in-range 0 (* 4 width height) 4)])
    (ptr-set! p _uint8 i        (band i #xFF))
    (ptr-set! p _uint8 (add1 i) (shift-right i 13))
    (ptr-set! p _uint8 (+ i 2)  0)
    (ptr-set! p _uint8 (+ i 3)  #xFF))
  (sdl-unlock-texture texture))

(define frames 0)
(define total 0)

;; rendering loop
;; while a quit event is not received, render image to the window
(define (render-loop render texture)
  (when (poll-loop)
    (define start (current-inexact-milliseconds))
    (render-to-texture texture)
    (sdl-render-copy render texture #f #f)
    (sdl-render-present render)
    (define end (current-inexact-milliseconds))
    (set! frames (add1 frames))
    (set! total (+ total (- end start)))
    (render-loop render texture)))

(define (hex32 n)
  (~r n #:base 16 #:min-width 8 #:pad-string "0"))

(define (main)
  (sdl-init #:video? #t #:audio? #f)
  (define win (sdl-create-window "Load BMP" width height))
  (define render (sdl-create-renderer win))
  (unless (and win render)
    (error 'sdl
           (format "Could not create SDL window or renderer: ~a" (sdl-get-error))))
  (define texture (sdl-create-streaming-texture
                   render SDL-PIXEL-FORMAT-RGB888 width height))
  (unless texture
    (error 'sdl (format "Could not create SDL texture: ~a" (sdl-get-error))))

  (define-values (p pitch) (sdl-lock-texture texture #f))
  (sdl-unlock-texture texture)
  (printf "Texture pitch: ~a\n" pitch)
  (render-loop render texture)
  (printf "Rendered ~a frames, average ~a ms/frame\n" frames (/ total frames))
  (sdl-quit))

(module+ main
  (main))
