{.compile: "Arduboy2/Arduboy2.cpp".}
{.compile: "Arduboy2/Arduboy2Audio.cpp".}
## *
##  @file Arduboy2.h
##  \brief
##  The Arduboy2Base and Arduboy2 classes and support objects and definitions.
##

#import
#  Arduboy2Core, Arduboy2Beep, Sprites, SpritesB

## * \brief
##  Library version
##
##  \details
##  For a version number in the form of x.y.z the value of the define will be
##  ((x * 10000) + (y * 100) + (z)) as a decimal number.
##  So, it will read as xxxyyzz, with no leading zeros on x.
##
##  A user program can test this value to conditionally compile based on the
##  library version. For example:
##
##  \code{.cpp}
##  // If the library is version 2.1.0 or higher
##  #if ARDUBOY_LIB_VER >= 20100
##    // ... code that make use of a new feature added to V2.1.0
##  #endif
##  \endcode
##

template BV(x: untyped): untyped = 1 shl x

const
  ARDUBOY_LIB_VER* = 50201

##  EEPROM settings

const
  ARDUBOY_UNIT_NAME_LEN* = 6
  EEPROM_VERSION* = 0
  EEPROM_SYS_FLAGS* = 1
  EEPROM_AUDIO_ON_OFF* = 2
  EEPROM_UNIT_ID* = 8
  EEPROM_UNIT_NAME* = 10

##  EEPROM_SYS_FLAGS values

const
  SYS_FLAG_UNAME* = 0
  SYS_FLAG_UNAME_MASK* = BV(SYS_FLAG_UNAME)
  SYS_FLAG_SHOW_LOGO* = 1
  SYS_FLAG_SHOW_LOGO_MASK* = BV(SYS_FLAG_SHOW_LOGO)
  SYS_FLAG_SHOW_LOGO_LEDS* = 2
  SYS_FLAG_SHOW_LOGO_LEDS_MASK* = BV(SYS_FLAG_SHOW_LOGO_LEDS)

## * \brief
##  Start of EEPROM storage space for sketches.
##
##  \details
##  An area at the start of EEPROM is reserved for system use.
##  This define specifies the first EEPROM location past the system area.
##  Sketches can use locations from here to the end of EEPROM space.
##

const
  EEPROM_STORAGE_SPACE_START* = 16

##  eeprom settings above are neded for audio

import
  Arduboy2Audio

##  If defined, it is safe to draw outside of the screen boundaries.
##  Pixels that would exceed the display limits will be ignored.

const
  PIXEL_SAFE_MODE* = true

##  pixel colors

const
  BLACK* = 0
  WHITE* = 1

## * \brief
##  Color value to indicate pixels are to be inverted.
##
##  \details
##  BLACK pixels will become WHITE and WHITE will become BLACK.
##
##  \note
##  Only function Arduboy2Base::drawBitmap() currently supports this value.
##

const
  INVERT* = 2
  CLEAR_BUFFER* = true

## =============================================
## ========== Rect (rectangle) object ==========
## =============================================
## * \brief
##  A rectangle object for collision functions.
##
##  \details
##  The X and Y coordinates specify the top left corner of a rectangle with the
##  given width and height.
##
##  \see Arduboy2Base::collide(Point, Rect) Arduboy2Base::collide(Rect, Rect)
##       Point
##

type
  Rect* {.importcpp: "Rect", header: "Arduboy2.h", bycopy.} = object
    x* {.importc: "x".}: int16 ## *< The X coordinate of the top left corner
    y* {.importc: "y".}: int16 ## *< The Y coordinate of the top left corner
    width* {.importc: "width".}: uint8 ## *< The width of the rectangle
    height* {.importc: "height".}: uint8 ## *< The height of the rectangle
                                       ## * \brief
                                       ##  The default constructor
                                       ##


proc constructRect*(): Rect {.constructor, importcpp: "Rect(@)", header: "Arduboy2.h".}
proc constructRect*(x: int16; y: int16; width: uint8; height: uint8): Rect {.
    constructor, importcpp: "Rect(@)", header: "Arduboy2.h".}
## ==================================
## ========== Point object ==========
## ==================================
## * \brief
##  An object to define a single point for collision functions.
##
##  \details
##  The location of the point is given by X and Y coordinates.
##
##  \see Arduboy2Base::collide(Point, Rect) Rect
##

type
  Point* {.importcpp: "Point", header: "Arduboy2.h", bycopy.} = object
    x* {.importc: "x".}: int16 ## *< The X coordinate of the point
    y* {.importc: "y".}: int16 ## *< The Y coordinate of the point
                             ## * \brief
                             ##  The default constructor
                             ##


proc constructPoint*(): Point {.constructor, importcpp: "Point(@)",
                             header: "Arduboy2.h".}
proc constructPoint*(x: int16; y: int16): Point {.constructor,
    importcpp: "Point(@)", header: "Arduboy2.h".}
