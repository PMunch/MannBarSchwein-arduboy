{.compile: "Arduboy2/Arduboy2Core.cpp".}
## *
##  @file Arduboy2Core.h
##  \brief
##  The Arduboy2Core class for Arduboy hardware initilization and control.
##

##  main hardware compile flags


const
  LOW = 0
  HIGH = 1
  RGB_ON* = LOW
  RGB_OFF* = HIGH

##  ----- Arduboy pins -----

template BV(x: untyped): untyped = 1 shl x
when defined(ARDUBOY_10):
  const
  #  PIN_CS* = 12
  #  CS_PORT* = PORTD
  #  CS_BIT* = PORTD6
  #  PIN_DC* = 4
  #  DC_PORT* = PORTD
  #  DC_BIT* = PORTD4
  #  PIN_RST* = 6
  #  RST_PORT* = PORTD
  #  RST_BIT* = PORTD7
    RED_LED* = 10
    GREEN_LED* = 11
    BLUE_LED* = 9
  #  RED_LED_PORT* = PORTB
  #  RED_LED_BIT* = PORTB6
  #  GREEN_LED_PORT* = PORTB
  #  GREEN_LED_BIT* = PORTB7
  #  BLUE_LED_PORT* = PORTB
  #  BLUE_LED_BIT* = PORTB5
  ##  bit values for button states
  ##  these are determined by the buttonsState() function
  const
    LEFT_BUTTON* = BV(5)       ## *< The Left button value for functions requiring a bitmask
    RIGHT_BUTTON* = BV(6)      ## *< The Right button value for functions requiring a bitmask
    UP_BUTTON* = BV(7)         ## *< The Up button value for functions requiring a bitmask
    DOWN_BUTTON* = BV(4)       ## *< The Down button value for functions requiring a bitmask
    A_BUTTON* = BV(3)          ## *< The A button value for functions requiring a bitmask
    B_BUTTON* = BV(2)          ## *< The B button value for functions requiring a bitmask
  #  PIN_LEFT_BUTTON* = A2
  #  LEFT_BUTTON_PORT* = PORTF
  #  LEFT_BUTTON_PORTIN* = PINF
  #  LEFT_BUTTON_DDR* = DDRF
  #  LEFT_BUTTON_BIT* = PORTF5
  #  PIN_RIGHT_BUTTON* = A1
  #  RIGHT_BUTTON_PORT* = PORTF
  #  RIGHT_BUTTON_PORTIN* = PINF
  #  RIGHT_BUTTON_DDR* = DDRF
  #  RIGHT_BUTTON_BIT* = PORTF6
  #  PIN_UP_BUTTON* = A0
  #  UP_BUTTON_PORT* = PORTF
  #  UP_BUTTON_PORTIN* = PINF
  #  UP_BUTTON_DDR* = DDRF
  #  UP_BUTTON_BIT* = PORTF7
  #  PIN_DOWN_BUTTON* = A3
  #  DOWN_BUTTON_PORT* = PORTF
  #  DOWN_BUTTON_PORTIN* = PINF
  #  DOWN_BUTTON_DDR* = DDRF
  #  DOWN_BUTTON_BIT* = PORTF4
  #  PIN_A_BUTTON* = 7
  #  A_BUTTON_PORT* = PORTE
  #  A_BUTTON_PORTIN* = PINE
  #  A_BUTTON_DDR* = DDRE
  #  A_BUTTON_BIT* = PORTE6
  #  PIN_B_BUTTON* = 8
  #  B_BUTTON_PORT* = PORTB
  #  B_BUTTON_PORTIN* = PINB
  #  B_BUTTON_DDR* = DDRB
  #  B_BUTTON_BIT* = PORTB4
  #  PIN_SPEAKER_1* = 5
  #  PIN_SPEAKER_2* = 13
  #  SPEAKER_1_PORT* = PORTC
  #  SPEAKER_1_DDR* = DDRC
  #  SPEAKER_1_BIT* = PORTC6
  #  SPEAKER_2_PORT* = PORTC
  #  SPEAKER_2_DDR* = DDRC
  #  SPEAKER_2_BIT* = PORTC7
  ##  -----------------------
  ##  ----- DevKit pins -----
