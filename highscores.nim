import nimfiles / [Arduboy2, Arduboy2Core, Arduboy2Beep, EEPROMLib]

const
  eeFile = 2.byte
  address = (eeFile * 7 * 5 + EEPROMStorageSpaceStart).cint

var
  initials: array[3, char]
  textBuffer: array[16, char]

proc sprintf(buf, frmt: cstring) {.header: "<stdio.h>",
                                  importc: "sprintf",
                                  varargs.}

template print(a: Arduboy2, x, y: SomeOrdinal, value: untyped, textSize: static[int] = 1): untyped =
  when textSize != 1:
    a.setTextSize(textSize)
  a.setCursor(x, y)
  discard a.print(value)
  when textSize != 1:
    a.setTextSize(1)

macro printf(a: Arduboy2, x, y: SomeOrdinal, buffer: var openArray[char], format: untyped, values: varargs[untyped]): untyped =
  result = quote do:
    sprintf(`buffer`.addr, `format`)
    `a`.setCursor(`x`, `y`)
    discard `a`.print(`buffer`.addr)
  for value in values:
    result[0].add value

template readInt16(e: EEPROMClass, pos: untyped): untyped =
  let
    hi = e.read(pos)
    lo = e.read(pos + 1)
    res =
      if hi == 0xFF and lo == 0xFF:
        0'i16
      else:
        (hi.int16 shl 8) or lo.int16
  res

template readInitialsInto(e: EEPROMClass, pos: untyped, initials: untyped): untyped =
  initials[0] = e.read(pos).char
  initials[1] = e.read(pos + 1).char
  initials[2] = e.read(pos + 2).char

proc displayHighScores(): bool =
  const
    y = 8'i16
    x = 24'i16
  arduboy.clear()
  arduboy.print(32, 0, "HIGH SCORES".cstring)
  arduboy.display()

  for i in 0.cint..6:
    arduboy.printf(x, y + i.int16 * 8, textBuffer, "%2d", i + 1)
    arduboy.display()
    let score = EEPROM.readInt16(address + 5 * i)

    EEPROM.readInitialsInto(address + 5 * i + 2, initials)

    if score > 0:
      arduboy.printf(x + 24, y + i.int16 * 8, textBuffer, "%c%c%c %u", initials[0], initials[1], initials[2], score)
      arduboy.display()

  for i in 0..<300:
    arduboy.delayShort(15)
    if arduboy.justPressed(AButton) or arduboy.justPressed(BButton):
      return true
  return false

proc enterInitials() =
  var index = 0'i16
  arduboy.clear()
  for initial in initials.mitems:
    initial = ' '

  while true:
    arduboy.display()
    arduboy.clear()
    arduboy.pollButtons()

    arduboy.print(16, 0, "HIGH SCORE".cstring)
    arduboy.printf(88, 0, textBuffer, "%u", score)
    arduboy.print(56, 20, initials[0])
    arduboy.print(64, 20, initials[1])
    arduboy.print(72, 20, initials[2])

    for i in 0.int16..2:
      arduboy.drawLine(56 + (i*8), 27, 56 + (i*8) + 6, 27, 1)

    arduboy.drawLine(56, 28, 88, 28, 0)
    arduboy.drawLine(56 + (index*8), 28, 56 + (index*8) + 6, 28, 1)
    arduboy.delayShort(70)

    if arduboy.justPressed(LeftButton) or arduboy.justPressed(BButton):
      if index > 0:
        dec index
        #playToneTimed(1046, 80)
    if arduboy.justPressed(RightButton):
      if index < 2:
        inc index
        #playToneTimed(1046, 80)
    if arduboy.justPressed(UpButton):
      inc initials[index]
      #playToneTimed(523, 80)
      initials[index] = case initials[index]:
        of '0': ' '
        of '!': 'A'
        of '[': '0'
        of '@': '!'
        else: initials[index]
    if arduboy.justPressed(DownButton):
      dec initials[index]
      #playToneTimed(523, 80)
      initials[index] = case initials[index]:
        of ' ': '?'
        of '/': 'Z'
        of 31.char: '/'
        of '@': ' '
        else: initials[index]
    if arduboy.justPressed(AButton):
      #playToneTimed(1046, 80)
      if index < 2:
        inc index
      else:
        return

proc enterHighScore() =
  var
    tmpInitials: array[3, char]
    tmpScore = 0'i16

  for i in 0.cint..6:
    tmpScore = EEPROM.readInt16(address + 5 * i)

    if score > tmpScore:
      enterInitials()
      for j in i.cint..6:
        tmpScore = EEPROM.readInt16(address + 5 * j)

        EEPROM.readInitialsInto(address + 5 * j + 2, tmpInitials)

        EEPROM.update(address + 5 * j, ((score shr 8) and 0xFF).byte)
        EEPROM.update(address + 5 * j + 1, (score and 0xFF).byte)
        EEPROM.update(address + 5 * j + 2, initials[0].byte)
        EEPROM.update(address + 5 * j + 3, initials[1].byte)
        EEPROM.update(address + 5 * j + 4, initials[2].byte)

        score = tmpScore
        initials = tmpInitials

      score = 0
      for initial in initials.mitems:
        initial = ' '

      return