## ==================================
## ========== Arduboy2Base ==========
## ==================================
## * \brief
##  The main functions provided for writing sketches for the Arduboy,
##  _minus_ text output.
##
##  \details
##  This class in inherited by Arduboy2, so if text output functions are
##  required Arduboy2 should be used instead.
##
##  \note
##  \parblock
##  An Arduboy2Audio class object named `audio` will be created by the
##  Arduboy2Base class, so there is no need for a sketch itself to create an
##  Arduboy2Audio object. Arduboy2Audio functions can be called using the
##  Arduboy2 or Arduboy2Base `audio` object.
##
##  Example:
##
##  \code{.cpp}
##  #include <Arduboy2.h>
##
##  Arduboy2 arduboy;
##
##  // Arduboy2Audio functions can be called as follows:
##    arduboy.audio.on();
##    arduboy.audio.off();
##  \endcode
##  \endparblock
##
##  \note
##  \parblock
##  A friend class named _Arduboy2Ex_ is declared by this class. The intention
##  is to allow a sketch to create an _Arduboy2Ex_ class which would have access
##  to the private and protected members of the Arduboy2Base class. It is hoped
##  that this may eliminate the need to create an entire local copy of the
##  library, in order to extend the functionality, in most circumstances.
##  \endparblock
##
##  \see Arduboy2
##

type
  Arduboy2Base* {.importcpp: "Arduboy2Base", header: "Arduboy2.h", bycopy.} = object ##  helper function for sound enable/disable system control
    audio* {.importc: "audio".}: Arduboy2Audio ## * \brief
                                           ##  Initialize the hardware, display the boot logo, provide boot utilities, etc.
                                           ##
                                           ##  \details
                                           ##  This function should be called once near the start of the sketch,
                                           ##  usually in `setup()`, before using any other functions in this class.
                                           ##  It initializes the display, displays the boot logo, provides "flashlight"
                                           ##  and system control features and initializes audio control.
                                           ##
                                           ##  \note
                                           ##  To free up some code space for use by the sketch, `boot()` can be used
                                           ##  instead of `begin()` to allow the elimination of some of the things that
                                           ##  aren't really required, such as displaying the boot logo.
                                           ##
                                           ##  \see boot()
                                           ##
    frameCount* {.importc: "frameCount".}: uint16 ## * \brief
                                                ##  The display buffer array in RAM.
                                                ##
                                                ##  \details
                                                ##  The display buffer (also known as the screen buffer) contains an
                                                ##  image bitmap of the desired contents of the display, which is written
                                                ##  to the display using the `display()` function. The drawing functions of
                                                ##  this library manipulate the contents of the display buffer. A sketch can
                                                ##  also access the display buffer directly.
                                                ##
                                                ##  \see getBuffer()
                                                ##
  FlashStringHelper* {.importc: "const __FlashStringHelper".} = object
    ##  For frame funcions


proc constructArduboy2Base*(): Arduboy2Base {.constructor,
    importcpp: "Arduboy2Base(@)", header: "Arduboy2.h".}
proc begin*(this: var Arduboy2Base) {.importcpp: "begin", header: "Arduboy2.h".}
proc flashlight*(this: var Arduboy2Base) {.importcpp: "flashlight",
                                       header: "Arduboy2.h".}
proc systemButtons*(this: var Arduboy2Base) {.importcpp: "systemButtons",
    header: "Arduboy2.h".}
proc bootLogo*(this: var Arduboy2Base) {.importcpp: "bootLogo", header: "Arduboy2.h".}
proc bootLogoCompressed*(this: var Arduboy2Base) {.importcpp: "bootLogoCompressed",
    header: "Arduboy2.h".}
proc bootLogoSpritesSelfMasked*(this: var Arduboy2Base) {.
    importcpp: "bootLogoSpritesSelfMasked", header: "Arduboy2.h".}
proc bootLogoSpritesOverwrite*(this: var Arduboy2Base) {.
    importcpp: "bootLogoSpritesOverwrite", header: "Arduboy2.h".}
proc bootLogoSpritesBSelfMasked*(this: var Arduboy2Base) {.
    importcpp: "bootLogoSpritesBSelfMasked", header: "Arduboy2.h".}
proc bootLogoSpritesBOverwrite*(this: var Arduboy2Base) {.
    importcpp: "bootLogoSpritesBOverwrite", header: "Arduboy2.h".}
proc bootLogoShell*(this: var Arduboy2Base; drawLogo: proc (a1: int16)) {.
    importcpp: "bootLogoShell", header: "Arduboy2.h".}
proc bootLogoExtra*(this: var Arduboy2Base) {.importcpp: "bootLogoExtra",
    header: "Arduboy2.h".}
proc waitNoButtons*(this: var Arduboy2Base) {.importcpp: "waitNoButtons",
    header: "Arduboy2.h".}
proc clear*(this: var Arduboy2Base) {.importcpp: "clear", header: "Arduboy2.h".}
proc display*(this: var Arduboy2Base) {.importcpp: "display", header: "Arduboy2.h".}
proc display*(this: var Arduboy2Base; clear: bool) {.importcpp: "display",
    header: "Arduboy2.h".}
