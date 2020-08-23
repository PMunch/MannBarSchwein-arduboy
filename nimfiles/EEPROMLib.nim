##
##   EEPROM.h - EEPROM library
##   Original Copyright (c) 2006 David A. Mellis.  All right reserved.
##   New version by Christopher Andrews 2015.
##
##   This library is free software; you can redistribute it and/or
##   modify it under the terms of the GNU Lesser General Public
##   License as published by the Free Software Foundation; either
##   version 2.1 of the License, or (at your option) any later version.
##
##   This library is distributed in the hope that it will be useful,
##   but WITHOUT ANY WARRANTY; without even the implied warranty of
##   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
##   Lesser General Public License for more details.
##
##   You should have received a copy of the GNU Lesser General Public
##   License along with this library; if not, write to the Free Software
##   Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
##

## **
##     EERef class.
##
##     This object references an EEPROM cell.
##     Its purpose is to mimic a typical byte of RAM, however its storage is the EEPROM.
##     This class has an overhead of two bytes, similar to storing a pointer to an EEPROM cell.
## *

type
  EERef* {.importcpp: "EERef", header: "EEPROM.h", bycopy.} = object
    index* {.importc: "index".}: cint ## Index of current EEPROM cell.


proc constructEERef*(index: cint): EERef {.constructor, importcpp: "EERef(@)",
                                       header: "EEPROM.h".}
proc `*`*(this: EERef): uint8 {.noSideEffect, importcpp: "(* #)", header: "EEPROM.h".}
#converter `uint8`*(this: EERef): uint8 {.noSideEffect,
#    importcpp: "EERef::operator uint8", header: "EEPROM.h".}
proc `+=`*(this: var EERef; `in`: uint8) {.importcpp: "(# += #)", header: "EEPROM.h".}
proc `-=`*(this: var EERef; `in`: uint8) {.importcpp: "(# -= #)", header: "EEPROM.h".}
proc `*=`*(this: var EERef; `in`: uint8) {.importcpp: "(# *= #)", header: "EEPROM.h".}
proc `/=`*(this: var EERef; `in`: uint8) {.importcpp: "(# /= #)", header: "EEPROM.h".}
proc `^=`*(this: var EERef; `in`: uint8) {.importcpp: "(# ^= #)", header: "EEPROM.h".}
proc `%=`*(this: var EERef; `in`: uint8) {.importcpp: "(# %= #)", header: "EEPROM.h".}
proc `&=`*(this: var EERef; `in`: uint8) {.importcpp: "(# &= #)", header: "EEPROM.h".}
proc `|=`*(this: var EERef; `in`: uint8) {.importcpp: "(# |= #)", header: "EEPROM.h".}
proc `<<=`*(this: var EERef; `in`: uint8) {.importcpp: "(# <<= #)", header: "EEPROM.h".}
proc `>>=`*(this: var EERef; `in`: uint8) {.importcpp: "(# >>= #)", header: "EEPROM.h".}
proc update*(this: var EERef; `in`: uint8): var EERef {.importcpp: "update",
    header: "EEPROM.h".}
proc `++`*(this: var EERef): var EERef {.importcpp: "(++ #)", header: "EEPROM.h".}
proc `--`*(this: var EERef): var EERef {.importcpp: "(-- #)", header: "EEPROM.h".}
proc `++`*(this: var EERef; a2: cint): uint8 {.importcpp: "(++ #)", header: "EEPROM.h".}
proc `--`*(this: var EERef; a2: cint): uint8 {.importcpp: "(-- #)", header: "EEPROM.h".}
## **
##     EEPtr class.
##
##     This object is a bidirectional pointer to EEPROM cells represented by EERef objects.
##     Just like a normal pointer type, this can be dereferenced and repositioned using
##     increment/decrement operators.
## *

type
  EEPtr* {.importcpp: "EEPtr", header: "EEPROM.h", bycopy.} = object
    index* {.importc: "index".}: cint ## Index of current EEPROM cell.


proc constructEEPtr*(index: cint): EEPtr {.constructor, importcpp: "EEPtr(@)",
                                       header: "EEPROM.h".}
#converter `int`*(this: EEPtr): cint {.noSideEffect, importcpp: "EEPtr::operator int",
#                                  header: "EEPROM.h".}
proc `*`*(this: var EEPtr): EERef {.importcpp: "(* #)", header: "EEPROM.h".}
proc `++`*(this: var EEPtr): var EEPtr {.importcpp: "(++ #)", header: "EEPROM.h".}
proc `--`*(this: var EEPtr): var EEPtr {.importcpp: "(-- #)", header: "EEPROM.h".}
proc `++`*(this: var EEPtr; a2: cint): EEPtr {.importcpp: "(++ #)", header: "EEPROM.h".}
proc `--`*(this: var EEPtr; a2: cint): EEPtr {.importcpp: "(-- #)", header: "EEPROM.h".}
## **
##     EEPROMClass class.
##
##     This object represents the entire EEPROM space.
##     It wraps the functionality of EEPtr and EERef into a basic interface.
##     This class is also 100% backwards compatible with earlier Arduino core releases.
## *

type
  EEPROMClass* {.importcpp: "EEPROMClass", header: "EEPROM.h", bycopy.} = object ## Basic user access methods.


proc `[]`*(this: var EEPROMClass; idx: cint): EERef {.importcpp: "#[@]",
    header: "EEPROM.h".}
proc read*(this: var EEPROMClass; idx: cint): uint8 {.importcpp: "read",
    header: "EEPROM.h".}
proc write*(this: var EEPROMClass; idx: cint; val: uint8) {.importcpp: "write",
    header: "EEPROM.h".}
proc update*(this: var EEPROMClass; idx: cint; val: uint8) {.importcpp: "update",
    header: "EEPROM.h".}
proc begin*(this: var EEPROMClass): EEPtr {.importcpp: "begin", header: "EEPROM.h".}
proc `end`*(this: var EEPROMClass): EEPtr {.importcpp: "end", header: "EEPROM.h".}
proc length*(this: var EEPROMClass): uint16 {.importcpp: "length", header: "EEPROM.h".}
proc get*[T](this: var EEPROMClass; idx: cint; t: var T): var T {.importcpp: "get",
    header: "EEPROM.h".}
proc put*[T](this: var EEPROMClass; idx: cint; t: T): T {.importcpp: "put",
    header: "EEPROM.h".}
var EEPROM* {.importcpp: "EEPROM", header: "EEPROM.h".}: EEPROMClass
