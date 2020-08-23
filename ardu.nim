import nimfiles / [Arduboy2, Arduboy2Core]
import ardusprites

const arduinoPath {.strdefine.}: string = ""

{.passC: "-I" & arduinoPath & "/cores/arduino".}
{.passC: "-I" & arduinoPath & "/variants/leonardo".}
{.passC: "-I" & arduinoPath & "/libraries/EEPROM/src".}
{.compile: arduinoPath & "/cores/arduino/main.cpp".}
{.compile: arduinoPath & "/cores/arduino/PluggableUSB.cpp".}
{.compile: arduinoPath & "/cores/arduino/USBCore.cpp".}
{.compile: arduinoPath & "/cores/arduino/wiring.c".}
{.compile: arduinoPath & "/cores/arduino/WMath.cpp".}
{.compile: arduinoPath & "/cores/arduino/CDC.cpp".}
{.compile: arduinoPath & "/cores/arduino/Print.cpp".}
{.compile: arduinoPath & "/cores/arduino/abi.cpp".}

const spritePath {.strdefine.}: string = "../../MannBarSchwein/Arduboy/sprites/"
loadSprite(leg1, spritePath & "leg_frame1.bmp")
loadSprite(leg2, spritePath & "leg_frame2.bmp")
loadSprite(leg3, spritePath & "leg_frame3.bmp")
loadSprite(manBody, spritePath & "man_body.bmp")
loadSprite(bearBody, spritePath & "bear_body.bmp")
loadSprite(pigBody, spritePath & "pig_body.bmp")
loadSprite(manHead, spritePath & "man_head.bmp")
loadSprite(bearHead, spritePath & "bear_head.bmp")
loadSprite(pigHead, spritePath & "pig_head.bmp")
loadSprite(manGate, spritePath & "man_gate.bmp")
loadSprite(bearGate, spritePath & "bear_gate.bmp")
loadSprite(pigGate, spritePath & "pig_gate.bmp")
loadSprite(manGateClosed, spritePath & "man_gate_closed.bmp")
loadSprite(bearGateClosed, spritePath & "bear_gate_closed.bmp")
loadSprite(pigGateClosed, spritePath & "pig_gate_closed.bmp")
loadSprite(money, spritePath & "money.bmp")
loadSprite(meat, spritePath & "meat.bmp")
loadSprite(apple, spritePath & "apple.bmp")
loadSprite(ground, spritePath & "ground.bmp")
loadSprite(ground2, spritePath & "block.bmp")
loadSprite(spike, spritePath & "spike.bmp")
loadSprite(mountainSmall, spritePath & "mountain_small.bmp")
loadSprite(mountainBig, spritePath & "mountain_big.bmp")
loadSprite(mann, spritePath & "mann.bmp")
loadSprite(bar, spritePath & "bar.bmp")
loadSprite(schwein, spritePath & "schwein.bmp")

proc yield_impl*() {.exportc: "yield".} = discard

proc F(x: cstring): ptr FlashStringHelper {.importc, nodecl.}
proc micros(): culong {.importc, nodecl.}

var
  arduboy: Arduboy2
  frame = 0'u8
  test: uint32
  myDelay: culong
  tempTime: culong

proc setup*() {.exportc.} =
  arduboy.begin()
  arduboy.setFramerate(255)
  myDelay = 7430 #4705

proc loop*() {.exportc.} =
  if not arduboy.nextFrame():
    return
  while micros() - tempTime < myDelay: discard
  tempTime = micros()
  arduboy.display()

  if frame == 3:
    frame = 0
    arduboy.clear()
    let keys = arduboy.buttonsState()
    if (keys and UP_BUTTON) != 0:
      myDelay += 10
    if (keys and DOWN_BUTTON) != 0:
      myDelay -= 10
    if (keys and LEFT_BUTTON) != 0:
      myDelay -= 1
    if (keys and RIGHT_BUTTON) != 0:
      myDelay += 1
    #arduboy.setCursor(4, 9)
    #discard arduboy.print(myDelay)

  if frame == 0:
    #arduboy.fillRect(0, 48, 128, 16)
    #arduboy.fillRect(84, 0, 42, 64)
    #drawBitmap(35-1, 49, manHead, NoMask, SpriteUnMasked)
    #drawBitmap(35+1, 56, manBody, NoMask, SpriteUnMasked)
    #drawBitmap(35, 60, leg1, NoMask, SpriteUnMasked)
    drawBitmap(46, 24, bar, NoMask, SpriteUnMasked)
  if frame == 1:
    #arduboy.fillRect(0, 32, 128, 16)
    #arduboy.fillRect(42, 0, 42, 64)
    #drawBitmap(50-1, 49, bearHead, NoMask, SpriteUnMasked)
    #drawBitmap(50+1, 56, bearBody, NoMask, SpriteUnMasked)
    #drawBitmap(50, 60, leg1, NoMask, SpriteUnMasked)
    drawBitmap(6, 24, mann, NoMask, SpriteUnMasked)
  if frame == 2:
    #arduboy.fillRect(0, 16, 128, 16)
    #drawBitmap(20-1, 49, pigHead, NoMask, SpriteUnMasked)
    #drawBitmap(20+1, 56, pigBody, NoMask, SpriteUnMasked)
    #drawBitmap(20, 60, leg1, NoMask, SpriteUnMasked)
    drawBitmap(74, 24, schwein, NoMask, SpriteUnMasked)

  frame += 1