#proc drawPixel*(x: int16; y: int16; color: uint8 = WHITE) {.
#    importcpp: "Arduboy2Base::drawPixel(@)", header: "Arduboy2.h".}
proc getPixel*(this: var Arduboy2Base; x: uint8; y: uint8): uint8 {.
    importcpp: "getPixel", header: "Arduboy2.h".}
proc drawCircle*(this: var Arduboy2Base; x0: int16; y0: int16; r: uint8;
                color: uint8 = WHITE) {.importcpp: "drawCircle",
                                      header: "Arduboy2.h".}
proc drawCircleHelper*(this: var Arduboy2Base; x0: int16; y0: int16; r: uint8;
                      corners: uint8; color: uint8 = WHITE) {.
    importcpp: "drawCircleHelper", header: "Arduboy2.h".}
proc fillCircle*(this: var Arduboy2Base; x0: int16; y0: int16; r: uint8;
                color: uint8 = WHITE) {.importcpp: "fillCircle",
                                      header: "Arduboy2.h".}
proc fillCircleHelper*(this: var Arduboy2Base; x0: int16; y0: int16; r: uint8;
                      sides: uint8; delta: int16; color: uint8 = WHITE) {.
    importcpp: "fillCircleHelper", header: "Arduboy2.h".}
proc drawLine*(this: var Arduboy2Base; x0: int16; y0: int16; x1: int16; y1: int16;
              color: uint8 = WHITE) {.importcpp: "drawLine", header: "Arduboy2.h".}
proc drawRect*(this: var Arduboy2Base; x: int16; y: int16; w: uint8; h: uint8;
              color: uint8 = WHITE) {.importcpp: "drawRect", header: "Arduboy2.h".}
proc drawFastVLine*(this: var Arduboy2Base; x: int16; y: int16; h: uint8;
                   color: uint8 = WHITE) {.importcpp: "drawFastVLine",
    header: "Arduboy2.h".}
proc drawFastHLine*(this: var Arduboy2Base; x: int16; y: int16; w: uint8;
                   color: uint8 = WHITE) {.importcpp: "drawFastHLine",
    header: "Arduboy2.h".}
proc fillRect*(this: var Arduboy2Base; x: int16; y: int16; w: uint8; h: uint8;
              color: uint8 = WHITE) {.importcpp: "fillRect", header: "Arduboy2.h".}
proc fillScreen*(this: var Arduboy2Base; color: uint8 = WHITE) {.
    importcpp: "fillScreen", header: "Arduboy2.h".}
proc drawRoundRect*(this: var Arduboy2Base; x: int16; y: int16; w: uint8;
                   h: uint8; r: uint8; color: uint8 = WHITE) {.
    importcpp: "drawRoundRect", header: "Arduboy2.h".}
proc fillRoundRect*(this: var Arduboy2Base; x: int16; y: int16; w: uint8;
                   h: uint8; r: uint8; color: uint8 = WHITE) {.
    importcpp: "fillRoundRect", header: "Arduboy2.h".}
proc drawTriangle*(this: var Arduboy2Base; x0: int16; y0: int16; x1: int16;
                  y1: int16; x2: int16; y2: int16; color: uint8 = WHITE) {.
    importcpp: "drawTriangle", header: "Arduboy2.h".}
proc fillTriangle*(this: var Arduboy2Base; x0: int16; y0: int16; x1: int16;
                  y1: int16; x2: int16; y2: int16; color: uint8 = WHITE) {.
    importcpp: "fillTriangle", header: "Arduboy2.h".}
proc drawBitmap*(x: int16; y: int16; bitmap: ptr uint8; w: uint8; h: uint8;
                color: uint8 = WHITE) {.importcpp: "Arduboy2Base::drawBitmap(@)",
                                      header: "Arduboy2.h".}
proc drawSlowXYBitmap*(this: var Arduboy2Base; x: int16; y: int16;
                      bitmap: ptr uint8; w: uint8; h: uint8;
                      color: uint8 = WHITE) {.importcpp: "drawSlowXYBitmap",
    header: "Arduboy2.h".}
proc drawCompressed*(sx: int16; sy: int16; bitmap: ptr uint8;
                    color: uint8 = WHITE) {.
    importcpp: "Arduboy2Base::drawCompressed(@)", header: "Arduboy2.h".}
proc getBuffer*(this: var Arduboy2Base): ptr uint8 {.importcpp: "getBuffer",
    header: "Arduboy2.h".}
proc generateRandomSeed*(this: var Arduboy2Base): culong {.
    importcpp: "generateRandomSeed", header: "Arduboy2.h".}
proc initRandomSeed*(this: var Arduboy2Base) {.importcpp: "initRandomSeed",
    header: "Arduboy2.h".}
proc swap*(this: var Arduboy2Base; a: var int16; b: var int16) {.importcpp: "swap",
    header: "Arduboy2.h".}
