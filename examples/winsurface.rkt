;;
;; winsurface.rkt
;;
;; Query information about the window surface
;; and render directly to it
;;

#lang racket

(require ffi/unsafe)

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
  (memset (SDL_Surface-pixels sfc) 0 (* (SDL_Surface-h sfc) (SDL_Surface-pitch sfc))))

;; Assume the surface doesn't need to be locked,
;; the pixel format is 32-bpp and pitch = 4 * width
(define (render-to-surface sfc)
  (define p (SDL_Surface-pixels sfc))
  (define f (SDL_Surface-format sfc))
  (for ([i (in-range 0 (* 4 width height) 4)])
    (ptr-set! p _int8 i         -1)
    (ptr-set! p _int8 (add1 i)   0)
    (ptr-set! p _int8 (+ i 2)    0)
    (ptr-set! p _int8 (+ i 3)    0)))

(define frames 0)
(define total 0)

;; rendering loop
;; while a quit event is not received, render image to the window
(define (render-loop win scr)
  (when (poll-loop)
    (define start (current-inexact-milliseconds))
    (render-to-surface scr)
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
  (define sfc-format (SDL_Surface-format win-sfc))
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
  (init-surface win-sfc)
  (render-loop win win-sfc)
  (printf "Rendered ~a frames, average ~a ms/frame\n" frames (/ total frames))
  (sdl-quit))

(module+ main
  (main))
