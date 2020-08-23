{.compile: "Arduboy2/Arduboy2Beep.cpp".}
## *
##  @file Arduboy2Beep.h
##  \brief
##  Classes to generate simple square wave tones on the Arduboy speaker pins.
##

## * \brief
##  Play simple square wave tones using speaker pin 1.
##
##  \note
##  Class `BeepPin2` provides identical functions for playing tones on speaker
##  pin 2. Both classes can be used in the same sketch to allow playing
##  two tones at the same time. To do this, the `begin()` and `timer()`
##  functions of both classes must be used.
##
##  \details
##  This class can be used to play square wave tones on speaker pin 1.
##  The functions are designed to produce very small and efficient code.
##
##  A tone can be set to play for a given duration, or continuously until
##  stopped or replaced by a new tone. No interrupts are used. A tone is
##  generated by a hardware timer/counter directly toggling the pin,
##  so once started, no CPU cycles are used to actually play the tone.
##  The program continues to run while a tone is playing. However, a small
##  amount of code is required to time and stop a tone after a given duration.
##
##  Tone frequencies can range from 15.26Hz to 1000000Hz.
##
##  Although there's no specific code to handle mute control, the
##  `Arduboy2Audio` class will work since it has code to mute sound by setting
##  the speaker pins to input mode and unmute by setting the pins as outputs.
##  The `BeepPin1` class doesn't interfere with this operation.
##
##  In order to avoid needing to use interrupts, the duration of tones is timed
##  by calling the `timer()` function continuously at a fixed interval.
##  The duration of a tone is given by specifying the number of times `timer()`
##  will be called before stopping the tone.
##
##  For sketches that use `Arduboy2::nextFrame()`, or some other method to
##  generate frames at a fixed rate, `timer()` can be called once per frame.
##  Tone durations will then be given as the number of frames to play the tone
##  for. For example, with a rate of 60 frames per second a duration of 30
##  would be used to play a tone for half a second.
##
##  The variable named `#duration` is the counter that times the duration of a
##  tone. A sketch can determine if a tone is currently playing by testing if
##  the `#duration` variable is non-zero (assuming it's a timed tone, not a
##  continuous tone).
##
##  To keep the code small and efficient, the frequency of a tone is specified
##  by the actual count value to be loaded into to timer/counter peripheral.
##  The frequency will be determined by the count provided and the clock rate
##  of the timer/counter. In order to allow a tone's frequency to be specified
##  in hertz (cycles per second) the `freq()` helper function is provided,
##  which converts a given frequency to the required count value.
##
##  NOTE that it is intended that `freq()` only be called with constant values.
##  If `freq()` is called with a variable, code to perform floating point math
##  will be included in the sketch, which will likely greatly increase the
##  sketch's code size unless the sketch also uses floating point math for
##  other purposes.
##
##  The formulas for frequency/count conversion are:
##
##      count=(1000000/frequency)-1
##      frequency=1000000/(count+1)
##
##  Counts must be between 0 and 65535.
##
##  All members of the class are static, so it's not necessary to create an
##  instance of the class in order to use it. However, creating an instance
##  doesn't produce any more code and it may make the source code smaller and
##  make it easier to switch to the `BeepPin2` class if it becomes necessary.
##
##  The following is a basic example sketch, which will generate a tone when
##  a button is pressed.
##
##  \code{.cpp}
##  #include <Arduboy2.h>
##  // There's no need to #include <Arduboy2Beep.h>
##  // It will be included in Arduboy2.h
##
##  Arduboy2 arduboy;
##  BeepPin1 beep; // class instance for speaker pin 1
##
##  void setup() {
##    arduboy.begin();
##    arduboy.setFrameRate(50);
##    beep.begin(); // set up the hardware for playing tones
##  }
##
##  void loop() {
##    if (!arduboy.nextFrame()) {
##      return;
##    }
##
##    beep.timer(); // handle tone duration
##
##    arduboy.pollButtons();
##
##    if (arduboy.justPressed(A_BUTTON)) {
##      // play a 1000Hz tone for 100 frames (2 seconds at 50 FPS)
##      // beep.freq(1000) is used to convert 1000Hz to the required count
##      beep.tone(beep.freq(1000), 100);
##    }
##  }
##  \endcode
##
##  \note
##  These functions, and the equivalents in class `BeepPin2`, will not work with
##  a DevKit Arduboy because the speaker pins used cannot be directly controlled
##  by a timer/counter. "Dummy" functions are provided so a sketch will compile
##  and work properly but no sound will be produced.
##
##  \see BeepPin2
##