proc setFrameRate*(this: var Arduboy2Base; rate: uint8) {.importcpp: "setFrameRate",
    header: "Arduboy2.h".}
proc setFrameDuration*(this: var Arduboy2Base; duration: uint8) {.
    importcpp: "setFrameDuration", header: "Arduboy2.h".}
proc nextFrame*(this: var Arduboy2Base): bool {.importcpp: "nextFrame",
    header: "Arduboy2.h".}
proc nextFrameDEV*(this: var Arduboy2Base): bool {.importcpp: "nextFrameDEV",
    header: "Arduboy2.h".}
proc everyXFrames*(this: var Arduboy2Base; frames: uint8): bool {.
    importcpp: "everyXFrames", header: "Arduboy2.h".}
proc cpuLoad*(this: var Arduboy2Base): cint {.importcpp: "cpuLoad",
    header: "Arduboy2.h".}
proc pressed*(this: var Arduboy2Base; buttons: uint8): bool {.importcpp: "pressed",
    header: "Arduboy2.h".}
proc notPressed*(this: var Arduboy2Base; buttons: uint8): bool {.
    importcpp: "notPressed", header: "Arduboy2.h".}
proc pollButtons*(this: var Arduboy2Base) {.importcpp: "pollButtons",
                                        header: "Arduboy2.h".}
proc justPressed*(this: var Arduboy2Base; button: uint8): bool {.
    importcpp: "justPressed", header: "Arduboy2.h".}
proc justReleased*(this: var Arduboy2Base; button: uint8): bool {.
    importcpp: "justReleased", header: "Arduboy2.h".}
proc collide*(point: Point; rect: Rect): bool {.importcpp: "Arduboy2Base::collide(@)",
    header: "Arduboy2.h".}
proc collide*(rect1: Rect; rect2: Rect): bool {.importcpp: "Arduboy2Base::collide(@)",
    header: "Arduboy2.h".}
proc readUnitID*(this: var Arduboy2Base): uint16 {.importcpp: "readUnitID",
    header: "Arduboy2.h".}
proc writeUnitID*(this: var Arduboy2Base; id: uint16) {.importcpp: "writeUnitID",
    header: "Arduboy2.h".}
proc readUnitName*(this: var Arduboy2Base; name: cstring): uint8 {.
    importcpp: "readUnitName", header: "Arduboy2.h".}
proc writeUnitName*(this: var Arduboy2Base; name: cstring) {.
    importcpp: "writeUnitName", header: "Arduboy2.h".}
proc readShowBootLogoFlag*(this: var Arduboy2Base): bool {.
    importcpp: "readShowBootLogoFlag", header: "Arduboy2.h".}
proc writeShowBootLogoFlag*(this: var Arduboy2Base; val: bool) {.
    importcpp: "writeShowBootLogoFlag", header: "Arduboy2.h".}
proc readShowUnitNameFlag*(this: var Arduboy2Base): bool {.
    importcpp: "readShowUnitNameFlag", header: "Arduboy2.h".}
proc writeShowUnitNameFlag*(this: var Arduboy2Base; val: bool) {.
    importcpp: "writeShowUnitNameFlag", header: "Arduboy2.h".}
proc readShowBootLogoLEDsFlag*(this: var Arduboy2Base): bool {.
    importcpp: "readShowBootLogoLEDsFlag", header: "Arduboy2.h".}
proc writeShowBootLogoLEDsFlag*(this: var Arduboy2Base; val: bool) {.
    importcpp: "writeShowBootLogoLEDsFlag", header: "Arduboy2.h".}
## ==============================
## ========== Arduboy2 ==========
## ==============================
## * \brief
##  The main functions provided for writing sketches for the Arduboy,
##  _including_ text output.
##
##  \details
##  This class is derived from Arduboy2Base. It provides text output functions
##  in addition to all the functions inherited from Arduboy2Base.
##
##  \note
##  A friend class named _Arduboy2Ex_ is declared by this class. The intention
##  is to allow a sketch to create an _Arduboy2Ex_ class which would have access
##  to the private and protected members of the Arduboy2 class. It is hoped
##  that this may eliminate the need to create an entire local copy of the
##  library, in order to extend the functionality, in most circumstances.
##
##  \see Arduboy2Base
##

type
  Arduboy2* {.importcpp: "Arduboy2", header: "Arduboy2.h", bycopy.} = object


proc constructArduboy2*(): Arduboy2 {.constructor, importcpp: "Arduboy2(@)",
                                   header: "Arduboy2.h".}
proc bootLogoText*(this: var Arduboy2) {.importcpp: "bootLogoText",
                                     header: "Arduboy2.h".}
proc bootLogoExtra*(this: var Arduboy2) {.importcpp: "bootLogoExtra",
                                      header: "Arduboy2.h".}
proc write*(this: var Arduboy2; a2: uint8): csize {.importcpp: "write",
    header: "Arduboy2.h".}
