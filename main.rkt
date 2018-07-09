;;
;; main.rkt
;;
;; Main module for rasdel
;;

#lang racket

(require "base.rkt")
(require "video.rkt")
(require "events.rkt")

(provide
 sdl-init sdl-quit sdl-get-error
 sdl-get-num-render-drivers sdl-get-render-driver-info
 sdl-create-window sdl-create-renderer
 sdl-create-texture sdl-create-streaming-texture
 sdl-poll-event sdl-event-has-type?
 sdl-lock-texture sdl-unlock-texture
 sdl-render-copy sdl-render-present
 sdl-get-window-surface sdl-update-window-surface sdl-must-lock-surface?
 sdl-get-pixel-format-name sdl-map-rgb
 sdl-allocate-event sdl-next-event

 SDL_GetWindowFlags

 ;; structs
 (struct-out sdl-renderer-info)
 (struct-out sdl-surface)
 (struct-out SDL_PixelFormat)

 ;; events
 SDL-QUIT

 ;; pixel formats
 SDL-PIXEL-FORMAT-RGB888 SDL-PIXEL-FORMAT-RGBX8888
 SDL-PIXEL-FORMAT-BGR888 SDL-PIXEL-FORMAT-BGRX8888
 SDL-PIXEL-FORMAT-RGBA8888 SDL-PIXEL-FORMAT-ARGB8888)