elif defined(AB_DEVKIT):
  const
    PIN_CS* = 6
    CS_PORT* = PORTD
    CS_BIT* = PORTD7
    PIN_DC* = 4
    DC_PORT* = PORTD
    DC_BIT* = PORTD4
    PIN_RST* = 12
    RST_PORT* = PORTD
    RST_BIT* = PORTD6
    SPI_MOSI_PORT* = PORTB
    SPI_MOSI_BIT* = PORTB2
    SPI_SCK_PORT* = PORTB
    SPI_SCK_BIT* = PORTB1
  ##  map all LEDs to the single TX LED on DEVKIT
  const
    RED_LED* = 17
    GREEN_LED* = 17
    BLUE_LED* = 17
    BLUE_LED_PORT* = PORTB
    BLUE_LED_BIT* = PORTB0
  ##  bit values for button states
  ##  these are determined by the buttonsState() function
  const
    LEFT_BUTTON* = BV(5)
    RIGHT_BUTTON* = BV(2)
    UP_BUTTON* = BV(4)
    DOWN_BUTTON* = BV(6)
    A_BUTTON* = BV(1)
    B_BUTTON* = BV(0)
  ##  pin values for buttons, probably shouldn't use these
  const
    PIN_LEFT_BUTTON* = 9
    LEFT_BUTTON_PORT* = PORTB
    LEFT_BUTTON_PORTIN* = PINB
    LEFT_BUTTON_DDR* = DDRB
    LEFT_BUTTON_BIT* = PORTB5
    PIN_RIGHT_BUTTON* = 5
    RIGHT_BUTTON_PORT* = PORTC
    RIGHT_BUTTON_PORTIN* = PINC
    RIGHT_BUTTON_DDR* = DDRC
    RIGHT_BUTTON_BIT* = PORTC6
    PIN_UP_BUTTON* = 8
    UP_BUTTON_PORT* = PORTB
    UP_BUTTON_PORTIN* = PINB
    UP_BUTTON_DDR* = DDRB
    UP_BUTTON_BIT* = PORTB4
    PIN_DOWN_BUTTON* = 10
    DOWN_BUTTON_PORT* = PORTB
    DOWN_BUTTON_PORTIN* = PINB
    DOWN_BUTTON_DDR* = DDRB
    DOWN_BUTTON_BIT* = PORTB6
    PIN_A_BUTTON* = A0
    A_BUTTON_PORT* = PORTF
    A_BUTTON_PORTIN* = PINF
    A_BUTTON_DDR* = DDRF
    A_BUTTON_BIT* = PORTF7
    PIN_B_BUTTON* = A1
    B_BUTTON_PORT* = PORTF
    B_BUTTON_PORTIN* = PINF
    B_BUTTON_DDR* = DDRF
    B_BUTTON_BIT* = PORTF6
    PIN_SPEAKER_1* = A2
    SPEAKER_1_PORT* = PORTF
    SPEAKER_1_DDR* = DDRF
    SPEAKER_1_BIT* = PORTF5
  ##  SPEAKER_2 is purposely not defined for DEVKIT as it could potentially
  ##  be dangerous and fry your hardware (because of the devkit wiring).
  ##
  ##  Reference: https://github.com/Arduboy/Arduboy/issues/108
##  --------------------
##  ----- Pins common on Arduboy and DevKit -----
##  Unconnected analog input used for noise by initRandomSeed()

#const
#  RAND_SEED_IN* = A4
#  RAND_SEED_IN_PORT* = PORTF
#  RAND_SEED_IN_BIT* = PORTF1
#
###  Value for ADMUX to read the random seed pin: 2.56V reference, ADC1
#
#const
#  RAND_SEED_IN_ADMUX* = (BV(REFS0) or BV(REFS1) or BV(MUX0))
#
###  SPI interface
#
#const
#  SPI_MISO_PORT* = PORTB
#  SPI_MISO_BIT* = PORTB3
#  SPI_MOSI_PORT* = PORTB
#  SPI_MOSI_BIT* = PORTB2
#  SPI_SCK_PORT* = PORTB
#  SPI_SCK_BIT* = PORTB1
#  SPI_SS_PORT* = PORTB
#  SPI_SS_BIT* = PORTB0

