;;
;; events.rkt
;; Support for SDL events
;;

#lang racket

(require ffi/unsafe)

(require "base.rkt")
(require (for-syntax "base.rkt"))

(provide (all-defined-out))

;;
;; --- Constants ---------------------------------
;;

(define SDL-RELEASED 0)
(define SDL-PRESSED  1)
(define SDL-QUERY   -1)
(define SDL-IGNORE   0)
(define SDL-DISABLE  0)
(define SDL-ENABLE   1)

;; event types
(define SDL-FIRSTEVENT                  0)

(define SDL-QUIT                    #x100)
(define SDL-APP-TERMINATING         #x101)
(define SDL-APP-LOWMEMORY           #x102)
(define SDL-APP-WILLENTERBACKGROUND #x103)
(define SDL-APP-DIDENTERBACKGROUND  #x104)
(define SDL-APP-WILLENTERFOREGROUND #x105)
(define SDL-APP-DIDENTERFOREGROUND  #x106)

(define SDL-WINDOWEVENT      #x200)
(define SDL-SYSWMEVENT       #x201)

(define SDL-KEYDOWN          #x300)
(define SDL-KEYUP            #x301)
(define SDL-TEXTEDITING      #x302)
(define SDL-TEXTINPUT        #x303)

(define SDL-MOUSEMOTION      #x400)
(define SDL-MOUSEBUTTONDOWN  #x401)
(define SDL-MOUSEBUTTONUP    #x402)
(define SDL-MOUSEWHEEL       #x403)

(define SDL-JOYAXISMOTION    #x600)
(define SDL-JOYBALLMOTION    #x601)
(define SDL-JOYHATMOTION     #x602)
(define SDL-JOYBUTTONDOWN    #x603)
(define SDL-JOYBUTTONUP      #x604)
(define SDL-JOYDEVICEADDED   #x605)
(define SDL-JOYDEVICEREMOVED #x606)

(define SDL-CONTROLLERAXISMOTION     #x650)
(define SDL-CONTROLLERBUTTONDOWN     #x651)
(define SDL-CONTROLLERBUTTONUP       #x652)
(define SDL-CONTROLLERDEVICEADDED    #x653)
(define SDL-CONTROLLERDEVICEREMOVED  #x654)
(define SDL-CONTROLLERDEVICEREMAPPED #x655)

(define SDL-FINGERDOWN       #x700)
(define SDL-FINGERUP         #x701)
(define SDL-FINGERMOTION     #x702)

(define SDL-DOLLARGESTURE    #x800)
(define SDL-DOLLARRECORD     #x801)
(define SDL-MULTIGESTURE     #x802)

(define SDL-CLIPBOARDUPDATE  #x900)
(define SDL-DROPFILE         #x1000)
(define SDL-USEREVENT        #x8000)

(define SDL-LASTEVENT        #xFFFF)


(define _SDL_eventaction
  (_enum
   '(SDL_ADDEVENT
     SDL_PEEKEVENT
     SDL_GETEVENT)))

;;
;; --- Types & structures ------------------------
;;

(define _SDL_Joystick _pointer)
(define SDL_JoystickID _int32)

(define-cstruct _SDL_JoystickGUID
  ([data  (make-array-type _uint8 16)]))

(define SDL_TouchID _int64)
(define SDL_FingerID _int64)

(define-cstruct _SDL_Finger
  ([id SDL_FingerID]
   [x _float]
   [y _float]
   [pressure _float]))

(define SDL_GestureID _int64)

(define-cstruct _SDL_CommonEvent
  ([type _uint32]
   [timestamp _uint32]))


(define-cstruct _SDL_WindowEvent
  ([type _uint32]
   [timestamp _uint32]
   [windowID _uint32]
   [event _uint8]
   [padding1 _uint8]
   [padding2 _uint8]
   [padding3 _uint8]
   [data1 _int32]
   [data2 _int32]))

(define-cstruct _SDL_KeyboardEvent
  ([type _uint32]
   [timestamp _uint32]
   [windowID _uint32]
   [state _uint8]
   [repeat _uint8]
   [padding2 _uint8]
   [padding3 _uint8]))

(define-cstruct _SDL_TextEditingEvent
  ([type _uint32]
   [timestamp _uint32]
   [windowID _uint32]
   [text _string]
   [start _int32]
   [length _int32]))

(define-cstruct _SDL_TextInputEvent
  ([type _uint32]
   [timestamp _uint32]
   [windowID _uint32]
   [text _string]))

(define-cstruct _SDL_MouseMotionEvent
  ([type _uint32]
   [timestamp _uint32]
   [windowID _uint32]
   [which _uint32]
   [state _uint32]
   [x _int32]
   [y _int32]
   [xrel _int32]
   [yrel _int32]))

(define-cstruct _SDL_MouseButtonEvent
  ([type _uint32]
   [timestamp _uint32]
   [windowID _uint32]
   [which _uint32]
   [button _uint8]
   [state _uint8]
   [padding1 _uint8]
   [padding2 _uint8]
   [x _int32]
   [y _int32]))

(define-cstruct _SDL_MouseWheelEvent
  ([type _uint32]
   [timestamp _uint32]
   [windowID _uint32]
   [which _uint32]
   [x _int32]
   [y _int32]))

(define-cstruct _SDL_JoyAxisEvent
  ([type _uint32]
   [timestamp _uint32]
   [which SDL_JoystickID]
   [axis _uint8]
   [padding1 _uint8]
   [padding2 _uint8]
   [padding3 _uint8]
   [value _int16]
   [padding4 _uint16]))

(define-cstruct _SDL_JoyBallEvent
  ([type _uint32]
   [timestamp _uint32]
   [which SDL_JoystickID]
   [ball _uint8]
   [padding1 _uint8]
   [padding2 _uint8]
   [padding3 _uint8]
   [xrel _int16]
   [yrel _int16]))


(define-cstruct _SDL_JoyHatEvent
  ([type _uint32]
   [timestamp _uint32]
   [which SDL_JoystickID]
   [hat _uint8]
   [value _uint8]
   [padding1 _uint8]
   [padding2 _uint8]))


(define-cstruct _SDL_JoyButtonEvent
  ([type _uint32]
   [timestamp _uint32]
   [which SDL_JoystickID]
   [button _uint8]
   [state _uint8]
   [padding1 _uint8]
   [padding2 _uint8]))

(define-cstruct _SDL_JoyDeviceEvent
  ([type _uint32]
   [timestamp _uint32]
   [which _int32]))

(define-cstruct _SDL_ControllerAxisEvent
  ([type _uint32]
   [timestamp _uint32]
   [which SDL_JoystickID]
   [axis _uint8]
   [padding1 _uint8]
   [padding2 _uint8]
   [padding3 _uint8]
   [value _int16]
   [padding4 _uint16]))

(define-cstruct _SDL_ControllerButtonEvent
  ([type _uint32]
   [timestamp _uint32]
   [which SDL_JoystickID]
   [button _uint8]
   [state _uint8]
   [padding1 _uint8]
   [padding2 _uint8]))

(define-cstruct _SDL_ControllerDeviceEvent
  ([type _uint32]
   [timestamp _uint32]
   [which _int32]))

(define-cstruct _SDL_TouchFingerEvent
  ([type _uint32]
   [timestamp _uint32]
   [touchId SDL_TouchID]
   [fingerId SDL_FingerID]
   [x _float]
   [y _float]
   [dx _float]
   [dy _float]
   [pressure _float]))

(define-cstruct _SDL_MultiGestureEvent
  ([type _uint32]
   [timestamp _uint32]
   [touchId SDL_TouchID]
   [dTheta _float]
   [dDist _float]
   [x _float]
   [y _float]
   [numFingers _uint16]
   [padding _uint16]))

(define-cstruct _SDL_DollarGestureEvent
  ([type _uint32]
   [timestamp _uint32]
   [touchId SDL_TouchID]
   [gestureId SDL_GestureID]
   [numFingers _uint32]
   [error _float]
   [x _float]
   [y _float]))

(define-cstruct _SDL_DropEvent
  ([type _uint32]
   [timestamp _uint32]
   [file _string]))


(define-cstruct _SDL_QuitEvent
  ([type _uint32]
   [timestamp _uint32]))


(define-cstruct _SDL_OSEvent
  ([type _uint32]
   [timestamp _uint32]))


(define-cstruct _SDL_UserEvent
  ([type _uint32]
   [timestamp _uint32]
   [windowID _uint32]
   [code _int32]
   [data1 _pointer]
   [data2 _pointer]))


(define-cpointer-type _SDL_SysWMmsg)

(define-cstruct _SDL_SysWMEvent
  ([type _uint32]
   [timestamp _uint32]
   [msg _SDL_SysWMmsg]))


(define _SDL_Event
  (_union _uint32 ;type
          _SDL_CommonEvent ;common
          _SDL_WindowEvent ;window
          _SDL_KeyboardEvent ;key
          _SDL_TextEditingEvent ;edit
          _SDL_TextInputEvent ;text
          _SDL_MouseMotionEvent ;motion
          _SDL_MouseButtonEvent ;button
          _SDL_MouseWheelEvent ;wheel
          _SDL_JoyAxisEvent ;jaxis
          _SDL_JoyBallEvent ;jball
          _SDL_JoyHatEvent ;jhat
          _SDL_JoyButtonEvent ;jbutton
          _SDL_JoyDeviceEvent ;jdevice
          _SDL_ControllerAxisEvent ;caxis
          _SDL_ControllerButtonEvent ;cbutton
          _SDL_ControllerDeviceEvent ;cdevice
          _SDL_QuitEvent ;quit
          _SDL_UserEvent ;user
          _SDL_SysWMEvent ;syswm
          _SDL_TouchFingerEvent ;tfinger
          _SDL_MultiGestureEvent ;mgesture
          _SDL_DollarGestureEvent ;dgesture
          _SDL_DropEvent ;drop
          (make-array-type _uint8 56)))  ;padding

(define-cpointer-type _SDL_Event*)
(define-cpointer-type _SDL_EventFilter*)

;;
;; --- Function definitions ----------------------
;;

;extern DECLSPEC void SDLCALL SDL_PumpEvents(void);
(define-sdl  SDL_PumpEvents (_fun -> _void))
;extern DECLSPEC int SDLCALL SDL_PeepEvents(SDL_Event * events, int numevents, SDL_eventaction action, Uint32 minType, Uint32 maxType);
(define-sdl  SDL_PeepEvents (_fun _SDL_Event* _int _SDL_eventaction _uint32 _uint32 -> _int))
;extern DECLSPEC SDL_bool SDLCALL SDL_HasEvent(Uint32 type);
(define-sdl  SDL_HasEvent (_fun _uint32 -> _bool))
;extern DECLSPEC SDL_bool SDLCALL SDL_HasEvents(Uint32 minType, Uint32 maxType);
(define-sdl  SDL_HasEvents (_fun _uint32 _uint32 -> _bool))
;extern DECLSPEC void SDLCALL SDL_FlushEvent(Uint32 type);
(define-sdl  SDL_FlushEvent (_fun _uint32 -> _void))
;extern DECLSPEC void SDLCALL SDL_FlushEvents(Uint32 minType, Uint32 maxType);
(define-sdl  SDL_FlushEvents (_fun _uint32 _uint32 -> _void))

;extern DECLSPEC int SDLCALL SDL_PollEvent(SDL_Event * event);
(define-sdl  SDL_PollEvent (_fun _SDL_Event* -> _int))

(define sdl-poll-event SDL_PollEvent)

;; allocates a new event in every call
(define (sdl-next-event)
  (define e (malloc _SDL_Event 'atomic))
  (cpointer-push-tag! e SDL_Event*-tag)
  (define count (SDL_PollEvent e))
  (if (= count 1) e #f))

(define (sdl-event-has-type? e t)
  (= (union-ref (ptr-ref e _SDL_Event) 0)
     t))

(define (sdl-allocate-event)
  (define res (malloc _SDL_Event 'atomic))
  (cpointer-push-tag! res SDL_Event*-tag)
  res)

(define current-event #f)

(define (sdl-init-events)
  (set! current-event (malloc _SDL_Event 'atomic))
  (cpointer-push-tag! current-event SDL_Event*-tag))

(define (sdl-process-event)
  (define count (sdl-poll-event current-event))
  (= count 1))

;; TODO: query about the event
;; TODO: match-event to test event type & destructure it


;extern DECLSPEC int SDLCALL SDL_WaitEvent(SDL_Event * event);
(define-sdl  SDL_WaitEvent (_fun _SDL_Event* -> _int))
;extern DECLSPEC int SDLCALL SDL_WaitEventTimeout(SDL_Event * event, int timeout);
(define-sdl  SDL_WaitEventTimeout (_fun _SDL_Event* _int -> _int))
;extern DECLSPEC int SDLCALL SDL_PushEvent(SDL_Event * event);
(define-sdl  SDL_PushEvent (_fun _SDL_Event* -> _int))
;typedef int (SDLCALL * SDL_EventFilter) (void *userdata, SDL_Event * event);
(define SDL_EventFilter (_fun _pointer _SDL_Event* -> _int))
;extern DECLSPEC void SDLCALL SDL_SetEventFilter(SDL_EventFilter filter, void *userdata);
(define-sdl  SDL_SetEventFilter (_fun SDL_EventFilter _pointer -> _void))
;extern DECLSPEC SDL_bool SDLCALL SDL_GetEventFilter(SDL_EventFilter * filter,void **userdata);
(define-sdl  SDL_GetEventFilter (_fun _SDL_EventFilter* _pointer -> _bool))
;extern DECLSPEC void SDLCALL SDL_AddEventWatch(SDL_EventFilter filter, void *userdata);
(define-sdl  SDL_AddEventWatch (_fun SDL_EventFilter _pointer -> _void))
;extern DECLSPEC void SDLCALL SDL_DelEventWatch(SDL_EventFilter filter, void *userdata);
(define-sdl  SDL_DelEventWatch (_fun SDL_EventFilter _pointer -> _void))
;extern DECLSPEC void SDLCALL SDL_FilterEvents(SDL_EventFilter filter, void *userdata);
(define-sdl  SDL_FilterEvents (_fun SDL_EventFilter _pointer -> _void))
;extern DECLSPEC Uint8 SDLCALL SDL_EventState(Uint32 type, int state);
(define-sdl  SDL_EventState (_fun _uint32 _int -> _uint8))
;#define SDL_GetEventState(type) SDL_EventState(type, SDL_QUERY)
(define (SDL_GetEventState type) (SDL_EventState type SDL-QUERY))
;extern DECLSPEC Uint32 SDLCALL SDL_RegisterEvents(int numevents);
(define-sdl  SDL_RegisterEvents (_fun _int -> _uint32))
