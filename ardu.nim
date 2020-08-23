include arduboy
import ardusprites
import macros

const spritePath {.strdefine.}: string = "sprites/"

loadSprite(leg1, spritePath & "leg_frame1_alt.bmp")
loadSprite(leg2, spritePath & "leg_frame2_alt.bmp")
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
proc pgm_read_byte(x: ptr uint8): uint8 {.importc, nodecl.}

type
  Scene = enum
    Title, Game
  Character = enum
    Mann, Bar, Schwein
  LevelData[count: static[int]] = distinct array[count, uint8]

proc `[]`(levelData: LevelData, idx: uint32): uint8 =
  pgmReadByte(cast[ptr uint8](cast[int](levelData) + idx.int))

macro loadLevel(name: untyped, levelString: static[string]): untyped =
  #echo levelString
  #echo levelString.len
  #echo levelString[654]
  let w = levelString.find('\n')
  #echo "w: ", w
  var levelData = nnkBracket.newTree()
  for i in countdown(w, 1):
    var line = 0'u8
    for j in countdown(7, 0):
      let pos = (w+1)*j + i - 1
      #echo "pos: ", pos, " ", ord(levelString[pos])
      line = line or ((levelString[pos] == '#').uint8 shl j)
    #echo line.int.toBin 8
    levelData.add newLit(line)
  let count = levelData.len
  result = quote do:
    let `name` {.codegenDecl: "const $# PROGMEM $#".} = LevelData[`count`](`levelData`)
  echo result.repr

template loadLevelData(name: untyped, file: static[string]): untyped =
  loadLevel(name, loadBMP(file))

loadLevelData(level, "level.bmp")
loadLevelData(manfood, "manfood.bmp")
    # [0b1000_0000'u8, 0b1100_0000, 0b1010_0000, 0b1001_0000, 0b1000_1000, 0b1000_0100, 0b1000_0010, 0b1000_0001, 0b1100_0000, 0b1110_0000, 0b1101_0000, 0b1100_1000, 0b1100_0100, 0b1100_0010, 0b1100_0001, 0b1110_0000, 0b1111_0000, 0b1110_1000, 0b1110_0100, 0b1110_0010, 0b1110_0001, 0b1000_0000, 0b1000_0000, 0b1000_0000, 0b1000_0000, 0b1000_0000, 0b1000_0000, 0b1000_0000, 0b1000_0000, 0b1000_0000]
    # [0b1000_0000'u8, 0b1000_0000, 0b1000_0000, 0b1000_0000, 0b1000_0000, 0b1000_0000, 0b1000_0000, 0b1100_0000, 0b1000_0000, 0b1000_0000, 0b1000_0000, 0b1000_0000, 0b1000_0000, 0b1000_0000, 0b1000_0000, 0b1100_0000, 0b1100_0000, 0b1100_0000, 0b1110_0000, 0b1110_0000, 0b1000_0000, 0b1000_0000, 0b1000_0000, 0b1000_0000, 0b1000_0000, 0b1000_0000, 0b1000_0000, 0b1000_0000, 0b1000_0000, 0b1000_0000]

var
  arduboy: Arduboy2
  subFrame = 0'u8
  frame: uint32
  jframe: uint32
  myDelay: culong
  tempTime: culong
  scene = Title
  currentCharacter: Character
  y: int16 = 10
  yspeed: int16 = -1

template legFrame(): untyped = [leg1.unsafeAddr, leg2.unsafeAddr][(frame div 4) mod 2][]

