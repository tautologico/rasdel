;;
;; base.rkt
;; Definitions for basic functionality
;;
;; - init & shutdown
;; - errors
;; - version
;; - configuration hints
;;

#lang racket

(require ffi/unsafe
         ffi/unsafe/define)

(provide (all-defined-out))

;; load ffi dll lib
(define (sdl-get-lib)
  (let ([type (system-type 'os)])
    (case type
      [(unix)     "libSDL2"]
      [(windows)  "SDL2"]
      [(macosx)   "libSDL2"]
      [else (error "Platform not supported: " type)])))

(define-ffi-definer define-sdl (ffi-lib (sdl-get-lib) #f))

(define-syntax-rule (sdl-error e)
  (when e
    (error 'sdl (SDL_GetError))))

;;;
;;; Wrapper functions
;;;

(define (build-subsystem-flags subs)
  (bitwise-ior
   (if (member 'video subs)   SDL_INIT_VIDEO 0)
   (if (member 'audio subs)   SDL_INIT_AUDIO 0)
   (if (member 'control subs) SDL_INIT_GAMECONTROLLER 0)
   (if (member 'timer subs)   SDL_INIT_TIMER 0)
   (if (member 'haptic subs)  SDL_INIT_HAPTIC 0)))

(define (sdl-init #:video? [video? #t] #:audio? [audio? #t])
  (define mask
    (bitwise-ior (if video? SDL_INIT_VIDEO 0)
                 (if audio? SDL_INIT_AUDIO 0)))
  (SDL_Init mask))

;; TODO: add contract for init-subsystem
(define (sdl-init-subsystems . subs)
  (SDL_InitSubSystem (build-subsystem-flags subs)))

(define (sdl-was-init? sub)
  (not (zero? (SDL_WasInit (build-subsystem-flags (list sub))))))

;; TODO: automatically register for finalization
(define (sdl-quit)
  (SDL_Quit))

;;;
;;; Functions from C API
;;;

;;; base pointer types
(define-cpointer-type _uint8*)
(define-cpointer-type _int8*)
(define-cpointer-type _uint16*)
(define-cpointer-type _int16*)
(define-cpointer-type _uint32*)
(define-cpointer-type _int32*)
(define-cpointer-type _int*)
(define-cpointer-type _size*)
(define-cpointer-type _float*)


;;; --- SDL.h ------------------------------------
(define SDL_INIT_TIMER          #x00000001)
(define SDL_INIT_AUDIO          #x00000010)
(define SDL_INIT_VIDEO          #x00000020)
(define SDL_INIT_JOYSTICK       #x00000200)
(define SDL_INIT_HAPTIC         #x00001000)
(define SDL_INIT_GAMECONTROLLER #x00002000) ;turn on game controller also implicitly does JOYSTICK
(define SDL_INIT_EVERYTHING
  (bitwise-ior #x00000001 #x00000010 #x00000020 #x00000200 #x00001000 #x00002000))

;extern DECLSPEC int SDLCALL SDL_Init(Uint32 flags);
(define-sdl SDL_Init (_fun _uint32 -> [e : _bool]
                           -> (sdl-error e)))
;extern DECLSPEC int SDLCALL SDL_InitSubSystem(Uint32 flags);
(define-sdl SDL_InitSubSystem (_fun _uint32 -> [e : _bool]
                                    -> (sdl-error e)))
;extern DECLSPEC void SDLCALL SDL_QuitSubSystem(Uint32 flags);
(define-sdl SDL_QuitSubSystem (_fun _uint32 -> _void))
;extern DECLSPEC Uint32 SDLCALL SDL_WasInit(Uint32 flags);
(define-sdl SDL_WasInit (_fun _uint32 -> _uint32))
;extern DECLSPEC void SDLCALL SDL_Quit(void);
(define-sdl SDL_Quit (_fun -> _void))


; SDL_Platform.h

(define-sdl SDL_GetPlatform  (_fun -> _string))

; SDL_Main.h
;extern DECLSPEC void SDL_SetMainReady(void);
(define-sdl SDL_SetMainReady (_fun -> _void))

; SDL_version.h

(define-cstruct _SDL_version
  ((major _sint8)
   (minor _sint8)
   (patch _uint8)))

;extern DECLSPEC int SDLCALL SDL_GetRevisionNumber(void);
(define-sdl SDL_GetRevisionNumber (_fun -> _int))
;extern DECLSPEC void SDLCALL SDL_GetVersion(SDL_version * ver);
(define-sdl SDL_GetVersion (_fun [v : (_ptr o _SDL_version)] -> _void
                                 -> v))
;extern DECLSPEC const char *SDLCALL SDL_GetRevision(void);
(define-sdl SDL_GetRevision (_fun -> _string))

(struct sdl-version (major minor patch) #:transparent)

(define (sdl-get-version)
  (define ver (SDL_GetVersion))
  (sdl-version (SDL_version-major ver)
               (SDL_version-minor ver)
               (SDL_version-patch ver)))

(define sdl-revision-number (SDL_GetRevisionNumber))

(define (sdl-get-revision) (SDL_GetRevision))


;;; --- SDL_error.h ------------------------------
(define _SDL_errorcode
  (_enum
   '(SDL_ENOMEM
     SDL_EFREAD
     SDL_EFWRITE
     SDL_EFSEEK
     SDL_UNSUPPORTED
     SDL_LASTERROR)))

;; TODO: SDL_Error is an internal function; SDL_SetError
;; may not be very
;; useful for clients of this lib

;extern DECLSPEC int SDLCALL SDL_SetError(const char *fmt, ...);
(define-sdl SDL_SetError (_fun _string -> _int)) ;; TODO: varargs
;extern DECLSPEC const char *SDLCALL SDL_GetError(void);
(define-sdl SDL_GetError (_fun -> _string))
;extern DECLSPEC void SDLCALL SDL_ClearError(void);
(define-sdl SDL_ClearError (_fun -> _void))
;extern DECLSPEC int SDLCALL SDL_Error(SDL_errorcode code);
(define-sdl SDL_Error (_fun _SDL_errorcode -> _int))

;; wrapper

(define (sdl-get-error) (SDL_GetError))


;;; --- SDL_hints.h ------------------------------
(define SDL_HINT_FRAMEBUFFER_ACCELERATION   "SDL_FRAMEBUFFER_ACCELERATION")
(define SDL_HINT_RENDER_DRIVER              "SDL_RENDER_DRIVER")
(define SDL_HINT_RENDER_OPENGL_SHADERS      "SDL_RENDER_OPENGL_SHADERS")
(define SDL_HINT_RENDER_SCALE_QUALITY       "SDL_RENDER_SCALE_QUALITY")
(define SDL_HINT_RENDER_VSYNC               "SDL_RENDER_VSYNC")
(define SDL_HINT_VIDEO_X11_XVIDMODE         "SDL_VIDEO_X11_XVIDMODE")
(define SDL_HINT_VIDEO_X11_XINERAMA         "SDL_VIDEO_X11_XINERAMA")
(define SDL_HINT_VIDEO_X11_XRANDR           "SDL_VIDEO_X11_XRANDR")
(define SDL_HINT_GRAB_KEYBOARD              "SDL_GRAB_KEYBOARD")
(define SDL_HINT_VIDEO_MINIMIZE_ON_FOCUS_LOSS   "SDL_VIDEO_MINIMIZE_ON_FOCUS_LOSS")
(define SDL_HINT_IDLE_TIMER_DISABLED        "SDL_IOS_IDLE_TIMER_DISABLED")
(define SDL_HINT_ORIENTATIONS               "SDL_IOS_ORIENTATIONS")
(define SDL_HINT_XINPUT_ENABLED             "SDL_XINPUT_ENABLED")
(define SDL_HINT_GAMECONTROLLERCONFIG       "SDL_GAMECONTROLLERCONFIG")
(define SDL_HINT_JOYSTICK_ALLOW_BACKGROUND_EVENTS "SDL_JOYSTICK_ALLOW_BACKGROUND_EVENTS")
(define SDL_HINT_ALLOW_TOPMOST              "SDL_ALLOW_TOPMOST")

(define _SDL_HintPriority
  (_enum
   '(SDL_HINT_DEFAULT
     SDL_HINT_NORMAL
     SDL_HINT_OVERRIDE)))

;SDL_bool  SDL_SetHintWithPriority(const char *name, const char *value, SDL_HintPriority priority);
(define-sdl SDL_SetHintWithPriority (_fun _string _string _SDL_HintPriority -> _bool))
;SDL_bool  SDL_SetHint(const char *name, const char *value);
(define-sdl SDL_SetHint (_fun _string _string -> _bool))
;const char *  SDL_GetHint(const char *name);
(define-sdl SDL_GetHint (_fun _string -> _string))
;void  SDL_ClearHints(void);
(define-sdl SDL_ClearHints (_fun -> _void))
