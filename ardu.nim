include arduboy
import ardusprites
import macros
import math

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
#proc F(x: cstring): ptr FlashStringHelper {.importc, nodecl.}
proc micros(): culong {.importc, nodecl.}
proc pgm_read_byte(x: ptr uint8): uint8 {.importc, nodecl.}
proc pgm_read_word(x: ptr uint8): uint16 {.importc, nodecl.}

proc toFixed(x: float): int8 {.compileTime.} =
  #x.trunc.int8 shl 4 + ((x - x.trunc)*10).int8
  round(x * (1 shl 4)).int8

proc roundFixed(x: int16): int16 =
  (x + toFixed(0.5).int16) shr 4

type
  Scene = enum
    Title, Game
  Character = enum
    Mann, Bar, Schwein
  LevelData[count: static[int]] = distinct array[count, uint8]
  PositionData[count, width: static[int]] = distinct array[count, uint16]
  Particle = object
    age: uint8
    x, y: int16
    xs, ys: int8

proc `[]`(data: LevelData, idx: uint32): uint8 =
  pgmReadByte(cast[ptr uint8](cast[int](data.unsafeAddr) + idx.int))

proc `[]`(data: PositionData, idx: SomeInteger): uint16 =
  pgmReadWord(cast[ptr uint8](cast[int](data.unsafeAddr) + (idx * 2).int))
  #array[data.count, uint16](data)[idx]

macro loadPositions(name: untyped, levelString: static[string]): untyped =
  #echo levelString
  #echo levelString.len
  #echo levelString[654]
  let w = levelString.find('\n')
  #echo "w: ", w
  var levelData = nnkBracket.newTree()
  for i in countdown(w, 1):
    for j in countdown(7, 0):
      let
        idx = (w+1)*j + i - 1
        pos = w*j + i - 1
      #echo "pos: ", pos, " ", ord(levelString[pos])
      if levelString[idx] == '#':
        levelData.add newLit(pos.uint16)
    #echo line.int.toBin 8
  let count = levelData.len
  result = quote do:
    let `name` {.codegenDecl: "const PROGMEM $# $#".} = PositionData[`count`, `w`](`levelData`)
    #let `name` = PositionData[`count`, `w`](`levelData`)
  echo result.repr

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
    let `name` {.codegenDecl: "const PROGMEM $# $#".} = LevelData[`count`](`levelData`)
  echo result.repr

template loadPositionData(name: untyped, file: static[string]): untyped =
  loadPositions(name, loadBMP(file))

template loadLevelData(name: untyped, file: static[string]): untyped =
  loadLevel(name, loadBMP(file))


loadLevelData(level, "level.bmp")
loadLevelData(manfood, "manfood.bmp")
loadLevelData(bearfood, "bearfood.bmp")
loadLevelData(pigfood, "pigfood.bmp")
loadPositionData(spikes, "spikes.bmp")
loadPositionData(mangates, "mangate.bmp")
loadPositionData(piggates, "piggate.bmp")
loadPositionData(beargates, "beargate.bmp")

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
  mangateidx: uint8 = 0
  piggateidx: uint8 = 0
  beargateidx: uint8 = 0
  taken: array[level.count, uint8]
  score = 0
  particles: array[100, Particle]
  sp, ep: uint16
  lowestSpikeIdx: uint16 = 0

template legFrame(): untyped = [leg1.unsafeAddr, leg2.unsafeAddr][(frame div 4) mod 2][]

template calculatePlayerBounds() {.dirty.} =
  let
    x = 110'i16
    y = 64 - 11 - y
    by = ((frame div 4) mod 2).int16
    hy = (((frame - 2) div 4) mod 2).int16

proc drawPlayer() =
  calculatePlayerBounds()
  if subFrame == 0 and currentCharacter == Bar:
    drawBitmap(x, y-hy, bearHead, NoMask, SpriteUnMasked)
    drawBitmap(x+2, y+7-by, bearBody, NoMask, SpriteUnMasked)
    drawBitmap(x+1, y+11-by, legFrame, NoMask, SpriteUnMasked)
  if subFrame == 1 and currentCharacter == Mann:
    drawBitmap(x, y-hy, manHead, NoMask, SpriteUnMasked)
    drawBitmap(x+2, y+7-by, manBody, NoMask, SpriteUnMasked)
    drawBitmap(x+1, y+11-by, legFrame, NoMask, SpriteUnMasked)
  if subFrame == 2 and currentCharacter == Schwein:
    drawBitmap(x, y-hy, pigHead, NoMask, SpriteUnMasked)
    drawBitmap(x+2, y+7-by, pigBody, NoMask, SpriteUnMasked)
    drawBitmap(x+1, y+11-by, legFrame, NoMask, SpriteUnMasked)