##  --------------------
##  OLED hardware (SSD1306)

const
  OLED_PIXELS_INVERTED* = 0x000000A7
  OLED_PIXELS_NORMAL* = 0x000000A6
  OLED_ALL_PIXELS_ON* = 0x000000A5
  OLED_PIXELS_FROM_RAM* = 0x000000A4
  OLED_VERTICAL_FLIPPED* = 0x000000C0
  OLED_VERTICAL_NORMAL* = 0x000000C8
  OLED_HORIZ_FLIPPED* = 0x000000A0
  OLED_HORIZ_NORMAL* = 0x000000A1

##  -----

const
  WIDTH* = 128
  HEIGHT* = 64
  COLUMN_ADDRESS_END* = (WIDTH - 1) and 127
  PAGE_ADDRESS_END* = ((HEIGHT div 8) - 1) and 7

## * \brief
##  Eliminate the USB stack to free up code space.
##
##  \note
##  **WARNING:** Removing the USB code will make it impossible for sketch
##  uploader programs to automatically force a reset into the bootloader!
##  This means that a user will manually have to invoke a reset in order to
##  upload a new sketch, after one without USB has be been installed.
##  Be aware that the timing for the point that a reset must be initiated can
##  be tricky, which could lead to some frustration on the user's part.
##
##  \details
##  \parblock
##  This macro will cause the USB code, normally included in the sketch as part
##  of the standard Arduino environment, to be eliminated. This will free up a
##  fair amount of program space, and some RAM space as well, at the expense of
##  disabling all USB functionality within the sketch (except as power input).
##
##  The macro should be placed before the `setup()` function definition:
##
##  \code{.cpp}
##  #include <Arduboy2.h>
##
##  Arduboy2 arduboy;
##
##  // (Other variable declarations, etc.)
##
##  // Eliminate the USB stack
##  ARDUBOY_NO_USB
##
##  void setup() {
##    arduboy.begin();
##    // any additional setup code
##  }
##  \endcode
##
##  As stated in the warning above, without the USB code an uploader program
##  will be unable to automatically force a reset into the bootloader to upload
##  a new sketch. The user will have to manually invoke a reset. In addition to
##  eliminating the USB code, this macro will check if the DOWN button is held
##  when the sketch first starts and, if so, will call `exitToBootloader()` to
##  start the bootloader for uploading. This makes it easier for the user than
##  having to press the reset button.
##
##  However, to make it even more convenient for a user to invoke the bootloader
##  it is highly recommended that a sketch using this macro include a menu or
##  prompt that allows the user to press the DOWN button within the sketch,
##  which should cause `exitToBootloader()` to be called.
##
##  At a minimum, the documentation for the sketch should clearly state that a
##  manual reset will be required, and give detailed instructions on what the
##  user must do to upload a new sketch.
##  \endparblock
##
##  \see Arduboy2Core::exitToBootloader()
##
## #define ARDUBOY_NO_USB int main() __attribute__ ((OS_main)); \
## int main() { \
##   Arduboy2Core::mainNoUSB(); \
##   return 0; \
## }
## * \brief
##  Lower level functions generally dealing directly with the hardware.
##
##  \details
##  This class is inherited by Arduboy2Base and thus also Arduboy2, so wouldn't
##  normally be used directly by a sketch.
##
##  \note
##  A friend class named _Arduboy2Ex_ is declared by this class. The intention
##  is to allow a sketch to create an _Arduboy2Ex_ class which would have access
##  to the private and protected members of the Arduboy2Core class. It is hoped
##  that this may eliminate the need to create an entire local copy of the
##  library, in order to extend the functionality, in most circumstances.
##

type
  Arduboy2Core* {.importcpp: "Arduboy2Core", header: "Arduboy2Core.h", bycopy.} = object ##  internals


proc constructArduboy2Core*(): Arduboy2Core {.constructor,
    importcpp: "Arduboy2Core(@)", header: "Arduboy2Core.h".}
