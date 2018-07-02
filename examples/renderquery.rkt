;;
;; renderquery.rkt
;;
;; Query information about the available render drivers
;;

#lang racket

(require "../base.rkt")
(require "../video.rkt")
(require "../events.rkt")

(define (main)
  (define num-drivers (sdl-get-num-render-drivers))
  (printf "SDL recognizes ~a render drivers:\n" num-drivers)
  (for ([i (in-range num-drivers)])
    (let ([info (sdl-get-render-driver-info i)])
      (printf "\nDriver ~a info: \n" i)
      (printf "  Name: ~a\n" (sdl-renderer-info-name info))
      (printf "  Number of texture formats: ~a\n" (sdl-renderer-info-num-texture-formats info))
      (printf "  Maximum texture width: ~a\n" (sdl-renderer-info-max-texture-width info))
      (printf "  Maximum texture height: ~a\n" (sdl-renderer-info-max-texture-height info)))))

(module+ main
  (main))