proc drawChar*(this: var Arduboy2; x: int16; y: int16; c: cuchar; color: uint8;
              bg: uint8; size: uint8) {.importcpp: "drawChar",
                                        header: "Arduboy2.h".}
proc setCursor*(this: var Arduboy2; x: int16; y: int16) {.importcpp: "setCursor",
    header: "Arduboy2.h".}
proc getCursorX*(this: var Arduboy2): int16 {.importcpp: "getCursorX",
    header: "Arduboy2.h".}
proc getCursorY*(this: var Arduboy2): int16 {.importcpp: "getCursorY",
    header: "Arduboy2.h".}
proc setTextColor*(this: var Arduboy2; color: uint8) {.importcpp: "setTextColor",
    header: "Arduboy2.h".}
proc getTextColor*(this: var Arduboy2): uint8 {.importcpp: "getTextColor",
    header: "Arduboy2.h".}
proc setTextBackground*(this: var Arduboy2; bg: uint8) {.
    importcpp: "setTextBackground", header: "Arduboy2.h".}
proc getTextBackground*(this: var Arduboy2): uint8 {.
    importcpp: "getTextBackground", header: "Arduboy2.h".}
proc setTextSize*(this: var Arduboy2; s: uint8) {.importcpp: "setTextSize",
    header: "Arduboy2.h".}
proc getTextSize*(this: var Arduboy2): uint8 {.importcpp: "getTextSize",
    header: "Arduboy2.h".}
proc setTextWrap*(this: var Arduboy2; w: bool) {.importcpp: "setTextWrap",
    header: "Arduboy2.h".}
proc getTextWrap*(this: var Arduboy2): bool {.importcpp: "getTextWrap",
    header: "Arduboy2.h".}
proc clear*(this: var Arduboy2) {.importcpp: "clear", header: "Arduboy2.h".}
proc begin*(this: var Arduboy2) {.importcpp: "begin", header: "Arduboy2.h".}
proc flashlight*(this: var Arduboy2) {.importcpp: "flashlight",
                                       header: "Arduboy2.h".}
proc systemButtons*(this: var Arduboy2) {.importcpp: "systemButtons",
    header: "Arduboy2.h".}
proc bootLogo*(this: var Arduboy2) {.importcpp: "bootLogo", header: "Arduboy2.h".}
proc bootLogoCompressed*(this: var Arduboy2) {.importcpp: "bootLogoCompressed",
    header: "Arduboy2.h".}
proc bootLogoSpritesSelfMasked*(this: var Arduboy2) {.
    importcpp: "bootLogoSpritesSelfMasked", header: "Arduboy2.h".}
proc bootLogoSpritesOverwrite*(this: var Arduboy2) {.
    importcpp: "bootLogoSpritesOverwrite", header: "Arduboy2.h".}
proc bootLogoSpritesBSelfMasked*(this: var Arduboy2) {.
    importcpp: "bootLogoSpritesBSelfMasked", header: "Arduboy2.h".}
proc bootLogoSpritesBOverwrite*(this: var Arduboy2) {.
    importcpp: "bootLogoSpritesBOverwrite", header: "Arduboy2.h".}
proc bootLogoShell*(this: var Arduboy2; drawLogo: proc (a1: int16)) {.
    importcpp: "bootLogoShell", header: "Arduboy2.h".}
proc waitNoButtons*(this: var Arduboy2) {.importcpp: "waitNoButtons",
    header: "Arduboy2.h".}
proc display*(this: var Arduboy2) {.importcpp: "display", header: "Arduboy2.h".}
proc display*(this: var Arduboy2; clear: bool) {.importcpp: "display",
    header: "Arduboy2.h".}
proc getPixel*(this: var Arduboy2; x: uint8; y: uint8): uint8 {.
    importcpp: "getPixel", header: "Arduboy2.h".}
proc drawCircle*(this: var Arduboy2; x0: int16; y0: int16; r: uint8;
                color: uint8 = WHITE) {.importcpp: "drawCircle",
                                      header: "Arduboy2.h".}
proc drawCircleHelper*(this: var Arduboy2; x0: int16; y0: int16; r: uint8;
                      corners: uint8; color: uint8 = WHITE) {.
    importcpp: "drawCircleHelper", header: "Arduboy2.h".}
proc fillCircle*(this: var Arduboy2; x0: int16; y0: int16; r: uint8;
                color: uint8 = WHITE) {.importcpp: "fillCircle",
                                      header: "Arduboy2.h".}
proc fillCircleHelper*(this: var Arduboy2; x0: int16; y0: int16; r: uint8;
                      sides: uint8; delta: int16; color: uint8 = WHITE) {.
    importcpp: "fillCircleHelper", header: "Arduboy2.h".}
proc drawLine*(this: var Arduboy2; x0: int16; y0: int16; x1: int16; y1: int16;
              color: uint8 = WHITE) {.importcpp: "drawLine", header: "Arduboy2.h".}
