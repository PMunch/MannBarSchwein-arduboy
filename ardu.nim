include arduboy
import macros, macroutils
import ardusprites
import math
import tables
import fixedpoint

const
  colours = false
  backdrop = false
  spritePath {.strdefine.}: string = "sprites/"

# Set up fixed point types
defFixedPoint(Speed, int8, 4)
defFixedPoint(Position, int16, 4)

type
  Scene = enum
    Title, Highscore, Game, GameOver
  Character = enum
    Mann, Bar, Schwein
  Particle = object
    age: uint8
    x, y: Position
    xs, ys: Speed
  BackdropSprite = enum
    Big, Small
  Backdrop = object
    sprite: BackdropSprite
    x: Position
    y: int16

# Load all our sprites
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
loadSprite(mountainSmallMask, spritePath & "mountain_small_mask.bmp")
loadSprite(mountainBigMask, spritePath & "mountain_big_mask.bmp")
loadSprite(mann, spritePath & "mann.bmp")
loadSprite(bar, spritePath & "bar.bmp")
loadSprite(schwein, spritePath & "schwein.bmp")

var
  # We don't call NimMain anywhere, so you can't instantiate variables here
  arduboy: Arduboy2
  score: int16

include levelloader, highscores # Includes for simplicity

# Load the level data
loadLevelData(level, "level.bmp")
loadPositionData(manfoods, "manfood.bmp")
loadPositionData(bearfoods, "bearfood.bmp")
loadPositionData(pigfoods, "pigfood.bmp")
loadPositionData(spikes, "spikes.bmp")
loadPositionData(mangates, "mangate.bmp")
loadPositionData(piggates, "piggate.bmp")
loadPositionData(beargates, "beargate.bmp")

var
  subFrame: uint8
  frame: uint32
  myDelay: culong
  tempTime: culong
  scene: Scene
  currentCharacter: Character
  y: Position
  yspeed: Speed
  particles: array[150, Particle]
  sp, ep: uint16
  lowestManFoodIdx: uint16
  lowestPigFoodIdx: uint16
  lowestBearFoodIdx: uint16
  lowestManGateIdx: uint16
  lowestPigGateIdx: uint16
  lowestBearGateIdx: uint16
  lowestSpikeIdx: uint16
  takenManFood: set[0..manFoods.count]
  takenBearFood: set[0..bearFoods.count]
  takenPigFood: set[0..pigFoods.count]
  backdrops: array[5, Backdrop]

template legFrame(): untyped = [leg1.unsafeAddr, leg2.unsafeAddr][(frame div 4) mod 2][]

template calculatePlayerBounds() {.dirty.} =
  let
    x = 110'i16
    y = 64 - 11 - y.getInt
    by = ((frame div 4) mod 2).int16
    hy = (((frame - 2) div 4) mod 2).int16