type
  BeepPin1* {.importcpp: "BeepPin1", header: "Arduboy2Beep.h", bycopy.} = object ## * \brief
                                                                         ##  The counter used by the
                                                                         ## `timer()`
                                                                         ## function to time the
                                                                         ## duration of a tone.
                                                                         ##
                                                                         ##
                                                                         ## \details
                                                                         ##  This
                                                                         ## variable is set by the `dur`
                                                                         ## parameter of the
                                                                         ## `tone()`
                                                                         ## function.
                                                                         ##  It is then
                                                                         ## decremented each time the
                                                                         ## `timer()`
                                                                         ## function is called, if its
                                                                         ##  value isn't 0. When
                                                                         ## `timer()`
                                                                         ## decrements it to 0, a tone that is playing
                                                                         ##  will be
                                                                         ## stopped.
                                                                         ##
                                                                         ##  A sketch can
                                                                         ## determine if a tone is
                                                                         ## currently playing by testing if
                                                                         ##  this
                                                                         ## variable is
                                                                         ## non-zero
                                                                         ## (assuming it's a timed tone, not a
                                                                         ## continuous
                                                                         ##  tone).
                                                                         ##
                                                                         ##
                                                                         ## Example:
                                                                         ##
                                                                         ## \code{.cpp}
                                                                         ##
                                                                         ## beep.tone(beep.freq(1000), 15);
                                                                         ##  while
                                                                         ## (beep.duration != 0) { } // wait for the tone to stop playing
                                                                         ##
                                                                         ## \endcode
                                                                         ##
                                                                         ##  It can also be
                                                                         ## manipulated
                                                                         ## directly by the sketch,
                                                                         ## although this should
                                                                         ##  seldom be
                                                                         ## necessary.
                                                                         ##
    duration* {.importc: "duration".}: uint8 ## * \brief
                                           ##  Set up the hardware.
                                           ##
                                           ##  \details
                                           ##  Prepare the hardware for playing tones.
                                           ##  This function must be called (usually in `setup()`) before using any of
                                           ##  the other functions in this class.
                                           ##


proc begin*(this: var BeepPin1) {.importcpp: "begin", header: "Arduboy2Beep.h".}
proc tone*(this: var BeepPin1; count: uint16) {.importcpp: "tone",
    header: "Arduboy2Beep.h".}
proc tone*(this: var BeepPin1; count: uint16; dur: uint8) {.importcpp: "tone",
    header: "Arduboy2Beep.h".}
proc timer*(this: var BeepPin1) {.importcpp: "timer", header: "Arduboy2Beep.h".}
proc noTone*(this: var BeepPin1) {.importcpp: "noTone", header: "Arduboy2Beep.h".}
proc freq*(this: var BeepPin1; hz: cfloat): uint16 {.importcpp: "freq",
    header: "Arduboy2Beep.h".}
## * \brief
##  Play simple square wave tones using speaker pin 2.
##
##  \details
##  This class contains the same functions as class `BeepPin1` except they use
##  speaker pin 2 instead of speaker pin 1.
##
##  Using `BeepPin1` is more desirable, as it uses a 16 bit Timer, which can
##  produce a greater frequency range and resolution than the 10 bit Timer
##  used by `BeepPin2`. However, if the sketch also includes other sound
##  generating code that uses speaker pin 1, `BeepPin2` can be used to avoid
##  conflict.
##
##  Tone frequencies on speaker pin 2 can range from 61.04Hz to 15625Hz using
##  allowed counts from 3 to 1023.
##
##  The formulas for frequency/count conversion are:
##
##      count=(62500/frequency)-1
##      frequency=62500/(count+1)
##
##  See the documentation for `BeepPin1` for more details.
##
##  \see BeepPin1
##

type
  BeepPin2* {.importcpp: "BeepPin2", header: "Arduboy2Beep.h", bycopy.} = object ## * \brief
                                                                         ##  The counter used by the
                                                                         ## `timer()`
                                                                         ## function to time the
                                                                         ## duration of a tone
                                                                         ##  played on speaker pin 2.
                                                                         ##
                                                                         ##
                                                                         ## \details
                                                                         ##  For details see
                                                                         ## `BeepPin1::duration`.
                                                                         ##
    duration* {.importc: "duration".}: uint8 ## * \brief
                                           ##  Set up the hardware for playing tones using speaker pin 2.
                                           ##
                                           ##  \details
                                           ##  For details see `BeepPin1::begin()`.
                                           ##


proc begin*(this: var BeepPin2) {.importcpp: "begin", header: "Arduboy2Beep.h".}
proc tone*(this: var BeepPin2; count: uint16) {.importcpp: "tone",
    header: "Arduboy2Beep.h".}
proc tone*(this: var BeepPin2; count: uint16; dur: uint8) {.importcpp: "tone",
    header: "Arduboy2Beep.h".}
proc timer*(this: var BeepPin2) {.importcpp: "timer", header: "Arduboy2Beep.h".}
proc noTone*(this: var BeepPin2) {.importcpp: "noTone", header: "Arduboy2Beep.h".}
proc freq*(this: var BeepPin2; hz: cfloat): uint16 {.importcpp: "freq",
    header: "Arduboy2Beep.h".}
