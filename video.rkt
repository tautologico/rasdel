;;
;; video.rkt
;; Graphics support
;;

#lang racket

(require ffi/unsafe)
(require ffi/unsafe/alloc)

(require "base.rkt")
(require (for-syntax "base.rkt"))

(provide (all-defined-out))

;;
;; wrapper functions
;;

(define (sdl-create-window title width height)
  (SDL_CreateWindow title SDL_WINDOWPOS_UNDEFINED SDL_WINDOWPOS_UNDEFINED
                    width height 0))

;;
;; Foreign API
;;

(define SDL_WINDOWPOS_UNDEFINED_MASK #x1FFF0000)
(define SDL_WINDOWPOS_UNDEFINED (bitwise-ior SDL_WINDOWPOS_UNDEFINED_MASK 0))

(define SDL_WINDOWPOS_CENTERED_MASK #x2FFF0000)
(define SDL_WINDOWPOS_CENTERED (bitwise-ior SDL_WINDOWPOS_CENTERED_MASK 0))


(define _SDL_WindowFlags
  (_enum
   `(SDL_WINDOW_FULLSCREEN = #x00000001;        /**< fullscreen window */
    SDL_WINDOW_OPENGL      = #x00000002;        /**< window usable with OpenGL context */
    SDL_WINDOW_SHOWN       = #x00000004;        /**< window is visible */
    SDL_WINDOW_HIDDEN      = #x00000008;        /**< window is not visible */
    SDL_WINDOW_BORDERLESS  = #x00000010;        /**< no window decoration */
    SDL_WINDOW_RESIZABLE   = #x00000020;        /**< window can be resized */
    SDL_WINDOW_MINIMIZED   = #x00000040;        /**< window is minimized */
    SDL_WINDOW_MAXIMIZED   = #x00000080;        /**< window is maximized */
    SDL_WINDOW_INPUT_GRABBED = #x00000100;      /**< window has grabbed input focus */
    SDL_WINDOW_INPUT_FOCUS = #x00000200;        /**< window has input focus */
    SDL_WINDOW_MOUSE_FOCUS = #x00000400;        /**< window has mouse focus */
    SDL_WINDOW_FULLSCREEN_DESKTOP = ,(bitwise-ior #x00000001 #x00001000 )
    SDL_WINDOW_FOREIGN = #x00000800)))

(define _SDL_WindowEventID
  (_enum
   '(SDL_WINDOWEVENT_NONE ; /**< Never used */
    SDL_WINDOWEVENT_SHOWN ;  /**< Window has been shown */
    SDL_WINDOWEVENT_HIDDEN;         /**< Window has been hidden */
    SDL_WINDOWEVENT_EXPOSED;        /**< Window has been exposed and should be redrawn */
    SDL_WINDOWEVENT_MOVED ;          /**< Window has been moved to data1, data2
    SDL_WINDOWEVENT_RESIZED;        /**< Window has been resized to data1xdata2 */
    SDL_WINDOWEVENT_SIZE_CHANGED;   /**< The window size has changed, either as a result of an API call or through the system or user changing the window size. */
    SDL_WINDOWEVENT_MINIMIZED;      /**< Window has been minimized */
    SDL_WINDOWEVENT_MAXIMIZED;      /**< Window has been maximized */
    SDL_WINDOWEVENT_RESTORED;       /**< Window has been restored to normal siz and position */
    SDL_WINDOWEVENT_ENTER;          /**< Window has gained mouse focus */
    SDL_WINDOWEVENT_LEAVE;          /**< Window has lost mouse focus */
    SDL_WINDOWEVENT_FOCUS_GAINED;   /**< Window has gained keyboard focus */
    SDL_WINDOWEVENT_FOCUS_LOST;     /**< Window has lost keyboard focus */
    SDL_WINDOWEVENT_CLOSE)));           /**< The window manager requests that the)))

(define-cstruct _sdl-display-mode
  ((format _uint32)
   (w _int)
   (h _int)
   (refresh-rate _int)
   (driver-data _pointer)))

(define-cpointer-type _SDL_Window*)
(define-cpointer-type _SDL_GLContext*)

(define-cstruct _SDL_Color
  ((r _uint8)
   (g _uint8)
   (b _uint8)))

(define-cstruct _SDL_Palette
  ((ncolors _int)
   (colors _SDL_Color-pointer)
   (version _uint32)
   (refcount _int)))

(define-cstruct _SDL_PixelFormat
  ([format _uint32]
   [palette _SDL_Palette-pointer]
   [BitsPerPixel _uint8]
   [BytesPerPixel _uint8]
   [padding (make-array-type _uint8 2)]
   [Rmask _uint32]
   [Gmask _uint32]
   [Bmask _uint32]
   [Amask _uint32]
   [Rloss _uint8]
   [Gloss _uint8]
   [Bloss _uint8]
   [Aloss _uint8]
   [Rshift _uint8]
   [Gshift _uint8]
   [Bshift _uint8]
   [Ashift _uint8]
   [refcount _int]
   [next _SDL_PixelFormat-pointer]))

(define-cstruct _SDL_Point
  ([x _int]
   [y _int]))

(define-cstruct _sdl-rect
  ([x _int]
   [y _int]
   [w _int]
   [h _int]))

(define-cstruct _SDL_Surface
  ([flags _uint32]
   [format _SDL_PixelFormat-pointer]
   [w _int]
   [h _int]
   [pitch _int]
   [pixels _pointer]
   [userdata _pointer]
   [locked _int]
   [lock_data _pointer]
   [clip_rect _sdl-rect]
   [map _pointer]
   [refcount _int]))

;; functions

;extern DECLSPEC int SDLCALL SDL_GetNumVideoDrivers(void);
(define-sdl SDL_GetNumVideoDrivers (_fun -> _int))
;extern DECLSPEC const char *SDLCALL SDL_GetVideoDriver(int index);
(define-sdl SDL_GetVideoDriver (_fun _int -> _string))

(define sdl-get-num-video-drivers SDL_GetNumVideoDrivers)
(define sdl-get-video-driver-name SDL_GetVideoDriver)

;extern DECLSPEC int SDLCALL SDL_VideoInit(const char *driver_name);
(define-sdl SDL_VideoInit (_fun _string -> _int))
;extern DECLSPEC void SDLCALL SDL_VideoQuit(void);
(define-sdl SDL_VideoQuit (_fun -> _void))

;extern DECLSPEC const char *SDLCALL SDL_GetCurrentVideoDriver(void);
(define-sdl SDL_GetCurrentVideoDriver (_fun -> _string))
;extern DECLSPEC int SDLCALL SDL_GetNumVideoDisplays(void);
(define-sdl SDL_GetNumVideoDisplays (_fun -> _int))
;extern DECLSPEC const char * SDLCALL SDL_GetDisplayName(int displayIndex);
(define-sdl SDL_GetDisplayName (_fun _int -> _string))

;extern DECLSPEC int SDLCALL SDL_GetDisplayBounds(int displayIndex, SDL_Rect * rect);
(define-sdl SDL_GetDisplayBounds (_fun _int [r : (_ptr o _sdl-rect)]
                                       -> (c : _int)
                                       -> (if (zero? c) r #f)))

;extern DECLSPEC int SDLCALL SDL_GetNumDisplayModes(int displayIndex);
(define-sdl SDL_GetNumDisplayModes (_fun _int -> _int))

;extern DECLSPEC int SDLCALL SDL_GetDisplayMode(int displayIndex, int modeIndex, SDL_DisplayMode * mode);
(define-sdl SDL_GetDisplayMode (_fun _int _int [dm : (_ptr o _sdl-display-mode)]
                                     -> (err : _int)
                                     -> (if (zero? err) dm #f)))

;extern DECLSPEC int SDLCALL SDL_GetDesktopDisplayMode(int displayIndex, SDL_DisplayMode * mode);
(define-sdl SDL_GetDesktopDisplayMode (_fun _int [dm : (_ptr o _sdl-display-mode)]
                                            -> (err : _int)
                                            -> (if (zero? err) dm #f)))

;extern DECLSPEC int SDLCALL SDL_GetCurrentDisplayMode(int displayIndex, SDL_DisplayMode * mode);
(define-sdl SDL_GetCurrentDisplayMode (_fun _int [dm : (_ptr o _sdl-display-mode)]
                                            -> (err : _int)
                                            -> (if (zero? err) dm #f)))

;extern DECLSPEC SDL_DisplayMode * SDLCALL SDL_GetClosestDisplayMode(int displayIndex, const SDL_DisplayMode * mode, SDL_DisplayMode * closest);
(define-sdl SDL_GetClosestDisplayMode (_fun _int _sdl-display-mode-pointer _sdl-display-mode-pointer -> _sdl-display-mode-pointer))
;extern DECLSPEC int SDLCALL SDL_GetWindowDisplayIndex(SDL_Window * window);
(define-sdl SDL_GetWindowDisplayIndex (_fun _SDL_Window* -> _int))
;extern DECLSPEC int SDLCALL SDL_SetWindowDisplayMode(SDL_Window * window,  const SDL_DisplayMode* mode);
(define-sdl SDL_SetWindowDisplayMode (_fun _SDL_Window* _sdl-display-mode-pointer -> _int))
;extern DECLSPEC int SDLCALL SDL_GetWindowDisplayMode(SDL_Window * window, SDL_DisplayMode * mode);
(define-sdl SDL_GetWindowDisplayMode (_fun _SDL_Window* _sdl-display-mode-pointer -> _int))
;extern DECLSPEC Uint32 SDLCALL SDL_GetWindowPixelFormat(SDL_Window * window);
(define-sdl SDL_GetWindowPixelFormat (_fun _SDL_Window* -> _uint32))

;extern DECLSPEC void SDLCALL SDL_DestroyWindow(SDL_Window * window);
(define-sdl SDL_DestroyWindow (_fun _SDL_Window* -> _void)
  #:wrap (deallocator))

;extern DECLSPEC SDL_Window * SDLCALL SDL_CreateWindow(const char *title, int x, int y, int w, int h, Uint32 flags);
(define-sdl SDL_CreateWindow (_fun _string _int _int _int _int _uint32
                                   -> _SDL_Window*)
  #:wrap (allocator SDL_DestroyWindow))

;extern DECLSPEC SDL_Window * SDLCALL SDL_CreateWindowFrom(const void *data);
(define-sdl SDL_CreateWindowFrom (_fun _pointer -> _SDL_Window*)
  #:wrap (allocator SDL_DestroyWindow))

;extern DECLSPEC Uint32 SDLCALL SDL_GetWindowID(SDL_Window * window);
(define-sdl SDL_GetWindowID (_fun _SDL_Window* -> _uint32))
;extern DECLSPEC SDL_Window * SDLCALL SDL_GetWindowFromID(Uint32 id);
(define-sdl SDL_GetWindowFromID (_fun _uint32 -> _SDL_Window*))
;extern DECLSPEC Uint32 SDLCALL SDL_GetWindowFlags(SDL_Window * window);
(define-sdl SDL_GetWindowFlags (_fun _SDL_Window* -> _uint32))
;extern DECLSPEC void SDLCALL SDL_SetWindowTitle(SDL_Window * window, const char *title);
(define-sdl SDL_SetWindowTitle (_fun _SDL_Window* _string -> _void))
;extern DECLSPEC const char *SDLCALL SDL_GetWindowTitle(SDL_Window * window);
(define-sdl SDL_GetWindowTitle (_fun _SDL_Window* -> _string))
;extern DECLSPEC void SDLCALL SDL_SetWindowIcon(SDL_Window * window, SDL_Surface * icon);
(define-sdl SDL_SetWindowIcon (_fun _SDL_Window* _SDL_Surface-pointer -> _void))
;extern DECLSPEC void* SDLCALL SDL_SetWindowData(SDL_Window * window, const char *name, void *userdata);
(define-sdl SDL_SetWindowData (_fun _SDL_Window* _string _pointer -> _pointer))
;extern DECLSPEC void *SDLCALL SDL_GetWindowData(SDL_Window * window, const char *name);
(define-sdl SDL_GetWindowData (_fun _SDL_Window* _string -> _pointer))
;extern DECLSPEC void SDLCALL SDL_SetWindowPosition(SDL_Window * window, int x, int y);
(define-sdl SDL_SetWindowPosition (_fun _SDL_Window* _int _int -> _void))

;extern DECLSPEC void SDLCALL SDL_GetWindowPosition(SDL_Window * window, int *x, int *y);
(define-sdl SDL_GetWindowPosition (_fun _SDL_Window* [x : (_ptr o _int)] [y : (_ptr o _int)]
                                        -> _void
                                        -> (values x y)))

;extern DECLSPEC void SDLCALL SDL_SetWindowSize(SDL_Window * window, int w, int h);
(define-sdl SDL_SetWindowSize (_fun _SDL_Window* _int _int -> _void))

;extern DECLSPEC void SDLCALL SDL_GetWindowSize(SDL_Window * window, int *w, int *h);
(define-sdl SDL_GetWindowSize (_fun _SDL_Window* [w : (_ptr o _int)] [h : (_ptr o _int)]
                                    -> _void
                                    -> (values w h)))

;extern DECLSPEC void SDLCALL SDL_SetWindowMinimumSize(SDL_Window * window, int min_w, int min_h);
(define-sdl SDL_SetWindowMinimumSize (_fun _SDL_Window* _int _int -> _void))

;extern DECLSPEC void SDLCALL SDL_GetWindowMinimumSize(SDL_Window * window, int *w, int *h);
(define-sdl SDL_GetWindowMinimumSize (_fun _SDL_Window* [w : (_ptr o _int)] [h : (_ptr o _int)]
                                           -> _void
                                           -> (values w h)))

;extern DECLSPEC void SDLCALL SDL_SetWindowMaximumSize(SDL_Window * window, int max_w, int max_h);
(define-sdl SDL_SetWindowMaximumSize (_fun _SDL_Window* _int _int -> _void))

;extern DECLSPEC void SDLCALL SDL_GetWindowMaximumSize(SDL_Window * window, int *w, int *h);
(define-sdl SDL_GetWindowMaximumSize (_fun _SDL_Window* [w : (_ptr o _int)] [h : (_ptr o _int)]
                                           -> _void
                                           -> (values w h)))

;extern DECLSPEC void SDLCALL SDL_SetWindowBordered(SDL_Window * window, SDL_bool bordered);
(define-sdl SDL_SetWindowBordered (_fun _SDL_Window* _bool -> _void))
;extern DECLSPEC void SDLCALL SDL_ShowWindow(SDL_Window * window);
(define-sdl SDL_ShowWindow (_fun _SDL_Window* -> _void))
;extern DECLSPEC void SDLCALL SDL_HideWindow(SDL_Window * window);
(define-sdl SDL_HideWindow (_fun _SDL_Window* -> _void))
;extern DECLSPEC void SDLCALL SDL_RaiseWindow(SDL_Window * window);
(define-sdl SDL_RaiseWindow (_fun _SDL_Window* -> _void))
;extern DECLSPEC void SDLCALL SDL_MaximizeWindow(SDL_Window * window);
(define-sdl SDL_MaximizeWindow (_fun _SDL_Window* -> _void))
;extern DECLSPEC void SDLCALL SDL_MinimizeWindow(SDL_Window * window);
(define-sdl SDL_MinimizeWindow (_fun _SDL_Window* -> _void))
;extern DECLSPEC void SDLCALL SDL_RestoreWindow(SDL_Window * window);
(define-sdl SDL_RestoreWindow (_fun _SDL_Window* -> _void))
;extern DECLSPEC int SDLCALL SDL_SetWindowFullscreen(SDL_Window * window, Uint32 flags);
(define-sdl SDL_SetWindowFullscreen (_fun _SDL_Window* _uint32 -> _int))

;extern DECLSPEC SDL_Surface * SDLCALL SDL_GetWindowSurface(SDL_Window * window);
(define-sdl SDL_GetWindowSurface (_fun _SDL_Window* -> _SDL_Surface-pointer))

(define sdl-get-window-surface SDL_GetWindowSurface)

;extern DECLSPEC int SDLCALL SDL_UpdateWindowSurface(SDL_Window * window);
(define-sdl SDL_UpdateWindowSurface (_fun _SDL_Window*
                                          -> (err : _int)
                                          -> (zero? err)))

(define sdl-update-window-surface SDL_UpdateWindowSurface)


;extern DECLSPEC int SDLCALL SDL_UpdateWindowSurfaceRects(SDL_Window * window, const SDL_Rect * rects, int numrects);
(define-sdl SDL_UpdateWindowSurfaceRects (_fun _SDL_Window* _sdl-rect-pointer _int -> _int))
;extern DECLSPEC void SDLCALL SDL_SetWindowGrab(SDL_Window * window, SDL_bool grabbed);
(define-sdl SDL_SetWindowGrab (_fun _SDL_Window* _bool -> _void))
;extern DECLSPEC SDL_bool SDLCALL SDL_GetWindowGrab(SDL_Window * window);
(define-sdl SDL_GetWindowGrab (_fun _SDL_Window* -> _bool))
;extern DECLSPEC int SDLCALL SDL_SetWindowBrightness(SDL_Window * window, float brightness);
(define-sdl SDL_SetWindowBrightness (_fun _SDL_Window* _float -> _int))
;extern DECLSPEC float SDLCALL SDL_GetWindowBrightness(SDL_Window * window);
(define-sdl SDL_GetWindowBrightness (_fun _SDL_Window* -> _float))
;extern DECLSPEC int SDLCALL SDL_SetWindowGammaRamp(SDL_Window * window, const Uint16 * red, const Uint16 * green, const Uint16 * blue);
(define-sdl SDL_SetWindowGammaRamp (_fun _SDL_Window* _uint16* _uint16* _uint16* -> _int))
;extern DECLSPEC int SDLCALL SDL_GetWindowGammaRamp(SDL_Window * window, Uint16 * red, Uint16 * green, Uint16 * blue);
(define-sdl SDL_GetWindowGammaRamp (_fun _SDL_Window* _uint16* _uint16* _uint16* -> _int))

;extern DECLSPEC SDL_bool SDLCALL SDL_IsScreenSaverEnabled(void);
(define-sdl SDL_IsScreenSaverEnabled (_fun -> _bool))
;extern DECLSPEC void SDLCALL SDL_EnableScreenSaver(void);
(define-sdl SDL_EnableScreenSaver (_fun -> _void))
;extern DECLSPEC void SDLCALL SDL_DisableScreenSaver(void);
(define-sdl SDL_DisableScreenSaver (_fun -> _void))

;;
;; --- Pixel formats (SDL_pixels.h) --------------
;;

;; pixel type
(define SDL-PIXEL-TYPE-UNKNOWN  0)
(define SDL-PIXEL-TYPE-INDEX1   1)
(define SDL-PIXEL-TYPE-INDEX4   2)
(define SDL-PIXEL-TYPE-INDEX8   3)
(define SDL-PIXEL-TYPE-PACKED8  4)
(define SDL-PIXEL-TYPE-PACKED16 5)
(define SDL-PIXEL-TYPE-PACKED32 6)
(define SDL-PIXEL-TYPE-ARRAYU8  7)
(define SDL-PIXEL-TYPE-ARRAYU16 8)
(define SDL-PIXEL-TYPE-ARRAYU32 9)
(define SDL-PIXEL-TYPE-ARRAYF16 10)
(define SDL-PIXEL-TYPE-ARRAYF32 11)

;; bitmap pixel order, high bit -> low bit
(define SDL-BITMAP-ORDER-NONE 0)
(define SDL-BITMAP-ORDER-4321 1)
(define SDL-BITMAP-ORDER-1234 2)

;; packed component order, high bit -> low bit
(define SDL-PACKED-ORDER-NONE 0)
(define SDL-PACKED-ORDER-XRGB 1)
(define SDL-PACKED-ORDER-RGBX 2)
(define SDL-PACKED-ORDER-ARGB 3)
(define SDL-PACKED-ORDER-RGBA 4)
(define SDL-PACKED-ORDER-XBGR 5)
(define SDL-PACKED-ORDER-BGRX 6)
(define SDL-PACKED-ORDER-ABGR 7)
(define SDL-PACKED-ORDER-BGRA 8)

;; array component order
(define SDL-ARRAY-ORDER-NONE 0)
(define SDL-ARRAY-ORDER-RGB  1)
(define SDL-ARRAY-ORDER-RGBA 2)
(define SDL-ARRAY-ORDER-ARGB 3)
(define SDL-ARRAY-ORDER-BGR  4)
(define SDL-ARRAY-ORDER-BGRA 5)
(define SDL-ARRAY-ORDER-ABGR 6)


(define (define-pixel-format type order layout bits bytes)
  (bitwise-ior (arithmetic-shift 1 28)
               (arithmetic-shift type 24)
               (arithmetic-shift order 20)
               (arithmetic-shift layout 16)
               (arithmetic-shift bits 8)
               (arithmetic-shift bytes 0)))

;; pixel format constants
(define SDL_PIXELFORMAT_UNKNOWN 0)
#;(define SDL_PIXELFORMAT_INDEX1LSB
  (define-pixel-format ))

;extern DECLSPEC const char* SDLCALL SDL_GetPixelFormatName(Uint32 format);
(define-sdl SDL_GetPixelFormatName (_fun _uint32 -> _string))

(define sdl-get-pixel-format-name SDL_GetPixelFormatName)

;SDL_bool SDLCALL SDL_PixelFormatEnumToMasks(Uint32 format, int *bpp,Uint32 * Rmask,Uint32 * Gmask,Uint32 * Bmask, Uint32 * Amask);
(define-sdl SDL_PixelFormatEnumToMasks (_fun _uint32 _uint32* _uint32* _uint32* _uint32*  -> _bool))
;Uint32 SDL_MasksToPixelFormatEnum(int bpp, Uint32 Rmask, Uint32 Gmask,Uint32 Bmask,Uint32 Amask);
(define-sdl SDL_MasksToPixelFormatEnum (_fun _int _uint32 _uint32 _uint32 _uint32  -> _uint32))
;extern DECLSPEC SDL_PixelFormat * SDLCALL SDL_AllocFormat(Uint32 pixel_format);
(define-sdl SDL_AllocFormat (_fun _uint32  -> _SDL_PixelFormat-pointer))
;extern DECLSPEC void SDLCALL SDL_FreeFormat(SDL_PixelFormat *format);
(define-sdl SDL_FreeFormat (_fun _SDL_PixelFormat-pointer  -> _void))
;extern DECLSPEC SDL_Palette *SDLCALL SDL_AllocPalette(int ncolors);
(define-sdl SDL_AllocPalette (_fun _int  -> _SDL_Palette-pointer))
;extern DECLSPEC int SDLCALL SDL_SetPixelFormatPalette(SDL_PixelFormat * format, SDL_Palette *palette);
(define-sdl SDL_SetPixelFormatPalette (_fun _SDL_PixelFormat-pointer _SDL_Palette-pointer  -> _int))
;extern DECLSPEC int SDLCALL SDL_SetPaletteColors(SDL_Palette * palette, const SDL_Color * colors, int firstcolor, int ncolors);
(define-sdl SDL_SetPaletteColors (_fun _SDL_Palette-pointer _SDL_Color-pointer _int _int  -> _int))
;extern DECLSPEC void SDLCALL SDL_FreePalette(SDL_Palette * palette)
(define-sdl SDL_FreePalette (_fun _SDL_Palette-pointer -> _void))

;extern DECLSPEC Uint32 SDLCALL SDL_MapRGB(const SDL_PixelFormat * format, Uint8 r, Uint8 g, Uint8 b);
(define-sdl SDL_MapRGB (_fun _SDL_PixelFormat-pointer _uint8 _uint8 _uint8 -> _uint32))

;extern DECLSPEC Uint32 SDLCALL SDL_MapRGBA(const SDL_PixelFormat * format, Uint8 r, Uint8 g, Uint8 b, Uint8 a);
(define-sdl SDL_MapRGBA (_fun _SDL_PixelFormat-pointer _uint8 _uint8 _uint8 _uint8 -> _uint32))

;extern DECLSPEC void SDLCALL SDL_GetRGB(Uint32 pixel, const SDL_PixelFormat * format, Uint8 * r, Uint8 * g, Uint8 * b);
(define-sdl SDL_GetRGB (_fun _uint32 _SDL_PixelFormat-pointer _uint8* _uint8* _uint8* -> _void))

;extern DECLSPEC void SDLCALL SDL_GetRGBA(Uint32 pixel, const SDL_PixelFormat * format, Uint8 * r, Uint8 * g, Uint8 * b, Uint8 * a);
(define-sdl SDL_GetRGBA (_fun _uint32 _SDL_PixelFormat-pointer _uint8* _uint8* _uint8* _uint8* -> _void))

;extern DECLSPEC void SDLCALL SDL_CalculateGammaRamp(float gamma, Uint16 * ramp);
(define-sdl SDL_CalculateGammaRamp (_fun _float _uint16* -> _void))

;;
;; --- Surfaces and rectangles (SDL_surface.h) ---
;;

(define _SDL_BlendMode
  (_enum
   '(SDL_BLENDMODE_NONE = #x00000000
                        SDL_BLENDMODE_BLEND = #x00000001
                        SDL_BLENDMODE_ADD = #x00000002
                        SDL_BLENDMODE_MOD = #x00000004)))

(define (sdl-load-bmp file) (SDL_LoadBMP_RW (SDL_RWFromFile file "rb") 1))

(define (sdl-blit-surface src dest)
  (SDL_BlitSurface src #f dest #f))

;extern DECLSPEC void SDLCALL SDL_FreeSurface(SDL_Surface * surface);
(define-sdl SDL_FreeSurface (_fun _SDL_Surface-pointer -> _void)
  #:wrap (deallocator))


;extern DECLSPEC SDL_Surface *SDLCALL SDL_CreateRGBSurface (Uint32 flags, int width, int height, int depth, Uint32 Rmask, Uint32 Gmask, Uint32 Bmask, Uint32 Amask);
(define-sdl SDL_CreateRGBSurface (_fun _uint32 _int _int _int
                                       _uint32 _uint32 _uint32 _uint32
                                       -> _SDL_Surface-pointer)
  #:wrap (allocator SDL_FreeSurface))

;extern DECLSPEC SDL_Surface *SDLCALL SDL_CreateRGBSurfaceFrom(void *pixels, int width,int height,int depth,int pitch,Uint32 Rmask,Uint32 Gmask,Uint32 Bmask,Uint32 Amask);
(define-sdl SDL_CreateRGBSurfaceFrom (_fun _pointer _int _int _int _int
                                           _uint32 _uint32 _uint32 _uint32
                                           -> _SDL_Surface-pointer)
  #:wrap (allocator SDL_FreeSurface))

;extern DECLSPEC int SDLCALL SDL_SetSurfacePalette(SDL_Surface * surface, SDL_Palette * palette);
(define-sdl SDL_SetSurfacePalette (_fun _SDL_Surface-pointer _SDL_Palette-pointer -> _int))

(define (sdl-must-lock-surface? s)
  (not (zero? (bitwise-and (SDL_Surface-flags s) #x02))))

;extern DECLSPEC int SDLCALL SDL_LockSurface(SDL_Surface * surface);
(define-sdl SDL_LockSurface (_fun _SDL_Surface-pointer -> _int))

;extern DECLSPEC void SDLCALL SDL_UnlockSurface(SDL_Surface * surface);
(define-sdl SDL_UnlockSurface (_fun _SDL_Surface-pointer -> _void))

;extern DECLSPEC SDL_Surface *SDLCALL SDL_LoadBMP_RW(SDL_RWops * src, int freesrc);
(define-sdl SDL_LoadBMP_RW (_fun _pointer _int -> _SDL_Surface-pointer)
  #:wrap (allocator SDL_FreeSurface))

;extern DECLSPEC int SDLCALL SDL_SaveBMP_RW (SDL_Surface * surface, SDL_RWops * dst, int freedst);
(define-sdl SDL_SaveBMP_RW (_fun _SDL_Surface-pointer _pointer _int -> _int))
;#define SDL_SaveBMP(surface, file) SDL_SaveBMP_RW(surface, SDL_RWFromFile(file, "wb"), 1)
#;(define (SDL_SaveBMP surface file) (SDL_SaveBMP_RW surface (SDL_RWFromFile file "wb") 1))
;extern DECLSPEC int SDLCALL SDL_SetSurfaceRLE(SDL_Surface * surface, int flag);
(define-sdl SDL_SetSurfaceRLE (_fun _SDL_Surface-pointer _int -> _int))
;extern DECLSPEC int SDLCALL SDL_SetColorKey(SDL_Surface * surface,int flag, Uint32 key);
(define-sdl SDL_SetColorKey (_fun _SDL_Surface-pointer _int _uint32 -> _int))
;extern DECLSPEC int SDLCALL SDL_GetColorKey(SDL_Surface * surface,Uint32 * key);
(define-sdl SDL_GetColorKey (_fun _SDL_Surface-pointer _uint32* -> _int))
;extern DECLSPEC int SDLCALL SDL_SetSurfaceColorMod(SDL_Surface * surface, Uint8 r, Uint8 g, Uint8 b);
(define-sdl SDL_SetSurfaceColorMod (_fun _SDL_Surface-pointer _uint8 _uint8 _uint8 -> _int))
;extern DECLSPEC int SDLCALL SDL_GetSurfaceColorMod(SDL_Surface * surface, Uint8 * r, Uint8 * g, Uint8 * b);
(define-sdl SDL_GetSurfaceColorMod (_fun _SDL_Surface-pointer _uint8* _uint8* _uint8* -> _int))
;extern DECLSPEC int SDLCALL SDL_SetSurfaceAlphaMod(SDL_Surface * surface, Uint8 alpha);
(define-sdl SDL_SetSurfaceAlphaMod (_fun _SDL_Surface-pointer _uint8 -> _int))
;extern DECLSPEC int SDLCALL SDL_GetSurfaceAlphaMod(SDL_Surface * surface, Uint8 * alpha);
(define-sdl SDL_GetSurfaceAlphaMod (_fun _SDL_Surface-pointer _uint8* -> _int))
;extern DECLSPEC int SDLCALL SDL_SetSurfaceBlendMode(SDL_Surface * surface, SDL_BlendMode blendMode);
(define-sdl SDL_SetSurfaceBlendMode (_fun _SDL_Surface-pointer _SDL_BlendMode -> _int))
;extern DECLSPEC int SDLCALL SDL_GetSurfaceBlendMode(SDL_Surface * surface, SDL_BlendMode *blendMode);
(define-sdl SDL_GetSurfaceBlendMode (_fun _SDL_Surface-pointer _pointer -> _int))
;extern DECLSPEC SDL_bool SDLCALL SDL_SetClipRect(SDL_Surface * surface, const SDL_Rect * rect);
(define-sdl SDL_SetClipRect (_fun _SDL_Surface-pointer _sdl-rect-pointer -> _bool))
;extern DECLSPEC void SDLCALL SDL_GetClipRect(SDL_Surface * surface, SDL_Rect * rect);
(define-sdl SDL_GetClipRect (_fun _SDL_Surface-pointer _sdl-rect-pointer -> _void))
;extern DECLSPEC SDL_Surface *SDLCALL SDL_ConvertSurface (SDL_Surface * src, SDL_PixelFormat * fmt, Uint32 flags);
(define-sdl SDL_ConvertSurface (_fun _SDL_Surface-pointer _SDL_PixelFormat-pointer _uint32 -> _SDL_Surface-pointer))
;extern DECLSPEC SDL_Surface *SDLCALL SDL_ConvertSurfaceFormat(SDL_Surface * src, Uint32 pixel_format, Uint32 flags);
(define-sdl SDL_ConvertSurfaceFormat (_fun _SDL_Surface-pointer _uint32 _uint32 -> _SDL_Surface-pointer))
;extern DECLSPEC int SDLCALL SDL_ConvertPixels(int width, int height, Uint32 src_format, const void * src, int src_pitch, Uint32 dst_format, void * dst, int dst_pitch);
(define-sdl SDL_ConvertPixels (_fun _int _int _uint32 _pointer _int _uint32 _pointer _int -> _int))
;extern DECLSPEC int SDLCALL SDL_FillRect (SDL_Surface * dst, const SDL_Rect * rect, Uint32 color);
(define-sdl SDL_FillRect (_fun _SDL_Surface-pointer _sdl-rect-pointer/null _uint32 -> _int))
;extern DECLSPEC int SDLCALL SDL_FillRects (SDL_Surface * dst, const SDL_Rect * rects, int count, Uint32 color);
(define-sdl SDL_FillRects (_fun _SDL_Surface-pointer _sdl-rect-pointer/null _int _uint32 -> _int))

;extern DECLSPEC int SDLCALL SDL_UpperBlit (SDL_Surface * src, const SDL_Rect * srcrect, SDL_Surface * dst, SDL_Rect * dstrect);
(define-sdl SDL_UpperBlit (_fun _SDL_Surface-pointer _sdl-rect-pointer/null
                                _SDL_Surface-pointer _sdl-rect-pointer/null
                                -> _int))

;#define SDL_BlitSurface SDL_UpperBlit
(define SDL_BlitSurface SDL_UpperBlit)

;extern DECLSPEC int SDLCALL SDL_LowerBlit (SDL_Surface * src, SDL_Rect * srcrect, SDL_Surface * dst, SDL_Rect * dstrect);
(define-sdl SDL_LowerBlit (_fun _SDL_Surface-pointer _sdl-rect-pointer/null
                                _SDL_Surface-pointer _sdl-rect-pointer/null
                                -> _int))

;extern DECLSPEC int SDLCALL SDL_UpperBlitScaled (SDL_Surface * src, const SDL_Rect * srcrect, SDL_Surface * dst, SDL_Rect * dstrect);
(define-sdl SDL_UpperBlitScaled (_fun _SDL_Surface-pointer _sdl-rect-pointer/null
                                      _SDL_Surface-pointer _sdl-rect-pointer/null
                                      -> _int))

;#define SDL_BlitScaled SDL_UpperBlitScaled
(define SDL_BlitScaled SDL_UpperBlitScaled)
;extern DECLSPEC int SDLCALL SDL_LowerBlitScaled (SDL_Surface * src, SDL_Rect * srcrect, SDL_Surface * dst, SDL_Rect * dstrect);
(define-sdl SDL_LowerBlitScaled (_fun _SDL_Surface-pointer _sdl-rect-pointer
                                      _SDL_Surface-pointer _sdl-rect-pointer
                                      -> _int))


;;
;; --- OpenGL interop ----------------------------
;;

(define _SDL_GLattr
  (_enum
  '(SDL_GL_RED_SIZE
    SDL_GL_GREEN_SIZE
    SDL_GL_BLUE_SIZE
    SDL_GL_ALPHA_SIZE
    SDL_GL_BUFFER_SIZE
    SDL_GL_DOUBLEBUFFER
    SDL_GL_DEPTH_SIZE
    SDL_GL_STENCIL_SIZE
    SDL_GL_ACCUM_RED_SIZE
    SDL_GL_ACCUM_GREEN_SIZE
    SDL_GL_ACCUM_BLUE_SIZE
    SDL_GL_ACCUM_ALPHA_SIZE
    SDL_GL_STEREO
    SDL_GL_MULTISAMPLEBUFFERS
    SDL_GL_MULTISAMPLESAMPLES
    SDL_GL_ACCELERATED_VISUAL
    SDL_GL_RETAINED_BACKING
    SDL_GL_CONTEXT_MAJOR_VERSION
    SDL_GL_CONTEXT_MINOR_VERSION
    SDL_GL_CONTEXT_EGL
    SDL_GL_CONTEXT_FLAGS
    SDL_GL_CONTEXT_PROFILE_MASK
    SDL_GL_SHARE_WITH_CURRENT_CONTEXT)))

(define _SDL_GLprofile
  (_enum
   '(SDL_GL_CONTEXT_PROFILE_CORE = #x0001
     SDL_GL_CONTEXT_PROFILE_COMPATIBILITY = #x0002
     SDL_GL_CONTEXT_PROFILE_ES = #x0004)))

(define _SDL_GLcontextFlag
  (_enum
   '(SDL_GL_CONTEXT_DEBUG_FLAG = #x0001
    SDL_GL_CONTEXT_FORWARD_COMPATIBLE_FLAG = #x0002
    SDL_GL_CONTEXT_ROBUST_ACCESS_FLAG = #x0004
    SDL_GL_CONTEXT_RESET_ISOLATION_FLAG = #x0008)))

;extern DECLSPEC int SDLCALL SDL_GL_LoadLibrary(const char *path);
(define-sdl SDL_GL_LoadLibrary (_fun _string -> _int))
;extern DECLSPEC void *SDLCALL SDL_GL_GetProcAddress(const char *proc);
(define-sdl SDL_GL_GetProcAddress (_fun _string -> _pointer))
;extern DECLSPEC void SDLCALL SDL_GL_UnloadLibrary(void);
(define-sdl SDL_GL_UnloadLibrary (_fun -> _void))
;extern DECLSPEC SDL_bool SDLCALL SDL_GL_ExtensionSupported(const char *extension);
(define-sdl SDL_GL_ExtensionSupported (_fun _string -> _bool))
;extern DECLSPEC int SDLCALL SDL_GL_SetAttribute(SDL_GLattr attr, int value);
(define-sdl SDL_GL_SetAttribute (_fun _SDL_GLattr _int -> _int))
;extern DECLSPEC int SDLCALL SDL_GL_GetAttribute(SDL_GLattr attr, int *value);
(define-sdl SDL_GL_GetAttribute (_fun _SDL_GLattr _int* -> _int))
;extern DECLSPEC SDL_GLContext SDLCALL SDL_GL_CreateContext(SDL_Window * window);
(define-sdl SDL_GL_CreateContext (_fun _SDL_Window* -> _SDL_GLContext*))
;extern DECLSPEC int SDLCALL SDL_GL_MakeCurrent(SDL_Window * window, SDL_GLContext context);
(define-sdl SDL_GL_MakeCurrent (_fun _SDL_Window* _SDL_GLContext* -> _int))
;extern DECLSPEC int SDLCALL SDL_GL_SetSwapInterval(int interval);
(define-sdl SDL_GL_SetSwapInterval (_fun _int -> _int))
;extern DECLSPEC int SDLCALL SDL_GL_GetSwapInterval(void);
(define-sdl SDL_GL_GetSwapInterval (_fun -> _int))
;extern DECLSPEC void SDLCALL SDL_GL_SwapWindow(SDL_Window * window);
(define-sdl SDL_GL_SwapWindow (_fun _SDL_Window* -> _void))
;extern DECLSPEC void SDLCALL SDL_GL_DeleteContext(SDL_GLContext context);
(define-sdl SDL_GL_DeleteContext (_fun _SDL_GLContext* -> _void))