proc playerBoundingBox(): tuple[x, y: int16, w, h: uint8] =
  calculatePlayerBounds()
  (x, y - hy, 8'u8, (13 - by).uint8)

proc drawPlayer() =
  calculatePlayerBounds()
  if subFrame >= 0 and currentCharacter == Bar:
    drawBitmap(x, y-hy, bearHead)
    drawBitmap(x+2, y+7-by, bearBody)
    drawBitmap(x+1, y+11-by, legFrame)
  if subFrame >= 1 and currentCharacter == Mann:
    drawBitmap(x, y-hy, manHead)
    drawBitmap(x+2, y+7-by, manBody)
    drawBitmap(x+1, y+11-by, legFrame)
  if subFrame >= 2 and currentCharacter == Schwein:
    drawBitmap(x, y-hy, pigHead)
    drawBitmap(x+2, y+7-by, pigBody)
    drawBitmap(x+1, y+11-by, legFrame)

template processEntity(entity, spriteWidth, action: untyped): untyped =
  var passed = typeof(`lowest entity Idx`).default
  for i in `lowest entity Idx` ..< `entity s`.count:
    if (when declared(`taken entity`): not `taken entity`.contains i else: true):
      let
        next = `entity s`[i]
        x = (next mod `entity s`.width) * 6
        y = (next div `entity s`.width) * 6
        lvlpos = `entity s`.width * 6 - frame
      if x < lvlpos:
        if lvlpos - x < 128 + spriteWidth:
          let
            `entity Idx` {.inject.} = i
            `entity X` {.inject.} = (128 - lvlpos + x).int16
            `entity Y` {.inject.} = (y + 64 - 8*6 + 2).int16
          action
        else:
          break
      else:
        inc passed
  `lowest entity Idx` += passed

macro processLevelEntities(branches: varargs[untyped]): untyped =
  type Entity = enum
    Spike, ManFood, BearFood, PigFood, ManGate, BearGate, PigGate
  var actions: Table[Entity, NimNode]
  for branch in branches:
    actions[parseEnum[Entity]($branch[0])] = branch[1]
  result = superQuote do:
    if subFrame >= 1:
      processEntity(mangate, 15):
        `actions[ManGate]`
      processEntity(manfood, 6):
        `actions[ManFood]`
    if subFrame >= 2:
      processEntity(piggate, 15):
        `actions[PigGate]`
      processEntity(pigfood, 6):
        `actions[PigFood]`
    if subFrame >= 0:
      processEntity(beargate, 15):
        `actions[BearGate]`
      processEntity(spike, 6):
        `actions[Spike]`
      processEntity(bearfood, 6):
        `actions[BearFood]`
  echo result.repr

template processLevel(action: untyped) =
  let
    start = frame div 6
    offset = (frame mod 6).int16
  for i in start .. min(start + 23, (level.count - 1).uint32):
    var
      h = 7*6 + 4'i16
      mask = 0b0000_0001'u8
    while mask != 0:
      if (mask and level[i]) == mask:
        let
          blockX {.inject.} = offset + 128 - 6 - 6*(i-start).int16
          blockY {.inject.} = 64'i16 - h
        action

      mask = mask shl 1
      h -= 6

proc drawBackdrops() =
  if subFrame == 2:
    for i in 0..backdrops.high:
      case backdrops[i].sprite:
      of Big:
        drawBitmap(backdrops[i].x.getInt, backdrops[i].y, mountainBig, mountainBigMask, SpriteMasked)
      of Small:
        drawBitmap(backdrops[i].x.getInt, backdrops[i].y, mountainSmall, mountainSmallMask, SpriteMasked)
      if scene != GameOver:
        backdrops[i].x += [toSpeed(0.3), toSpeed(0.4), toSpeed(0.5), toSpeed(0.6), toSpeed(0.7)][i]
      if backdrops[i].x > toPosition(128):
        backdrops[i].x.set -(44 * (1 + (frame and 0b11)).int)
        case frame and 0b1:
        of 0:
          backdrops[i].sprite = Small
          backdrops[i].y = 64 - 4 - 22
        of 1:
          backdrops[i].sprite = Big
          backdrops[i].y = 64 - 4 - 44
        else: discard

proc drawTitle() =
  if subFrame == 0 and frame > 50:
    drawBitmap(46, 24, bar)
  if subFrame == 1 and frame > 10:
    drawBitmap(6, 24, mann)
  if subFrame == 2 and frame > 90:
    drawBitmap(75, 24, schwein)
  if subFrame == 2 and frame > 100 and (frame div 10) mod 10 > 5:
    arduboy.setCursor(16, 48)
    discard arduboy.print("Press A to start")

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
      if particle.age >= 18:
        inc deadParticles
        continue
      particle.x += particle.xs +
        (if scene != GameOver: toSpeed(1) else: toSpeed(0))
      particle.y += particle.ys
      particle.ys += toSpeed(0.1)
      inc particle.age
    if subFrame == particle.age div 3:
      arduboy.drawPixel(particle.x.getInt, particle.y.getInt)
  sp += deadParticles

proc createParticle(x, y: int16, xs, ys: Speed) =
  let part = ep mod particles.len.uint16
  particles[part].age = 0
  particles[part].x.set x
  particles[part].y.set y
  particles[part].xs = xs
  particles[part].ys = ys
  inc ep
  if ep mod particles.len.uint16 == sp mod particles.len.uint16:
    inc sp

template next(character: var Character) =
  createParticleCircle(player.x + 1, player.y + 6, 2.0)
  character = Character((character.ord + 1) mod (Character.high.int + 1))

proc setup*() {.exportc.} =
  arduboy.begin()
  arduboy.setFramerate(255)
  myDelay = 7245

template gameOver() =
  if scene != GameOver:
    scene = GameOver
    createParticleCircle(player.x, player.y, 1.5)
    createParticleCircle(player.x, player.y, 1.0, 36 div 2)

macro createParticleCircle(x, y: int, speed: static[float], startAngle: static[int] = 0): untyped =
  result = newStmtList()
  for angle in countup(startAngle, 360, 36):
    let
      xs = (speed * cos(angle.float.degToRad))
      ys = (speed * sin(angle.float.degToRad))
    result.add quote do:
      createParticle(`x`, `y`, toSpeed(`xs`), toSpeed(`ys`))
  echo result.repr

macro play(scene: Scene) =
  result = quote do:
    case `scene`:
    else: discard
  for scene in Scene:
    result.add nnkOfBranch.newTree(newLit(scene), newCall(newIdentNode("play" & $scene)))

proc startGame() =
  scene = Game
  frame = 0
  score = 0
  y = toPosition(20)
  yspeed = toSpeed(-0.5)
  backdrops = [
    Backdrop(x: toPosition(-43), y: 64 - 4 - 44, sprite: Big),
    Backdrop(x: toPosition(-20), y: 64 - 4 - 40, sprite: Big),
    Backdrop(x: toPosition(0), y: 64 - 4 - 30, sprite: Big),
    Backdrop(x: toPosition(40), y: 64 - 4 - 10, sprite: Small),
    Backdrop(x: toPosition(60), y: 64 - 4 - 17, sprite: Small)
  ]

proc playTitle() =
  drawTitle()
  if subFrame == 0 and frame > 50: # Slight delay here to make sure that a mistimed jump doesn't start a new game
    if arduboy.pressed(AButton):
      startGame()
    let keys = arduboy.buttonsState()
    if (keys and UP_BUTTON) != 0:
      myDelay += 10
    if (keys and DOWN_BUTTON) != 0:
      myDelay -= 10
    if (keys and LEFT_BUTTON) != 0:
      myDelay -= 1
    if (keys and RIGHT_BUTTON) != 0:
      myDelay += 1
  if frame > 1000:
    scene = Highscore

proc playHighScore() =
  if displayHighScores():
    startGame()
  else:
    scene = Title
    frame = 0

template collides(bounds: tuple[x, y: int16, w, h: uint8], entityX, entityY: int16, entityW, entityH = 6'u8): bool =
  bounds.x < entityX + entityW.int16 and
  bounds.x + bounds.w.int16 > entityX and
  bounds.y < entityY + entityH.int16 and
  bounds.y + bounds.h.int16 > entityY

template processFood(character, state: untyped): untyped =
  if currentCharacter == state and player.collides(`character FoodX`, `character FoodY`):
    `taken character Food`.incl `character FoodIdx`
    score += 500
    createParticleCircle(`character FoodX`, `character FoodY` - 3, 1.0)
    createParticleCircle(`character FoodX`, `character FoodY` - 3, 0.5, 36 div 2)

template processGate(character, state: untyped): untyped =
  if currentCharacter == state:
    drawBitmap(`character gateX`, `character gateY` - 13, `character gate`)
  else:
    drawBitmap(`character gateX`, `character gateY` - 13, `character gateClosed`)
    if player.collides(`character gateX`, 0, 6, 64): # Ensure you can't jump over gates
      gameOver()

proc characters(score: int16): int16 =
  case score:
  of int16.low..(-1): characters(abs(score)) + 1
  of 0..9: 1
  of 10..99: 2
  of 100..999: 3
  of 1000..9999: 4
  of 10000..int16.high: 5

proc playGame() =
  arduboy.setCursor(64 - (score.characters()*8) div 2, 9)
  discard arduboy.print(score)
  when backdrop:
    drawBackdrops()
  if scene != GameOver:
    drawPlayer()
  let player = playerBoundingBox()
  processLevelEntities:
  of Spike:
    drawBitmap(spikeX, spikeY, spike)
    if player.collides(spikeX, spikeY):
      gameOver()
  of ManFood:
    drawBitmap(manfoodX, manfoodY, money)
    processFood(man, Mann)
  of BearFood:
    drawBitmap(bearfoodX, bearfoodY, meat)
    processFood(bear, Bar)
  of PigFood:
    drawBitmap(pigfoodX, pigfoodY, apple)
    processFood(pig, Schwein)
  of ManGate:
    processGate(man, Mann)
  of BearGate:
    processGate(bear, Bar)
  of PigGate:
    processGate(pig, Schwein)
  if subframe == 0:
    yspeed += toSpeed(-0.1)
  processLevel:
    if subframe >= 0:
      if blockX + 6 > player.x and blockX < player.x + player.w.int16:
        if 64 + 2 + 1 - 14 - (y + yspeed).getInt < blockY + 5 and
          64 + 2 + 1 - 14 - (y + yspeed).getInt + 13 > blockY:
          if 64 + 2 - 14 - y.getInt < blockY + 5 and
            64 + 2 - 14 - y.getInt + 13 > blockY:
            gameOver()
          else:
            if yspeed < toSpeed(0):
              y.set(60 - blockY + 6)
              yspeed = toSpeed(0)
            if scene != GameOver:
              createParticle(player.x + 4, player.y + 13, toSpeed(0.5),
                case frame mod 3:
                of 0: toSpeed(-0.7)
                of 1: toSpeed(-0.5)
                of 2: toSpeed(-1)
                else: toSpeed(0) # Won't happen
              )
    drawBitmap(blockX, blockY, ground2)
  if player.y > 64:
    gameOver()
  drawParticles()
  if subframe == 0 and scene != GameOver:
    if arduboy.justPressed(BButton) or arduboy.justPressed(DownButton):
      currentCharacter.next()
    # TODO: Prevent double-jump
    if (arduboy.justPressed(AButton) or arduboy.justPressed(UpButton)) and yspeed.getInt == 0:
      yspeed.set 2

    y += yspeed

template playGameOver() =
  if sp == ep:
    frame = 0
    scene = Title
    currentCharacter = Mann
    lowestMangateIdx = 0
    lowestBeargateIdx = 0
    lowestPiggateIdx = 0
    lowestManfoodIdx = 0
    lowestBearfoodIdx = 0
    lowestPigfoodIdx = 0
    lowestSpikeIdx = 0
    reset takenManFood
    reset takenBearFood
    reset takenPigFood
    sp = 0
    ep = 0
    enterHighScore()
  playGame()

proc loop*() {.exportc.} =
  if not arduboy.nextFrame():
    return
  while micros() - tempTime < myDelay: discard
  tempTime = micros()

  # Updates the display every subframe for colours, or every full frame for bw
  if colours or subFrame == 0:
    arduboy.display()

  if subFrame == 0:
    arduboy.clear()
    arduboy.pollButtons()
    # Debug print for setting myDelay
    #arduboy.setCursor(4, 9)
    #discard arduboy.Print(myDelay)

  scene.play()

  subFrame += 1
  if subFrame == 3:
    subFrame = 0
    if scene != GameOver:
      inc frame
      inc score
