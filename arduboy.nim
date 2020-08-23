import nimfiles / [Arduboy2, Arduboy2Core]
import strutils

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

template read4bytes(bmp: untyped, pos: int): untyped =
  bmp[pos].int or bmp[pos + 1].int shl 8 or bmp[pos + 2].int shl 16 or bmp[pos + 3].int shl 24

template read3bytes(bmp: untyped, pos: int): untyped =
  bmp[pos].int or bmp[pos + 1].int shl 8 or bmp[pos + 2].int shl 16

template read2bytes(bmp: untyped, pos: int): untyped =
  bmp[pos].int or bmp[pos + 1].int shl 8

proc loadBMP*(filename: static[string]): string {.compileTime.} =
  let
    data = staticRead(filename)
    bmp = data
  doAssert char(bmp[0]) & char(bmp[1]) == "BM", "Unrecognised BMP format, must be \"BM\"/Windows format"
  let
    size = bmp.read4bytes(2)
    offset = bmp.read4bytes(10)
    dibsize = bmp[14].int

  case dibsize:
  of 40, 108, 124:
    let
      readWidth = bmp.read4bytes(18)
      leftover = readWidth mod 4
      width = readWidth + (4 - (if leftover == 0: 4 else: leftover))
      bitspp = bmp.read2bytes(28)
    doAssert bitspp in {8, 24, 32}, "Bits per pixel must be equal to 8 or 32, not: " & $bitspp
    var
      x = newString(readWidth)
      y: seq[string]
      i = 0
    for b in countup(offset, size - 1, bitspp div 8):
      if i == width:
        i = 0
        y.add x
      if i < readWidth:
        if bitspp == 8:
          x[i] = if bmp[b] <= '\x80': ' ' else: '#'
        elif bitspp == 24:
          echo bmp.read3bytes(b).toHex 6
          x[i] = if bmp.read3bytes(b) <= 0x80: ' ' else: '#'
        elif bitspp == 32:
          echo (bmp.read4bytes(b) and 0x00_FF_FF_FF).toHex 8
          x[i] = if (bmp.read4bytes(b) and 0x00_FF_FF_FF) <= 0x80: ' ' else: '#'
        else: discard
      inc i
    if x.len != 0:
      y.add x
    result = y[^1]
    for i in countdown(y.high - 1, 0):
      result.add "\n" & y[i]
  else:
    doAssert dibsize in {40, 108, 124}, "Unknown DIB header format: " & $dibsize
