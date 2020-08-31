type
  LevelData[count: static[int]] = distinct array[count, uint8]
  PositionData[count, width: static[int]] = distinct array[count, uint16]

proc `[]`*(data: LevelData, idx: uint32): uint8 =
  pgmReadByte(cast[ptr uint8](cast[int](data.unsafeAddr) + idx.int))

proc `[]`*(data: PositionData, idx: SomeInteger): uint16 =
  pgmReadWord(cast[ptr uint8](cast[int](data.unsafeAddr) + (idx * 2).int))
  #array[data.count, uint16](data)[idx]

macro loadPositions*(name: untyped, levelString: static[string]): untyped =
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

macro loadLevel*(name: untyped, levelString: static[string]): untyped =
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

template loadPositionData*(name: untyped, file: static[string]): untyped =
  loadPositions(name, loadBMP(file))

template loadLevelData*(name: untyped, file: static[string]): untyped =
  loadLevel(name, loadBMP(file))
