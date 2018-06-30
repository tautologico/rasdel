;;
;; vidquery.rkt
;; Using the raw C API to query information about video
;;

#lang racket

(require "../base.rkt")
(require "../video.rkt")

(define (print-display-modes dsp)
  (define num-modes (SDL_GetNumDisplayModes dsp))
  (for ([i (in-range num-modes)])
    (let ([mode (SDL_GetDisplayMode dsp i)])
      (printf "   ** Mode ~a: (~a, ~a) ~a\n"
              i (sdl-display-mode-w mode)
              (sdl-display-mode-h mode)
              (sdl-display-mode-refresh-rate mode)))))

(define (main)
  (define num-drivers (sdl-get-num-video-drivers))

  (printf "SDL recognizes ~a video drivers:\n" num-drivers)
  (for ([i (in-range num-drivers)])
    (printf "Driver ~a: ~a\n" i (sdl-get-video-driver-name i)))
  (sdl-init #:video? #t #:audio? #f)
  (define num-displays (SDL_GetNumVideoDisplays))
  (printf "\nSDL recognizes ~a video displays:\n" num-displays)
  (for ([i (in-range num-displays)])
    (let ([r (SDL_GetDisplayBounds i)])
      (printf " * Display ~a: ~a - Bounds: ~a ~a ~a ~a - modes: ~a\n"
              i (SDL_GetDisplayName i)
              (sdl-rect-x r)
              (sdl-rect-y r)
              (sdl-rect-w r)
              (sdl-rect-h r)
              (SDL_GetNumDisplayModes i))
      (print-display-modes i)))

  (sdl-quit))

(module+ main
  (main))
