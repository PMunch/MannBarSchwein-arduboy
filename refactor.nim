template pressed(button: <Button Type>): bool = arduboy.pressed(button)
template logicStep(): bool = subFrame == 0

proc playTitle() =
  if logicStep:
    if AButton.pressed():
      scene = Game
      reset frame
      reset score
    if UpButton.pressed():
      myDelay += 10
    [...]

template collision(entity: untyped): =
  x > `entity X` and x + w < `entity X` + `entity W` and [...]

template drawObject(entity: untyped) =
  drawBitmap(`entity X`, `entity Y`, `entity Sprite`)

proc remove(entity: untyped) =
  taken[]

proc playGame() =
  drawLevel()
  withPlayerBounds(x, y, w, h):
    drawPlayer()
    processLevelEntities:
    of spike:
      if collision(entity):
        gameOver()
    of manfood:
      if collision(entity) and state = Mann:
        score += 500
        particles()
        entity.remove()
  subFrame += 1
  if subFrame == 3:
    subFrame = 0
    inc frame
    inc score


template play(scene: Scene) =
  `play scene`

loop:
  nextFrame
  customDelay
  display

  if logicStep:
    clear
    pollButtons

  scene.play()
