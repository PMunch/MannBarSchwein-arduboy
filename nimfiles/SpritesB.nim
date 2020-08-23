## *
##  @file SpritesB.h
##  \brief
##  A class for drawing animated sprites from image and mask bitmaps.
##  Optimized for small code size.
##

import
  Arduboy2, SpritesCommon

## * \brief
##  A class for drawing animated sprites from image and mask bitmaps.
##  Optimized for small code size.
##
##  \details
##  The functions in this class are identical to the `Sprites` class. The only
##  difference is that the functions in this class are optimized for smaller
##  code size rather than execution speed.
##
##  See the `Sprites` class documentation for details on the use of the
##  functions in this class.
##
##  Even if the speed is acceptable when using `SpritesB`, you should still try
##  using `Sprites`. In some cases `Sprites` will produce less code than
##  `SpritesB`, notably when only one of the functions is used.
##
##  You can easily switch between using the `Sprites` class or the `SpritesB`
##  class by using one or the other to create an object instance:
##
##  \code{.cpp}
##  Sprites sprites;  // Use this to optimize for execution speed
##  SpritesB sprites; // Use this to (likely) optimize for code size
##  \endcode
##
##  \see Sprites
##

type
  SpritesB* {.importcpp: "SpritesB", header: "SpritesB.h", bycopy.} = object ## * \brief
                                                                     ##  Draw a sprite using a separate image and mask array.
                                                                     ##
                                                                     ##  \param x,y The coordinates of the top left pixel location.
                                                                     ##  \param bitmap A pointer to the array containing the image frames.
                                                                     ##  \param mask A pointer to the array containing the mask frames.
                                                                     ##  \param frame The frame number of the image to draw.
                                                                     ##  \param mask_frame The frame number for the mask to use (can be different
                                                                     ##  from the image frame number).
                                                                     ##
                                                                     ##  \see
                                                                     ## Sprites::drawExternalMask()
                                                                     ##


proc drawExternalMask*(x: int16; y: int16; bitmap: ptr uint8; mask: ptr uint8;
                      frame: uint8; mask_frame: uint8) {.
    importcpp: "SpritesB::drawExternalMask(@)", header: "SpritesB.h".}
proc drawPlusMask*(x: int16; y: int16; bitmap: ptr uint8; frame: uint8) {.
    importcpp: "SpritesB::drawPlusMask(@)", header: "SpritesB.h".}
proc drawOverwrite*(x: int16; y: int16; bitmap: ptr uint8; frame: uint8) {.
    importcpp: "SpritesB::drawOverwrite(@)", header: "SpritesB.h".}
proc drawErase*(x: int16; y: int16; bitmap: ptr uint8; frame: uint8) {.
    importcpp: "SpritesB::drawErase(@)", header: "SpritesB.h".}
proc drawSelfMasked*(x: int16; y: int16; bitmap: ptr uint8; frame: uint8) {.
    importcpp: "SpritesB::drawSelfMasked(@)", header: "SpritesB.h".}
proc draw*(x: int16; y: int16; bitmap: ptr uint8; frame: uint8; mask: ptr uint8;
          sprite_frame: uint8; drawMode: uint8) {.
    importcpp: "SpritesB::draw(@)", header: "SpritesB.h".}
proc drawBitmap*(x: int16; y: int16; bitmap: ptr uint8; mask: ptr uint8;
                w: uint8; h: uint8; draw_mode: uint8) {.
    importcpp: "SpritesB::drawBitmap(@)", header: "SpritesB.h".}