proc drawRect*(this: var Arduboy2; x: int16; y: int16; w: uint8; h: uint8;
              color: uint8 = WHITE) {.importcpp: "drawRect", header: "Arduboy2.h".}
proc drawFastVLine*(this: var Arduboy2; x: int16; y: int16; h: uint8;
                   color: uint8 = WHITE) {.importcpp: "drawFastVLine",
    header: "Arduboy2.h".}
proc drawFastHLine*(this: var Arduboy2; x: int16; y: int16; w: uint8;
                   color: uint8 = WHITE) {.importcpp: "drawFastHLine",
    header: "Arduboy2.h".}
proc fillRect*(this: var Arduboy2; x: int16; y: int16; w: uint8; h: uint8;
              color: uint8 = WHITE) {.importcpp: "fillRect", header: "Arduboy2.h".}
proc fillScreen*(this: var Arduboy2; color: uint8 = WHITE) {.
    importcpp: "fillScreen", header: "Arduboy2.h".}
proc drawRoundRect*(this: var Arduboy2; x: int16; y: int16; w: uint8;
                   h: uint8; r: uint8; color: uint8 = WHITE) {.
    importcpp: "drawRoundRect", header: "Arduboy2.h".}
proc fillRoundRect*(this: var Arduboy2; x: int16; y: int16; w: uint8;
                   h: uint8; r: uint8; color: uint8 = WHITE) {.
    importcpp: "fillRoundRect", header: "Arduboy2.h".}
proc drawTriangle*(this: var Arduboy2; x0: int16; y0: int16; x1: int16;
                  y1: int16; x2: int16; y2: int16; color: uint8 = WHITE) {.
    importcpp: "drawTriangle", header: "Arduboy2.h".}
proc fillTriangle*(this: var Arduboy2; x0: int16; y0: int16; x1: int16;
                  y1: int16; x2: int16; y2: int16; color: uint8 = WHITE) {.
    importcpp: "fillTriangle", header: "Arduboy2.h".}
proc drawSlowXYBitmap*(this: var Arduboy2; x: int16; y: int16;
                      bitmap: ptr uint8; w: uint8; h: uint8;
                      color: uint8 = WHITE) {.importcpp: "drawSlowXYBitmap",
    header: "Arduboy2.h".}
proc getBuffer*(this: var Arduboy2): ptr uint8 {.importcpp: "getBuffer",
    header: "Arduboy2.h".}
proc generateRandomSeed*(this: var Arduboy2): culong {.
    importcpp: "generateRandomSeed", header: "Arduboy2.h".}
proc initRandomSeed*(this: var Arduboy2) {.importcpp: "initRandomSeed",
    header: "Arduboy2.h".}
proc swap*(this: var Arduboy2; a: var int16; b: var int16) {.importcpp: "swap",
    header: "Arduboy2.h".}
proc setFrameRate*(this: var Arduboy2; rate: uint8) {.importcpp: "setFrameRate",
    header: "Arduboy2.h".}
proc setFrameDuration*(this: var Arduboy2; duration: uint8) {.
    importcpp: "setFrameDuration", header: "Arduboy2.h".}
proc nextFrame*(this: var Arduboy2): bool {.importcpp: "nextFrame",
    header: "Arduboy2.h".}
proc nextFrameDEV*(this: var Arduboy2): bool {.importcpp: "nextFrameDEV",
    header: "Arduboy2.h".}
proc everyXFrames*(this: var Arduboy2; frames: uint8): bool {.
    importcpp: "everyXFrames", header: "Arduboy2.h".}
proc cpuLoad*(this: var Arduboy2): cint {.importcpp: "cpuLoad",
    header: "Arduboy2.h".}
proc pressed*(this: var Arduboy2; buttons: uint8): bool {.importcpp: "pressed",
    header: "Arduboy2.h".}
proc notPressed*(this: var Arduboy2; buttons: uint8): bool {.
    importcpp: "notPressed", header: "Arduboy2.h".}
proc pollButtons*(this: var Arduboy2) {.importcpp: "pollButtons",
                                        header: "Arduboy2.h".}
proc justPressed*(this: var Arduboy2; button: uint8): bool {.
    importcpp: "justPressed", header: "Arduboy2.h".}
proc justReleased*(this: var Arduboy2; button: uint8): bool {.
    importcpp: "justReleased", header: "Arduboy2.h".}
proc readUnitID*(this: var Arduboy2): uint16 {.importcpp: "readUnitID",
    header: "Arduboy2.h".}
proc writeUnitID*(this: var Arduboy2; id: uint16) {.importcpp: "writeUnitID",
    header: "Arduboy2.h".}
proc readUnitName*(this: var Arduboy2; name: cstring): uint8 {.
    importcpp: "readUnitName", header: "Arduboy2.h".}
proc writeUnitName*(this: var Arduboy2; name: cstring) {.
    importcpp: "writeUnitName", header: "Arduboy2.h".}
proc readShowBootLogoFlag*(this: var Arduboy2): bool {.
    importcpp: "readShowBootLogoFlag", header: "Arduboy2.h".}
