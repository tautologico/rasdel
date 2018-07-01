;;
;; log.rkt
;; Logging functions from SDL
;;

#lang racket

(require ffi/unsafe)

(require "base.rkt")
(require (for-syntax "base.rkt"))

;; constants
(define SDL_MAX_LOG_MESSAGE  4096)
(define SDL_LOG_CATEGORY_APPLICATION  0)
(define SDL_LOG_CATEGORY_ERROR  1)
(define SDL_LOG_CATEGORY_ASSERT  2)
(define SDL_LOG_CATEGORY_SYSTEM  3)
(define SDL_LOG_CATEGORY_AUDIO  4)
(define SDL_LOG_CATEGORY_VIDEO  5)
(define SDL_LOG_CATEGORY_RENDER  6)
(define SDL_LOG_CATEGORY_INPUT  7)
(define SDL_LOG_CATEGORY_TEST  8)
(define SDL_LOG_CATEGORY_RESERVED1  9)
(define SDL_LOG_CATEGORY_RESERVED2  10)
(define SDL_LOG_CATEGORY_RESERVED3  11)
(define SDL_LOG_CATEGORY_RESERVED4  12)
(define SDL_LOG_CATEGORY_RESERVED5  13)
(define SDL_LOG_CATEGORY_RESERVED6  14)
(define SDL_LOG_CATEGORY_RESERVED7  15)
(define SDL_LOG_CATEGORY_RESERVED8  16)
(define SDL_LOG_CATEGORY_RESERVED9  17)
(define SDL_LOG_CATEGORY_RESERVED10  18)
(define SDL_LOG_CATEGORY_CUSTOM  19)
(define SDL_LOG_PRIORITY_VERBOSE  1)
(define SDL_LOG_PRIORITY_DEBUG  2)
(define SDL_LOG_PRIORITY_INFO  3)
(define SDL_LOG_PRIORITY_WARN  4)
(define SDL_LOG_PRIORITY_ERROR  5)
(define SDL_LOG_PRIORITY_CRITICAL  6)
(define SDL_NUM_LOG_PRIORITIES  7)

;; types
(define SDL_LogPriority  _int)
(define-cpointer-type _SDL_LogOutputFunction*)

;; functions

(define SDL_LogOutputFunction (_fun _pointer _int SDL_LogPriority _string -> _void))
;extern DECLSPEC void SDLCALL SDL_LogSetAllPriority(SDL_LogPriority priority);
(define-sdl SDL_LogSetAllPriority (_fun SDL_LogPriority -> _void))
;extern DECLSPEC void SDLCALL SDL_LogSetPriority(int category, SDL_LogPriority priority);
(define-sdl SDL_LogSetPriority (_fun _int  SDL_LogPriority -> _void))
;extern DECLSPEC SDL_LogPriority SDLCALL SDL_LogGetPriority(int category);
(define-sdl SDL_LogGetPriority (_fun _int -> SDL_LogPriority))
;extern DECLSPEC void SDLCALL SDL_LogResetPriorities(void);
(define-sdl SDL_LogResetPriorities (_fun -> _void))
;extern DECLSPEC void SDLCALL SDL_Log(const char *fmt, ...);
(define-sdl SDL_Log (_fun _string -> _void))
;extern DECLSPEC void SDLCALL SDL_LogVerbose(int category, const char *fmt, ...);
(define-sdl SDL_LogVerbose (_fun _int  _string -> _void))
;extern DECLSPEC void SDLCALL SDL_LogDebug(int category, const char *fmt, ...);
(define-sdl SDL_LogDebug (_fun _int  _string  -> _void))
;extern DECLSPEC void SDLCALL SDL_LogInfo(int category, const char *fmt, ...);
(define-sdl SDL_LogInfo (_fun _int  _string -> _void))
;extern DECLSPEC void SDLCALL SDL_LogWarn(int category, const char *fmt, ...);
(define-sdl SDL_LogWarn (_fun _int  _string -> _void))
;extern DECLSPEC void SDLCALL SDL_LogError(int category, const char *fmt, ...);
(define-sdl SDL_LogError (_fun _int  _string  -> _void))
;extern DECLSPEC void SDLCALL SDL_LogCritical(int category, const char *fmt, ...);
(define-sdl SDL_LogCritical (_fun _int  _string  -> _void))
;extern DECLSPEC void SDLCALL SDL_LogMessage(int category, SDL_LogPriority priority, const char *fmt, ...);
(define-sdl SDL_LogMessage (_fun _int SDL_LogPriority _string -> _void))
;extern DECLSPEC void SDLCALL SDL_LogMessageV(int category, SDL_LogPriority priority, const char *fmt, va_list ap);
;typedef void (*SDL_LogOutputFunction)(void *userdata, int category, SDL_LogPriority priority, const char *message);
;extern DECLSPEC void SDLCALL SDL_LogGetOutputFunction(SDL_LogOutputFunction *callback, void **userdata);
(define-sdl SDL_LogGetOutputFunction (_fun _SDL_LogOutputFunction* _pointer -> _void))
;extern DECLSPEC void SDLCALL SDL_LogSetOutputFunction(SDL_LogOutputFunction callback, void *userdata);
(define-sdl SDL_LogSetOutputFunction (_fun SDL_LogOutputFunction _pointer -> _void))
