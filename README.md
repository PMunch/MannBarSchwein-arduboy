# MannBärSchwein

This is my entry for the Arduboy Game Jam 5: Pretty simple. It is a simple
side-scrolling platformer where the character must morph between three different
states in order to pick up food and pass through gates. The visuals uses a trick
in order to achieve three shades of gray to draw the characters, gates, and food
in different colours. It also has neat graphical effects like particles,
paralaxing background, and screen-shake.

But maybe most interesting of all it's written in Nim! That's right, your
favourite C and Python replacement can finally run on the Arduboy! This means
that the code can be written cleaner and safer than what you would be able to do
in C, and with fewer steps to build. For example the compiler will read in the
BMP files for the sprites and the level during compilation time and create
efficient progmem arrays of them automatically. No extra build step, no manual
overhead of making sure you converted your bitmaps to header files. Just update
the sprite and build! With its great type system sprites and levels are even
coded into types with compile-time information about their size. This means that
`drawBitmap` can ensure that a sprite and a mask is the same size, and that the
pointer you pass it is actually a sprite loaded with a call to `loadSprite` (the
macro that reads the BMP). It also means that if you change the length of the
level images the game will automatically know how to handle the new size. And
all of this with zero run-time overhead, both in speed and binary size! Earlier
experiments with the breakout game showed a byte-by-byte similarily sized output
for a naively converted implementation. And with templates, macros, and other
goodies it was possible to further decrease the binary size without the code
turning to ugly spaghetti.

To build the game simply make sure that the `nim.cfg` file points to a valid
installation of AVR, that you have [Nim](https://nim-lang.org/) installed, and
that you have run `nimble install macroutils fixedpoint` (this should really
have been done with a Nimble file instead of a Makefile, but it's late and I
want to publish this). Then simply run `make ardu.hex` and you're off to the
races! You can also check out the rest of the fairly short Makefile to see how I
upload the hex to an actual device or how I run it in the emulator.

# Binary versions

This repository contains three .hex files:
* `full.hex` is the complete game with all graphical bells and whistles
* `minimal.hex` which is with no background and a single colour
* `paralax.hex` which is with the paralaxing background but only a single colour

If you plan on running it in the emulator I would recommend one of the versions
without "colours" because those don't work properly there. But if you're running
it on proper hardware I highly suggest the `full.hex` version.