proc writeShowBootLogoFlag*(this: var Arduboy2; val: bool) {.
    importcpp: "writeShowBootLogoFlag", header: "Arduboy2.h".}
proc readShowUnitNameFlag*(this: var Arduboy2): bool {.
    importcpp: "readShowUnitNameFlag", header: "Arduboy2.h".}
proc writeShowUnitNameFlag*(this: var Arduboy2; val: bool) {.
    importcpp: "writeShowUnitNameFlag", header: "Arduboy2.h".}
proc readShowBootLogoLEDsFlag*(this: var Arduboy2): bool {.
    importcpp: "readShowBootLogoLEDsFlag", header: "Arduboy2.h".}
proc writeShowBootLogoLEDsFlag*(this: var Arduboy2; val: bool) {.
    importcpp: "writeShowBootLogoLEDsFlag", header: "Arduboy2.h".}
proc idle*(this: var Arduboy2) {.importcpp: "idle", header: "Arduboy2.h".}
proc LCDDataMode*(this: var Arduboy2) {.importcpp: "LCDDataMode",
                                        header: "Arduboy2.h".}
proc LCDCommandMode*(this: var Arduboy2) {.importcpp: "LCDCommandMode",
    header: "Arduboy2.h".}
proc SPItransfer*(this: var Arduboy2; data: uint8) {.importcpp: "SPItransfer",
    header: "Arduboy2.h".}
proc displayOff*(this: var Arduboy2) {.importcpp: "displayOff",
                                       header: "Arduboy2.h".}
proc displayOn*(this: var Arduboy2) {.importcpp: "displayOn",
                                      header: "Arduboy2.h".}
proc width*(this: var Arduboy2): uint8 {.importcpp: "width",
    header: "Arduboy2.h".}
proc height*(this: var Arduboy2): uint8 {.importcpp: "height",
    header: "Arduboy2.h".}
proc buttonsState*(this: var Arduboy2): uint8 {.importcpp: "buttonsState",
    header: "Arduboy2.h".}
proc paint8Pixels*(this: var Arduboy2; pixels: uint8) {.
    importcpp: "paint8Pixels", header: "Arduboy2.h".}
proc paintScreen*(this: var Arduboy2; image: ptr uint8) {.
    importcpp: "paintScreen", header: "Arduboy2.h".}
proc paintScreen*(this: var Arduboy2; image: ptr uint8; clear: bool = false) {.
    importcpp: "paintScreen", header: "Arduboy2.h".}
proc blank*(this: var Arduboy2) {.importcpp: "blank", header: "Arduboy2.h".}
proc invert*(this: var Arduboy2; inverse: bool) {.importcpp: "invert",
    header: "Arduboy2.h".}
proc allPixelsOn*(this: var Arduboy2; on: bool) {.importcpp: "allPixelsOn",
    header: "Arduboy2.h".}
proc flipVertical*(this: var Arduboy2; flipped: bool) {.importcpp: "flipVertical",
    header: "Arduboy2.h".}
proc flipHorizontal*(this: var Arduboy2; flipped: bool) {.
    importcpp: "flipHorizontal", header: "Arduboy2.h".}
proc sendLCDCommand*(this: var Arduboy2; command: uint8) {.
    importcpp: "sendLCDCommand", header: "Arduboy2.h".}
proc setRGBled*(this: var Arduboy2; red: uint8; green: uint8; blue: uint8) {.
    importcpp: "setRGBled", header: "Arduboy2.h".}
proc setRGBled*(this: var Arduboy2; color: uint8; val: uint8) {.
    importcpp: "setRGBled", header: "Arduboy2.h".}
proc freeRGBled*(this: var Arduboy2) {.importcpp: "freeRGBled",
                                       header: "Arduboy2.h".}
proc digitalWriteRGB*(this: var Arduboy2; red: uint8; green: uint8;
                     blue: uint8) {.importcpp: "digitalWriteRGB",
                                    header: "Arduboy2.h".}
proc digitalWriteRGB*(this: var Arduboy2; color: uint8; val: uint8) {.
    importcpp: "digitalWriteRGB", header: "Arduboy2.h".}
proc boot*(this: var Arduboy2) {.importcpp: "boot", header: "Arduboy2.h".}
proc safeMode*(this: var Arduboy2) {.importcpp: "safeMode",
                                     header: "Arduboy2.h".}
proc delayShort*(this: var Arduboy2; ms: uint16) {.importcpp: "delayShort",
    header: "Arduboy2.h".}
proc exitToBootloader*(this: var Arduboy2) {.importcpp: "exitToBootloader",
    header: "Arduboy2.h".}
proc mainNoUSB*(this: var Arduboy2) {.importcpp: "mainNoUSB",
                                      header: "Arduboy2.h".}


# From Print.h
const
  DEC* = 10
  HEX* = 16
  OCT* = 8
  BIN* = 2

proc getWriteError*(this: var Arduboy2): cint {.importcpp: "getWriteError",
                                        header: "Print.h".}
