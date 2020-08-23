##
##  Print.h - Base class that provides print() and println()
##  Copyright (c) 2008 David A. Mellis.  All right reserved.
##
##  This library is free software; you can redistribute it and/or
##  modify it under the terms of the GNU Lesser General Public
##  License as published by the Free Software Foundation; either
##  version 2.1 of the License, or (at your option) any later version.
##
##  This library is distributed in the hope that it will be useful,
##  but WITHOUT ANY WARRANTY; without even the implied warranty of
##  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
##  Lesser General Public License for more details.
##
##  You should have received a copy of the GNU Lesser General Public
##  License along with this library; if not, write to the Free Software
##  Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
##

import
  WString, Printable

const
  DEC* = 10
  HEX* = 16
  OCT* = 8
  BIN* = 2

type
  Print* {.importcpp: "Print", header: "Print.h", bycopy.} = object


proc constructPrint*(): Print {.constructor, importcpp: "Print(@)", header: "Print.h".}
proc getWriteError*(this: var Print): cint {.importcpp: "getWriteError",
                                        header: "Print.h".}
proc clearWriteError*(this: var Print) {.importcpp: "clearWriteError",
                                     header: "Print.h".}
proc write*(this: var Print; a2: uint8_t): csize {.importcpp: "write", header: "Print.h".}
proc write*(this: var Print; str: cstring): csize {.importcpp: "write", header: "Print.h".}
proc write*(this: var Print; buffer: ptr uint8_t; size: csize): csize {.
    importcpp: "write", header: "Print.h".}
proc write*(this: var Print; buffer: cstring; size: csize): csize {.importcpp: "write",
    header: "Print.h".}
proc write*(this: var Print; t: cshort): csize {.importcpp: "write", header: "Print.h".}
proc write*(this: var Print; t: cushort): csize {.importcpp: "write", header: "Print.h".}
proc write*(this: var Print; t: cint): csize {.importcpp: "write", header: "Print.h".}
proc write*(this: var Print; t: cuint): csize {.importcpp: "write", header: "Print.h".}
proc write*(this: var Print; t: clong): csize {.importcpp: "write", header: "Print.h".}
proc write*(this: var Print; t: culong): csize {.importcpp: "write", header: "Print.h".}
proc write*(this: var Print; c: char): csize {.importcpp: "write", header: "Print.h".}
proc write*(this: var Print; c: int8_t): csize {.importcpp: "write", header: "Print.h".}
proc print*(this: var Print; a2: ptr __FlashStringHelper): csize {.importcpp: "print",
    header: "Print.h".}
proc print*(this: var Print; a2: String): csize {.importcpp: "print", header: "Print.h".}
proc print*(this: var Print; a2: ptr char): csize {.importcpp: "print", header: "Print.h".}
proc print*(this: var Print; a2: char): csize {.importcpp: "print", header: "Print.h".}
proc print*(this: var Print; a2: cuchar; a3: cint = DEC): csize {.importcpp: "print",
    header: "Print.h".}
proc print*(this: var Print; a2: cint; a3: cint = DEC): csize {.importcpp: "print",
    header: "Print.h".}
proc print*(this: var Print; a2: cuint; a3: cint = DEC): csize {.importcpp: "print",
    header: "Print.h".}
proc print*(this: var Print; a2: clong; a3: cint = DEC): csize {.importcpp: "print",
    header: "Print.h".}
proc print*(this: var Print; a2: culong; a3: cint = DEC): csize {.importcpp: "print",
    header: "Print.h".}
proc print*(this: var Print; a2: cdouble; a3: cint = 2): csize {.importcpp: "print",
    header: "Print.h".}
proc print*(this: var Print; a2: Printable): csize {.importcpp: "print",
    header: "Print.h".}
proc println*(this: var Print; a2: ptr __FlashStringHelper): csize {.
    importcpp: "println", header: "Print.h".}
proc println*(this: var Print; s: String): csize {.importcpp: "println",
    header: "Print.h".}
proc println*(this: var Print; a2: ptr char): csize {.importcpp: "println",
    header: "Print.h".}
proc println*(this: var Print; a2: char): csize {.importcpp: "println", header: "Print.h".}
proc println*(this: var Print; a2: cuchar; a3: cint = DEC): csize {.importcpp: "println",
    header: "Print.h".}
proc println*(this: var Print; a2: cint; a3: cint = DEC): csize {.importcpp: "println",
    header: "Print.h".}
proc println*(this: var Print; a2: cuint; a3: cint = DEC): csize {.importcpp: "println",
    header: "Print.h".}
proc println*(this: var Print; a2: clong; a3: cint = DEC): csize {.importcpp: "println",
    header: "Print.h".}
proc println*(this: var Print; a2: culong; a3: cint = DEC): csize {.importcpp: "println",
    header: "Print.h".}
proc println*(this: var Print; a2: cdouble; a3: cint = 2): csize {.importcpp: "println",
    header: "Print.h".}
proc println*(this: var Print; a2: Printable): csize {.importcpp: "println",
    header: "Print.h".}
proc println*(this: var Print): csize {.importcpp: "println", header: "Print.h".}
proc flush*(this: var Print) {.importcpp: "flush", header: "Print.h".}