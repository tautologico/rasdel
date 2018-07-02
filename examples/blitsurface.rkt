;;
;; blitsurface.rkt
;;
;; Render to a surface with known pixel format
;; and blit it to the window surface
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
  (define e (sdl-poll-event))
  (cond [(and e (sdl-event-has-type? e SDL-QUIT)) #f]
        [e (poll-loop)]   ;; has event but it's not quit -> continue processing
        [else #t]))       ;; has no event -> return to main loop, not quit

(define (init-surface sfc)
  (memset (sdl-surface-pixels sfc) 0 (* (sdl-surface-h sfc) (sdl-surface-pitch sfc))))


;; Assume the surface doesn't need to be locked,
;; the pixel format is 32-bpp and pitch = 4 * width
(define (render-to-surface sfc)
  (define p (sdl-surface-pixels sfc))
  (for ([i (in-range 0 (* 4 width height) 4)])
    (ptr-set! p _uint8 i        (band i #xFF))
    (ptr-set! p _uint8 (add1 i) (shift-right i 13))
    (ptr-set! p _uint8 (+ i 2)  0)
    (ptr-set! p _uint8 (+ i 3)  #xFF)))

(define frames 0)
(define total 0)

;; rendering loop
;; while a quit event is not received, render image to the window
(define (render-loop win win-sfc scr)
  (when (poll-loop)
    (define start (current-inexact-milliseconds))
    (render-to-surface scr)
    (sdl-blit-surface scr win-sfc)
    (sdl-update-window-surface win)
    (define end (current-inexact-milliseconds))
    (set! frames (add1 frames))
    (set! total (+ total (- end start)))
    (render-loop win win-sfc scr)))

(define (hex32 n)
  (~r n #:base 16 #:min-width 8 #:pad-string "0"))

(define (main)
  (sdl-init #:video? #t #:audio? #f)
  (define win (sdl-create-window "Load BMP" width height))
  (define win-sfc (sdl-get-window-surface win))
  (define sfc (sdl-create-rgb-surface-with-format width height 32 SDL-PIXEL-FORMAT-RGB888))
  (unless (and win win-sfc sfc)
    (error 'create-window
           (format "Could not create SDL window or surface: ~a" (sdl-get-error))))
  (printf "Must lock RGB surface? ~a\n" (sdl-must-lock-surface? sfc))
  (define sfc-format (sdl-surface-format sfc))
  (printf "Surface format name: ~a\n"
          (sdl-get-pixel-format-name
           (SDL_PixelFormat-format sfc-format)))
  (printf "Bits per pixel: ~a - Bytes per pixel: ~a\n"
          (SDL_PixelFormat-BitsPerPixel sfc-format)
          (SDL_PixelFormat-BytesPerPixel sfc-format))
  (printf "Red Mask: ~a - Blue Mask: ~a - Green Mask: ~a\n"
          (hex32 (SDL_PixelFormat-Rmask sfc-format))
          (hex32 (SDL_PixelFormat-Gmask sfc-format))
          (hex32 (SDL_PixelFormat-Bmask sfc-format)))
  (printf "MapRGB(FF, 0, 0) = ~a\n"
          (hex32 (sdl-map-rgb sfc-format 255 0 0)))
  (printf "MapRGB(0, FF, 0) = ~a\n"
          (hex32 (sdl-map-rgb sfc-format 0 255 0)))
  (printf "MapRGB(0, 0, FF) = ~a\n"
          (hex32 (sdl-map-rgb sfc-format 0 0 255)))
  (init-surface sfc)
  (render-loop win win-sfc sfc)
  (printf "Rendered ~a frames, average ~a ms/frame\n" frames (/ total frames))
  (sdl-quit))

(module+ main
  (main))