proc clearWriteError*(this: var Arduboy2) {.importcpp: "clearWriteError",
                                     header: "Print.h".}
#proc write*(this: var Arduboy2; a2: uint8): csize {.importcpp: "write", header: "Print.h".}
proc write*(this: var Arduboy2; str: cstring): csize {.importcpp: "write", header: "Print.h".}
proc write*(this: var Arduboy2; buffer: ptr uint8; size: csize): csize {.
    importcpp: "write", header: "Print.h".}
proc write*(this: var Arduboy2; buffer: cstring; size: csize): csize {.importcpp: "write",
    header: "Print.h".}
proc write*(this: var Arduboy2; t: cshort): csize {.importcpp: "write", header: "Print.h".}
proc write*(this: var Arduboy2; t: cushort): csize {.importcpp: "write", header: "Print.h".}
proc write*(this: var Arduboy2; t: cint): csize {.importcpp: "write", header: "Print.h".}
proc write*(this: var Arduboy2; t: cuint): csize {.importcpp: "write", header: "Print.h".}
proc write*(this: var Arduboy2; t: clong): csize {.importcpp: "write", header: "Print.h".}
proc write*(this: var Arduboy2; t: culong): csize {.importcpp: "write", header: "Print.h".}
proc write*(this: var Arduboy2; c: char): csize {.importcpp: "write", header: "Print.h".}
proc write*(this: var Arduboy2; c: int8): csize {.importcpp: "write", header: "Print.h".}
proc print*(this: var Arduboy2; a2: ptr FlashStringHelper): csize {.importcpp: "print",
    header: "Print.h".}
#proc print*(this: var Arduboy2; a2: ptr FlashStringHelper): csize {.importcpp: "print",
#    header: "Print.h".}
#proc print*(this: var Arduboy2; a2: String): csize {.importcpp: "print", header: "Print.h".}
proc print*(this: var Arduboy2; a2: ptr char): csize {.importcpp: "print", header: "Print.h".}
proc print*(this: var Arduboy2; a2: cstring): csize {.importcpp: "print", header: "Print.h".}
proc print*(this: var Arduboy2; a2: char): csize {.importcpp: "print", header: "Print.h".}
#proc print*(this: var Arduboy2; a2: cuchar; a3: cint = DEC): csize {.importcpp: "print",
#    header: "Print.h".}
#proc print*(this: var Arduboy2; a2: cint; a3: cint = DEC): csize {.importcpp: "print",
#    header: "Print.h".}
proc print*(this: var Arduboy2; a2: cuint; a3: cint = DEC): csize {.importcpp: "print",
    header: "Print.h".}
proc print*(this: var Arduboy2; a2: clong; a3: cint = DEC): csize {.importcpp: "print",
    header: "Print.h".}
proc print*(this: var Arduboy2; a2: culong; a3: cint = DEC): csize {.importcpp: "print",
    header: "Print.h".}
#proc print*(this: var Arduboy2; a2: cdouble; a3: cint = 2): csize {.importcpp: "print",
#    header: "Print.h".}
#proc print*(this: var Arduboy2; a2: Printable): csize {.importcpp: "print",
#    header: "Print.h".}
#proc println*(this: var Arduboy2; a2: ptr __FlashStringHelper): csize {.
#    importcpp: "println", header: "Print.h".}
#proc println*(this: var Arduboy2; s: String): csize {.importcpp: "println",
#    header: "Print.h".}
proc println*(this: var Arduboy2; a2: ptr char): csize {.importcpp: "println",
    header: "Print.h".}
proc println*(this: var Arduboy2; a2: char): csize {.importcpp: "println", header: "Print.h".}
proc println*(this: var Arduboy2; a2: cuchar; a3: cint = DEC): csize {.importcpp: "println",
    header: "Print.h".}
proc println*(this: var Arduboy2; a2: cint; a3: cint = DEC): csize {.importcpp: "println",
    header: "Print.h".}
proc println*(this: var Arduboy2; a2: cuint; a3: cint = DEC): csize {.importcpp: "println",
    header: "Print.h".}
proc println*(this: var Arduboy2; a2: clong; a3: cint = DEC): csize {.importcpp: "println",
    header: "Print.h".}
proc println*(this: var Arduboy2; a2: culong; a3: cint = DEC): csize {.importcpp: "println",
    header: "Print.h".}
proc println*(this: var Arduboy2; a2: cdouble; a3: cint = 2): csize {.importcpp: "println",
    header: "Print.h".}
#proc println*(this: var Arduboy2; a2: Printable): csize {.importcpp: "println",
#    header: "Print.h".}
proc println*(this: var Arduboy2): csize {.importcpp: "println", header: "Print.h".}
proc flush*(this: var Arduboy2) {.importcpp: "flush", header: "Print.h".}

proc drawPixel*(this: var Arduboy2, x: int16; y: int16; color: uint8 = WHITE) {.
    importcpp: "drawPixel", header: "Arduboy2.h".}
