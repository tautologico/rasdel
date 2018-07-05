;;
;; winsurface.rkt
;;
;; Query information about the window surface
;; and render directly to it
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

(define (init-surface sfc)
  (memset (sdl-surface-pixels sfc) 0 (* (sdl-surface-h sfc) (sdl-surface-pitch sfc))))


;; Assume the surface doesn't need to be locked,
;; the pixel format is 32-bpp and pitch = 4 * width
(define (render-to-surface sfc)
  (define p (sdl-surface-pixels sfc))
  (define f (sdl-surface-format sfc))
  (define pval (sdl-map-rgb f 0 0 255))
  (define b1 (band pval #xFF))
  (define b2 (shift-right (band pval #xFF00) 8))
  (define b3 (shift-right (band pval #xFF0000) 16))
  (define b4 (shift-right (band pval #xFF000000) 24))
  (for ([i (in-range 0 (* 4 width height) 4)])
    (ptr-set! p _uint8 i        b1)
    (ptr-set! p _uint8 (add1 i) b2)
    (ptr-set! p _uint8 (+ i 2)  b3)
    (ptr-set! p _uint8 (+ i 3)  b4)))

(define (render-to-surface2 sfc)
  (define p (sdl-surface-pixels sfc))
  (define f (sdl-surface-format sfc))
  (define pval (sdl-map-rgb f 0 0 255))
  (for ([i (in-range 0 (* width height))])
    (ptr-set! p _uint32 i pval)))

(define frames 0)
(define total 0)

;; rendering loop
;; while a quit event is not received, render image to the window
(define (render-loop win scr)
  (when (poll-loop)
    (define start (current-inexact-milliseconds))
    (render-to-surface2 scr)
    (define end (current-inexact-milliseconds))
    (sdl-update-window-surface win)
    (set! frames (add1 frames))
    (set! total (+ total (- end start)))
    (render-loop win scr)))

(define (hex32 n)
  (~r n #:base 16 #:min-width 8 #:pad-string "0"))

(define (main)
  (sdl-init #:video? #t #:audio? #f)
  (define win (sdl-create-window "Load BMP" width height))
  (define win-sfc (sdl-get-window-surface win))
  (unless (and win win-sfc)
    (error 'create-window
           (format "Could not create SDL window or get surface: ~a" (sdl-get-error))))
  (printf "Must lock window surface? ~a\n" (sdl-must-lock-surface? win-sfc))
  (define sfc-format (sdl-surface-format win-sfc))
  (printf "Window surface format name: ~a\n"
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
  (init-surface win-sfc)
  (render-loop win win-sfc)
  (printf "Rendered ~a frames, average ~a ms/frame\n" frames (/ total frames))
  (sdl-quit))

(module+ main
  (main))