proc idle*(this: var Arduboy2Core) {.importcpp: "idle", header: "Arduboy2Core.h".}
proc LCDDataMode*(this: var Arduboy2Core) {.importcpp: "LCDDataMode",
                                        header: "Arduboy2Core.h".}
proc LCDCommandMode*(this: var Arduboy2Core) {.importcpp: "LCDCommandMode",
    header: "Arduboy2Core.h".}
proc SPItransfer*(this: var Arduboy2Core; data: uint8) {.importcpp: "SPItransfer",
    header: "Arduboy2Core.h".}
proc displayOff*(this: var Arduboy2Core) {.importcpp: "displayOff",
                                       header: "Arduboy2Core.h".}
proc displayOn*(this: var Arduboy2Core) {.importcpp: "displayOn",
                                      header: "Arduboy2Core.h".}
proc width*(this: var Arduboy2Core): uint8 {.importcpp: "width",
    header: "Arduboy2Core.h".}
proc height*(this: var Arduboy2Core): uint8 {.importcpp: "height",
    header: "Arduboy2Core.h".}
proc buttonsState*(this: var Arduboy2Core): uint8 {.importcpp: "buttonsState",
    header: "Arduboy2Core.h".}
proc paint8Pixels*(this: var Arduboy2Core; pixels: uint8) {.
    importcpp: "paint8Pixels", header: "Arduboy2Core.h".}
proc paintScreen*(this: var Arduboy2Core; image: ptr uint8) {.
    importcpp: "paintScreen", header: "Arduboy2Core.h".}
proc paintScreen*(this: var Arduboy2Core; image: ptr uint8; clear: bool = false) {.
    importcpp: "paintScreen", header: "Arduboy2Core.h".}
proc blank*(this: var Arduboy2Core) {.importcpp: "blank", header: "Arduboy2Core.h".}
proc invert*(this: var Arduboy2Core; inverse: bool) {.importcpp: "invert",
    header: "Arduboy2Core.h".}
proc allPixelsOn*(this: var Arduboy2Core; on: bool) {.importcpp: "allPixelsOn",
    header: "Arduboy2Core.h".}
proc flipVertical*(this: var Arduboy2Core; flipped: bool) {.importcpp: "flipVertical",
    header: "Arduboy2Core.h".}
proc flipHorizontal*(this: var Arduboy2Core; flipped: bool) {.
    importcpp: "flipHorizontal", header: "Arduboy2Core.h".}
proc sendLCDCommand*(this: var Arduboy2Core; command: uint8) {.
    importcpp: "sendLCDCommand", header: "Arduboy2Core.h".}
proc setRGBled*(this: var Arduboy2Core; red: uint8; green: uint8; blue: uint8) {.
    importcpp: "setRGBled", header: "Arduboy2Core.h".}
proc setRGBled*(this: var Arduboy2Core; color: uint8; val: uint8) {.
    importcpp: "setRGBled", header: "Arduboy2Core.h".}
proc freeRGBled*(this: var Arduboy2Core) {.importcpp: "freeRGBled",
                                       header: "Arduboy2Core.h".}
proc digitalWriteRGB*(this: var Arduboy2Core; red: uint8; green: uint8;
                     blue: uint8) {.importcpp: "digitalWriteRGB",
                                    header: "Arduboy2Core.h".}
proc digitalWriteRGB*(this: var Arduboy2Core; color: uint8; val: uint8) {.
    importcpp: "digitalWriteRGB", header: "Arduboy2Core.h".}
proc boot*(this: var Arduboy2Core) {.importcpp: "boot", header: "Arduboy2Core.h".}
proc safeMode*(this: var Arduboy2Core) {.importcpp: "safeMode",
                                     header: "Arduboy2Core.h".}
proc delayShort*(this: var Arduboy2Core; ms: uint16) {.importcpp: "delayShort",
    header: "Arduboy2Core.h".}
proc exitToBootloader*(this: var Arduboy2Core) {.importcpp: "exitToBootloader",
    header: "Arduboy2Core.h".}
proc mainNoUSB*(this: var Arduboy2Core) {.importcpp: "mainNoUSB",
                                      header: "Arduboy2Core.h".}
