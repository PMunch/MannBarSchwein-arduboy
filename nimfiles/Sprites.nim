{.compile: "Arduboy2/Sprites.cpp".}
## *
##  @file Sprites.h
##  \brief
##  A class for drawing animated sprites from image and mask bitmaps.
##

import
  Arduboy2, SpritesCommon

## * \brief
##  A class for drawing animated sprites from image and mask bitmaps.
##
##  \details
##  The functions in this class will draw to the screen buffer an image
##  contained in an array located in program memory. A mask can also be
##  specified or implied, which dictates how existing pixels in the buffer,
##  within the image boundaries, will be affected.
##
##  A sprite or mask array contains one or more "frames". Each frame is intended
##  to show whatever the sprite represents in a different position, such as the
##  various poses for a running or jumping character. By specifying a different
##  frame each time the sprite is drawn, it can be animated.
##
##  Each image array begins with values for the width and height of the sprite,
##  in pixels. The width can be any value. The height must be a multiple of
##  8 pixels, but with proper masking, a sprite of any height can be created.
##
##  For a separate mask array, as is used with `drawExternalMask()`, the width
##  and height are not included but must contain data of the same dimensions
##  as the corresponding image array.
##
##  Following the width and height values for an image array, or from the
##  beginning of a separate mask array, the array contains the image and/or
##  mask data for each frame. Each byte represents a vertical column of 8 pixels
##  with the least significant bit (bit 0) at the top. The bytes are drawn as
##  8 pixel high rows from left to right, top to bottom. When the end of a row
##  is reached, as specified by the width value, the next byte in the array will
##  be the start of the next row.
##
##  Data for each frame after the first one immediately follows the previous
##  frame. Frame numbers start at 0.
##
##  \note
##  \parblock
##  A separate `SpritesB` class is available as an alternative to this class.
##  The only difference is that the `SpritesB` class is optimized for small
##  code size rather than for execution speed. One or the other can be used
##  depending on whether size or speed is more important.
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
##  \endparblock
##
##  \note
##  \parblock
##  In the example patterns given in each Sprites function description,
##  a # character represents a bit set to 1 and
##  a - character represents a bit set to 0.
##  \endparblock
##
##  \see SpritesB
##

type
  Sprites* {.importcpp: "Sprites", header: "Sprites.h", bycopy.} = object ## * \brief
                                                                  ##  Draw a sprite using a separate image and mask array.
                                                                  ##
                                                                  ##  \param x,y The coordinates of the top left pixel location.
                                                                  ##  \param bitmap A pointer to the array containing the image frames.
                                                                  ##  \param mask A pointer to the array containing the mask frames.
                                                                  ##  \param frame The frame number of the image to draw.
                                                                  ##  \param mask_frame The frame number for the mask to use (can be different
                                                                  ##  from the image frame number).
                                                                  ##
                                                                  ##  \details
                                                                  ##  An array containing the image frames, and another array containing
                                                                  ##  corresponding mask frames, are used to draw a sprite.
                                                                  ##
                                                                  ##  Bits set to 1 in the mask indicate that the pixel will be set to the
                                                                  ##  value of the corresponding image bit. Bits set to 0 in the mask will be
                                                                  ##  left unchanged.
                                                                  ##
                                                                  ##      image  mask   before  after  (# = 1, - = 0)
                                                                  ##
                                                                  ##      -----  -###-  -----   -----
                                                                  ##      --#--  #####  -----   --#--
                                                                  ##      ##-##  ##-##  -----   ##-##
                                                                  ##      --#--  #####  -----   --#--
                                                                  ##      -----  -###-  -----   -----
                                                                  ##
                                                                  ##      image  mask   before  after
                                                                  ##
                                                                  ##      -----  -###-  #####   #---#
                                                                  ##      --#--  #####  #####   --#--
                                                                  ##      ##-##  #####  #####   ##-##
                                                                  ##      --#--  #####  #####   --#--
                                                                  ##      -----  -###-  #####   #---#
                                                                  ##


proc drawExternalMask*(x: int16; y: int16; bitmap: ptr uint8; mask: ptr uint8;
                      frame: uint8; mask_frame: uint8) {.
    importcpp: "Sprites::drawExternalMask(@)", header: "Sprites.h".}
proc drawPlusMask*(x: int16; y: int16; bitmap: ptr uint8; frame: uint8) {.
    importcpp: "Sprites::drawPlusMask(@)", header: "Sprites.h".}
proc drawOverwrite*(x: int16; y: int16; bitmap: ptr uint8; frame: uint8) {.
    importcpp: "Sprites::drawOverwrite(@)", header: "Sprites.h".}
proc drawErase*(x: int16; y: int16; bitmap: ptr uint8; frame: uint8) {.
    importcpp: "Sprites::drawErase(@)", header: "Sprites.h".}
proc drawSelfMasked*(x: int16; y: int16; bitmap: ptr uint8; frame: uint8) {.
    importcpp: "Sprites::drawSelfMasked(@)", header: "Sprites.h".}
proc draw*(x: int16; y: int16; bitmap: ptr uint8; frame: uint8; mask: ptr uint8;
          sprite_frame: uint8; drawMode: uint8) {.importcpp: "Sprites::draw(@)",
    header: "Sprites.h".}
proc drawBitmap*(x: int16; y: int16; bitmap: ptr uint8; mask: ptr uint8;
                w: uint8; h: uint8; draw_mode: uint8) {.
    importcpp: "Sprites::drawBitmap(@)", header: "Sprites.h".}