proc drawPlayer() =
  let
    x = 110'i16
    y = 64 - 11 - y
    by = ((frame div 4) mod 2).int16
    hy = (((frame - 2) div 4) mod 2).int16
  if subFrame == 0 and currentCharacter == Bar:
    drawBitmap(x, y-hy, bearHead, NoMask, SpriteUnMasked)
    drawBitmap(x+2, y+7-by, bearBody, NoMask, SpriteUnMasked)
    drawBitmap(x+1, y+11-by, legFrame, NoMask, SpriteUnMasked)
  if subFrame == 1 and currentCharacter == Schwein:
    drawBitmap(x, y-hy, pigHead, NoMask, SpriteUnMasked)
    drawBitmap(x+2, y+7-by, pigBody, NoMask, SpriteUnMasked)
    drawBitmap(x+1, y+11-by, legFrame, NoMask, SpriteUnMasked)
  if subFrame == 2 and currentCharacter == Mann:
    drawBitmap(x, y-hy, manHead, NoMask, SpriteUnMasked)
    drawBitmap(x+2, y+7-by, manBody, NoMask, SpriteUnMasked)
    drawBitmap(x+1, y+11-by, legFrame, NoMask, SpriteUnMasked)

proc drawLevel() =
  let
    start = frame div 6
    offset = (frame mod 6).int16
  for i in start .. min(start + 23, (level.count - 1).uint32):
    var
      h = 4'i16
      mask = 0b1000_0000'u8
    while mask != 0:
      if (mask and level[i]) == mask:
        drawBitmap(offset + 128 - 6 - 6*(i-start).int16, 64'i16 - h, ground2)
      #if (mask and manfood[i]) == mask:
      #  drawBitmap(offset + 128 - 6 - 6*(i-start).int16, 64'i16 - h, money)
      mask = mask shr 1
      h += 6

proc drawTitle() =
  if subFrame == 0:
    drawBitmap(46, 24, bar, NoMask, SpriteUnMasked)
  if subFrame == 1:
    drawBitmap(6, 24, mann, NoMask, SpriteUnMasked)
  if subFrame == 2:
    drawBitmap(74, 24, schwein, NoMask, SpriteUnMasked)

template next(x: var Character) =
  x = Character((x.ord + 1) mod (Character.high.int + 1))

proc setup*() {.exportc.} =
  arduboy.begin()
  arduboy.setFramerate(255)
  myDelay = 7245 #4705

proc loop*() {.exportc.} =
  if not arduboy.nextFrame():
    return
  while micros() - tempTime < myDelay: discard
  tempTime = micros()
  arduboy.display()

  if subFrame == 0:
    arduboy.clear()
    arduboy.pollButtons()
    #arduboy.setCursor(4, 9)
    #discard arduboy.print(myDelay)

  case scene:
  of Title:
    drawTitle()
    if subFrame == 0:
      if arduboy.pressed(AButton):
        scene = Game
        frame = 0
      let keys = arduboy.buttonsState()
      if (keys and UP_BUTTON) != 0:
        myDelay += 10
      if (keys and DOWN_BUTTON) != 0:
        myDelay -= 10
      if (keys and LEFT_BUTTON) != 0:
        myDelay -= 1
      if (keys and RIGHT_BUTTON) != 0:
        myDelay += 1
  of Game:
    drawLevel()
    drawPlayer()
    if subFrame == 0:
      if arduboy.justPressed(BButton) or arduboy.justPressed(DownButton):
        currentCharacter.next()
      if (arduboy.justPressed(AButton) or arduboy.justPressed(UpButton)) and yspeed == 0:
        yspeed = 3
        jframe = frame
      let
        start = frame div 6 + 2
        offset = (frame mod 6).int16
        h = y div 6
        ho = y mod 6
        groundMask = 0b1000_0000'u8 shr (h - 1)
        frontMask = 0b1000_0000'u8 shr h
      arduboy.setCursor(4, 9)
      discard arduboy.print(yspeed)
      if groundMask != 0 and (level[start] and groundMask) == groundMask:
        if yspeed < 0:
          y = h * 6
          yspeed = 0
      elif (frame - jframe) mod 4 == 0:
        yspeed -= 1
      if frontMask != 0 and (level[start+1] and frontMask) == frontMask:
        # You died!
        scene = Title
      y += yspeed

  subFrame += 1
  if subFrame == 3:
    subFrame = 0
    inc frame