template drawGate(c, state: untyped): untyped =
  let
    nextGate = `c gates`[`c gateidx`]
    gateX = (nextGate mod `c gates`.width) * 6
    gateY = nextGate div `c gates`.width
    lvlpos = `c gates`.width * 6 - frame
  if gateX < lvlpos and lvlpos - gateX < 128 + 15:
    if currentCharacter == state:
      drawBitmap(128 - (lvlpos - gateX).int16, (gateY * 6).int16 + 4, `c gate`)
    else:
      drawBitmap(128 - (lvlpos - gateX).int16, (gateY * 6).int16 + 4, `c gateClosed`)
  if lvlpos - gateX > uint16.high-100 and `c gateidx` < `c gates`.count - 1:
    inc `c gateidx`

template drawBlock(blocks, sprite: untyped): untyped =
  if (mask and blocks[i]) == mask:
    drawBitmap(offset + 128 - 6 - 6*(i-start).int16, 64'i16 - h, sprite)

template drawObject(objects, sprite: untyped): untyped =
  if (mask and objects[i]) == mask and (mask and taken[i]) != mask:
    drawBitmap(offset + 128 - 6 - 6*(i-start).int16, 64'i16 - h, sprite)

template drawObject2(c, state: untyped): untyped =
  var passed = typeof(lowestSpikeIdx).default
  if subframe == 0 and lowestSpikeIdx != spikes.width:
    for i in lowestSpikeIdx ..< spikes.width:
      let
        next = spikes[i]
        x = (next mod spikes.width) * 6
        y = next div spikes.width
        lvlpos = spikes.width * 6 - frame
      if x < lvlpos:
        if lvlpos - x < 128 + 6:
          drawBitmap(128 - (lvlpos - x).int16, (y * 6).int16 + 18, spike)
        else:
          break
      else:
        inc passed
    lowestSpikeIdx += passed

proc drawLevel() =
  if subFrame == 1:
    drawGate(man, Mann)
  if subFrame == 2:
    drawGate(pig, Schwein)
  if subFrame == 0:
    drawGate(bear, Bar)
  spikes.drawObject2(spike)

  let
    start = frame div 6
    offset = (frame mod 6).int16
  for i in start .. min(start + 23, (level.count - 1).uint32):
    var
      h = 7*6 + 4'i16
      mask = 0b0000_0001'u8
    while mask != 0:
      level.drawBlock(ground2)
      if subFrame == 1:
        manfood.drawObject(money)
      if subFrame == 2:
        pigfood.drawObject(apple)
      if subFrame == 0:
        bearfood.drawObject(meat)
      mask = mask shl 1
      h -= 6

proc drawTitle() =
  if subFrame == 0:
    drawBitmap(46, 24, bar)
  if subFrame == 1:
    drawBitmap(6, 24, mann)
  if subFrame == 2:
    drawBitmap(75, 24, schwein)

iterator roundRange[R, T](buffer: var array[R, T], longRange: HSlice): var T =
  ## Iterator that takes a buffer and two indices. The buffer is treated as
  ## circular, and the indices are intended to be exclusively increasing.
  assert R.low == 0, "Currently only supports zero-indexed arrays"
  for i in longRange:
    yield buffer[int(i) mod buffer.len]

proc drawParticles() =
  if sp == ep: return
  var deadParticles = typeof(sp).default
  for particle in particles.roundRange sp ..< ep:
    if subframe == 0:
      if particle.age == 9:
        inc deadParticles
        continue
      particle.x += particle.xs + toFixed(1)
      particle.y += particle.ys
      particle.ys += 1
      #if frame mod (32 - (abs(particle.xs) div 4)).uint32 == 0:
      #  particle.x += 1
      #if frame mod (32 - (abs(particle.ys) div 4)).uint32 == 0:
      #  particle.y += 1
      if frame mod 2 == 0:
        inc particle.age
    if subFrame == particle.age div 3:
      arduboy.drawPixel(particle.x.roundFixed, particle.y.roundFixed)
  sp += deadParticles

proc createParticle(x, y: int16, xs, ys: int8) =
  particles[ep].age = 0
  particles[ep].x = x shl 4
  particles[ep].y = y shl 4
  particles[ep].xs = xs
  particles[ep].ys = ys
  inc ep

template next(x: var Character) =
  x = Character((x.ord + 1) mod (Character.high.int + 1))

proc setup*() {.exportc.} =
  arduboy.begin()
  arduboy.setFramerate(255)
  myDelay = 7245 #4705

template gameOver() =
  scene = Title
  currentCharacter = Mann
  mangateidx = 0
  beargateidx = 0
  piggateidx = 0
  lowestSpikeIdx = 0
  sp = 0
  ep = 0
  reset taken

macro createCircle(x, y: int, speed: static[float]): untyped =
  result = newStmtList()
  for angle in countup(0, 360, 36):
    let
      xs = (speed * cos(angle.float.degToRad)).toFixed
      ys = (speed * sin(angle.float.degToRad)).toFixed
    result.add quote do:
      createParticle(`x`, `y`, `xs`, `ys`)
  echo result.repr

macro play(scene: Scene) =
  result = quote do:
    case `scene`:
    else: discard
  for scene in Scene:
    result.add nnkOfBranch.newTree(newLit(scene), newCall(newIdentNode("play" & $scene)))

proc playTitle() =
  drawTitle()
  if subFrame == 0:
    if arduboy.pressed(AButton):
      scene = Game
      frame = 0
      score = 0
    let keys = arduboy.buttonsState()
    if (keys and UP_BUTTON) != 0:
      myDelay += 10
    if (keys and DOWN_BUTTON) != 0:
      myDelay -= 10
    if (keys and LEFT_BUTTON) != 0:
      myDelay -= 1
    if (keys and RIGHT_BUTTON) != 0:
      myDelay += 1

proc playGame() =
  #createParticle(10, 20+ep.int16, 1.5.toFixed, (-0.5).toFixed)
  #arduboy.setCursor(64 - ((score.float.log10 + 1) * 2.5).int16, 9)
  #discard arduboy.print(score)
  drawPlayer()
  drawLevel()
  drawParticles()
  if subFrame == 0:
    if arduboy.justPressed(BButton) or arduboy.justPressed(DownButton):
      currentCharacter.next()
    if (arduboy.justPressed(AButton) or arduboy.justPressed(UpButton)) and yspeed == 0:
      yspeed = 3
      jframe = frame
    let
      start = frame div 6 + 2
      h = y div 6
      groundMask = 0b1000_0000'u8 shr (h - 1)
      frontMask = 0b1000_0000'u8 shr h
      frontMask2 = 0b1000_0000'u8 shr (h + 1)
    template collides(tile: untyped): untyped =
      (frontMask != 0 and (tile and frontMask) == frontMask) or
      (frontMask2 != 0 and (tile and frontMask2) == frontMask2)

    template landedOn(tile: untyped): untyped =
      (groundMask != 0 and (tile and groundMask) == groundMask)

    template collidesGate(c, state: untyped): untyped =
      block:
        let
          nextGate = `c gates`[`c gateidx`]
          gateX = (nextGate mod `c gates`.width)*6
          lvlpos = `c gates`.width * 6 - frame
        (currentCharacter != state and gateX < lvlpos and
          lvlpos - gateX < 128 + 15 and lvlpos - gateX < 30 and
          lvlpos - gateX > 20)

    if landedOn(level[start]):
      if yspeed < 0:
        y = h * 6
        yspeed = 0
    elif (frame - jframe) mod 4 == 0:
      yspeed -= 1
    #if landedOn(spikes[start]):
    #  gameOver()
    if collides(level[start+1]):
      gameOver()
    block:
      calculatePlayerBounds()
      arduboy.fillRect(x, y, 8, 13)

  #  if collidesGate(man, Mann) or collidesGate(bear, Bar) or
  #    collidesGate(pig, Schwein):
  #    gameOver()

  #  template pickup(character, objects: untyped): untyped =
  #    if currentCharacter == character and landedOn(objects[start]):
  #      if (taken[start] and groundMask) == 0:
  #        score += 500
  #        let offset = (frame mod 6).int16
  #        #createCircle(128 - 6*3 + offset, 14*6 + 7'i16 - y, 0.3)
  #        taken[start] = taken[start] or groundMask
  #    if currentCharacter == character and collides(objects[start+1]):
  #      if (taken[start+1] and (frontMask or frontMask2)) == 0:
  #        score += 500
  #        let offset = (frame mod 6).int16
  #        if (taken[start+1] and frontMask) == frontMask:
  #          createCircle(128 - 6*4 + offset, 9*6 + 7'i16 - y, 0.3)
  #          taken[start+1] = taken[start+1] or frontMask
  #        else:
  #          createCircle(128 - 6*4 + offset, 8*6 + 7'i16 - y, 0.3)
  #          taken[start+1] = taken[start+1] or frontMask2
  #  Mann.pickup(manfood)
  #  Bar.pickup(bearfood)
  #  Schwein.pickup(pigfood)

    y += yspeed

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
    #discard arduboy.Print(myDelay)

  scene.play()

  subFrame += 1
  if subFrame == 3:
    subFrame = 0
    inc frame
    inc score
