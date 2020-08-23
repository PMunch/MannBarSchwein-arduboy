import macros, strutils

import nimfiles / Sprites

type
  SpriteMode* = enum
    SpriteMasked = 1,
    SpriteUnmasked = 2,
    SpritePlusMask = 3,
    SpriteIsMask = 250,
    SpriteIsMaskErase = 251
  Sprite[count, w, h: static[int]] = distinct array[count, uint8]
  NoMaskType* = enum NoMask

template replace(stmt, x, y: untyped): untyped =
  let v = stmt
  if v == x: y
  else: v

template loadSprite*(name, file: untyped, addSize: static[bool] = false): untyped =
  sprite(name, loadBMP(file), addSize, false)

proc `$`*(x: byte): string = $x.int

macro sprite*(name: untyped, x: static[string], addSize: static[bool] = true, trim: static[bool] = true): untyped =
  echo x
  var
    cols = -1
    rows = 0
    first = if trim: int.high else: 0
    last = -1
    lines = x.splitLines
    start = true
    trailing = 0
    heading = 0
  for line in lines:
    if line.contains('#') or not start or not trim:
      start = false
      rows += 1
    else:
      heading += 1
    cols = max(cols, line.len)
    first = min(first, line.find('#').replace(-1, int.high))
    last = max(last, (if trim: line.len else: line.rfind('#')))
    if line.contains('#') or not trim:
      trailing = 0
    else:
      trailing += 1
  rows -= trailing
  var
    i = 0
    line = lines[i]
    bytes = if addSize: @[byte(cols-first), byte(rows)] else: @[]
    allBits: seq[bool]
  while not line.contains('#') and not trim:
    inc i
    line = lines[i]
  for r in 0..((rows-1) div 8):
    for c in 0..<(cols-first):
      var data: byte
      for i in (r * 8)..<min(r * 8 + 8, rows):
        if lines[heading + i].len > first + c and lines[heading + i][first + c] == '#':
          data = data or (1.byte shl (i - r * 8))
          allbits.add true
        else:
          allbits.add false
      bytes.add data
  var spriteData = nnkBracket.newTree()
  for i, num in bytes:
    spriteData.add newLit(num)
  let spriteLen = spriteData.len
  result = quote do:
    let `name` {.codegenDecl: "const $# PROGMEM $#".} = Sprite[`spriteLen`, `cols`, `rows`](`spriteData`)
  echo result.repr
  var hexArray = "["
  for b in bytes:
    hexArray &= "0x" & b.int.toHex(2) & ", "
  hexArray &= "]"
  echo hexArray
  echo allBits
  var
    blacks = 0
    whites = 0
    total = 0
    compressed: seq[byte]
  when true:
    while total < allBits.high:
      while allBits[total] == false and blacks < 0b1111 and total < allBits.high:
        blacks += 1
        total += 1
      while allBits[total] == true and whites < 0b1111 and total < allBits.high:
        whites += 1
        total += 1
      compressed.add ((blacks shl 4) or whites).byte
      blacks = 0
      whites = 0
  else:
    while total < allBits.high:
      var
        isWhite = allBits[total]
        count = 0
        cbyte = 0
      while allBits[total] == false and count < 0b111 and total < allBits.high:
        count += 1
        total += 1
      cbyte = (if isWhite: 1 else: 0) shl 7 or (count shl 4)
      count = 0
      isWhite = allBits[total]
      while allBits[total] == true and count < 0b111 and total < allBits.high:
        count += 1
        total += 1
      cbyte = cbyte or ((if isWhite: 1 else: 0) shl 3 or count)
      compressed.add cbyte.byte
      blacks = 0
      whites = 0
  echo compressed
  echo allbits.len
  echo compressed.len

#proc drawBitmapImpl_Orig(x, y: int16, bitmap, mask: ptr uint8, w, h, rw, rh: uint8, draw_mode: SpriteMode) =
#  {.emit: """
#  // no need to draw at all of we're offscreen
#  if (x + rw <= 0 || x > WIDTH - 1 || y + rh <= 0 || y > HEIGHT - 1)
#    return;
#
#  if (bitmap == NULL)
#    return;
#
#  // xOffset technically doesn't need to be 16 bit but the math operations
#  // are measurably faster if it is
#  uint16_t xOffset, ofs;
#  int8_t yOffset = y & 7;
#  int8_t sRow = y / 8;
#  uint8_t loop_h, start_h, rendered_width;
#
#  if (y < 0 && yOffset > 0) {
#    sRow--;
#  }
#
#  // if the left side of the render is offscreen skip those loops
#  if (x < 0) {
#    xOffset = abs(x);
#  } else {
#    xOffset = 0;
#  }
#
#  // if the right side of the render is offscreen skip those loops
#  if (x + rw > WIDTH - 1) {
#    rendered_width = ((WIDTH - x) - xOffset);
#  } else {
#    rendered_width = (rw - xOffset);
#  }
#
#  // if the top side of the render is offscreen skip those loops
#  if (sRow < -1) {
#    start_h = abs(sRow) - 1;
#  } else {
#    start_h = 0;
#  }
#
#  loop_h = rh / 8 + (rh % 8 > 0 ? 1 : 0); // divide, then round up
#
#  // if (sRow + loop_h - 1 > (HEIGHT/8)-1)
#  if (sRow + loop_h > (HEIGHT / 8)) {
#    loop_h = (HEIGHT / 8) - sRow;
#  }
#
#  // prepare variables for loops later so we can compare with 0
#  // instead of comparing two variables
#  loop_h -= start_h;
#
#  sRow += start_h;
#  ofs = (sRow * WIDTH) + x + xOffset;
#  uint8_t *bofs = (uint8_t *)bitmap + (start_h * w) + xOffset;
#  uint8_t data;
#
#  uint8_t mul_amt = 1 << yOffset;
#  uint16_t mask_data;
#  uint16_t bitmap_data;
#
#  switch (draw_mode) {
#    case SPRITE_UNMASKED:
#      // really if yOffset = 0 you have a faster case here that could be
#      // optimized
#      for (uint8_t a = 0; a < loop_h; a++) {
#        // if h % 8 != 0 we need to use a different mask for the last string of
#        // bytes in order to not mask more than the sprite.
#        if (a == loop_h - 1) {
#          mask_data = ~(((1 << (rh % 8)) - 1) * mul_amt);
#        } else {
#          mask_data = ~(0xFF * mul_amt);
#        }
#        for (uint8_t iCol = 0; iCol < rendered_width; iCol++) {
#          bitmap_data = pgm_read_byte(bofs) * mul_amt;
#
#          if (sRow >= 0) {
#            data = sBuffer[ofs];
#            data &= (uint8_t)(mask_data);
#            data |= (uint8_t)(bitmap_data & ~mask_data);
#            sBuffer[ofs] = data;
#          }
#          if (yOffset != 0 && sRow < 7) {
#            data = sBuffer[ofs + WIDTH];
#            data &= (*((unsigned char *) (&mask_data) + 1));
#            data |= (*((unsigned char *) (&bitmap_data) + 1));
#            sBuffer[ofs + WIDTH] = data;
#          }
#          ofs++;
#          bofs++;
#        }
#        sRow++;
#        bofs += w - rendered_width;
#        ofs += WIDTH - rendered_width;
#      }
#      break;
#
#    case SPRITE_IS_MASK:
#      for (uint8_t a = 0; a < loop_h; a++) {
#        if (a == loop_h - 1) {
#          mask_data = ~(((1 << (rh % 8)) - 1) * mul_amt);
#        } else {
#          mask_data = ~(0xFF * mul_amt);
#        }
#        for (uint8_t iCol = 0; iCol < rendered_width; iCol++) {
#          bitmap_data = (pgm_read_byte(bofs) * mul_amt) & ~mask_data;
#          if (sRow >= 0) {
#            sBuffer[ofs] |= (uint8_t)(bitmap_data);
#          }
#          if (yOffset != 0 && sRow < 7) {
#            sBuffer[ofs + WIDTH] |= (*((unsigned char *) (&bitmap_data) + 1));
#          }
#          ofs++;
#          bofs++;
#        }
#        sRow++;
#        bofs += w - rendered_width;
#        ofs += WIDTH - rendered_width;
#      }
#      break;
#
#    case SPRITE_IS_MASK_ERASE:
#      for (uint8_t a = 0; a < loop_h; a++) {
#        if (a == loop_h - 1) {
#          mask_data = ~(((1 << (rh % 8)) - 1) * mul_amt);
#        } else {
#          mask_data = ~(0xFF * mul_amt);
#        }
#        for (uint8_t iCol = 0; iCol < rendered_width; iCol++) {
#          bitmap_data = (pgm_read_byte(bofs) * mul_amt) & ~mask_data;
#          if (sRow >= 0) {
#            sBuffer[ofs]  &= ~(uint8_t)(bitmap_data);
#          }
#          if (yOffset != 0 && sRow < 7) {
#            sBuffer[ofs + WIDTH] &= ~(*((unsigned char *) (&bitmap_data) + 1));
#          }
#          ofs++;
#          bofs++;
#        }
#        sRow++;
#        bofs += w - rendered_width;
#        ofs += WIDTH - rendered_width;
#      }
#      break;
#
#    case SPRITE_MASKED:
#      uint8_t *mask_ofs;
#      mask_ofs = (uint8_t *)mask + (start_h * w) + xOffset;
#      for (uint8_t a = 0; a < loop_h; a++) {
#        for (uint8_t iCol = 0; iCol < rendered_width; iCol++) {
#          // NOTE: you might think in the yOffset==0 case that this results
#          // in more effort, but in all my testing the compiler was forcing
#          // 16-bit math to happen here anyways, so this isn't actually
#          // compiling to more code than it otherwise would. If the offset
#          // is 0 the high part of the word will just never be used.
#
#          // load data and bit shift
#          // mask needs to be bit flipped
#          // if h % 8 != 0 we need to use a different mask for the last string of
#          // bytes in order to not mask more than the sprite.
#          if (a == loop_h - 1) {
#            mask_data = ~((pgm_read_byte(mask_ofs) & ((1 << (rh % 8)) - 1)) * mul_amt);
#          } else {
#            mask_data = ~(pgm_read_byte(mask_ofs) * mul_amt);
#          }
#          bitmap_data = pgm_read_byte(bofs) * mul_amt;
#
#          if (sRow >= 0) {
#            data = sBuffer[ofs];
#            data &= (uint8_t)(mask_data);
#            data |= (uint8_t)(bitmap_data & ~mask_data);
#            sBuffer[ofs] = data;
#          }
#          if (yOffset != 0 && sRow < 7) {
#            data = sBuffer[ofs + WIDTH];
#            data &= (*((unsigned char *) (&mask_data) + 1));
#            data |= (*((unsigned char *) (&bitmap_data) + 1));
#            sBuffer[ofs + WIDTH] = data;
#          }
#          ofs++;
#          mask_ofs++;
#          bofs++;
#        }
#        sRow++;
#        bofs += w - rendered_width;
#        mask_ofs += w - rendered_width;
#        ofs += WIDTH - rendered_width;
#      }
#      break;
#
#
#    case SPRITE_PLUS_MASK:
#      // *2 because we use double the bits (mask + bitmap)
#      bofs = (uint8_t *)(bitmap + ((start_h * w) + xOffset) * 2);
#
#      uint8_t xi = rendered_width; // counter for x loop below
#
#      asm volatile(
#        "push r28\n" // save Y
#        "push r29\n"
#        "movw r28, %[buffer_ofs]\n" // Y = buffer_ofs_2
#        "adiw r28, 63\n" // buffer_ofs_2 = buffer_ofs + 128
#        "adiw r28, 63\n"
#        "adiw r28, 2\n"
#        "loop_y:\n"
#        "loop_x:\n"
#        // load bitmap and mask data
#        "lpm %A[bitmap_data], Z+\n"
#        "lpm %A[mask_data], Z+\n"
#
#        // shift mask and buffer data
#        "tst %[yOffset]\n"
#        "breq skip_shifting\n"
#        "mul %A[bitmap_data], %[mul_amt]\n"
#        "movw %[bitmap_data], r0\n"
#        "mul %A[mask_data], %[mul_amt]\n"
#        "movw %[mask_data], r0\n"
#
#        // SECOND PAGE
#        // if yOffset != 0 && sRow < 7
#        "cpi %[sRow], 7\n"
#        "brge end_second_page\n"
#        // then
#        "ld %[data], Y\n"
#        "com %B[mask_data]\n" // invert high byte of mask
#        "and %[data], %B[mask_data]\n"
#        "or %[data], %B[bitmap_data]\n"
#        // update buffer, increment
#        "st Y+, %[data]\n"
#
#        "end_second_page:\n"
#        "skip_shifting:\n"
#
#        // FIRST PAGE
#        // if sRow >= 0
#        "tst %[sRow]\n"
#        "brmi skip_first_page\n"
#        "ld %[data], %a[buffer_ofs]\n"
#        // then
#        "com %A[mask_data]\n"
#        "and %[data], %A[mask_data]\n"
#        "or %[data], %A[bitmap_data]\n"
#        // update buffer, increment
#        "st %a[buffer_ofs]+, %[data]\n"
#        "jmp end_first_page\n"
#
#        "skip_first_page:\n"
#        // since no ST Z+ when skipped we need to do this manually
#        "adiw %[buffer_ofs], 1\n"
#
#        "end_first_page:\n"
#
#        "dec %[xi]\n"
#        "brne loop_x\n"
#
#        // increment y
#        "next_loop_y:\n"
#        "dec %[yi]\n"
#        "breq finished\n"
#        "mov %[xi], %[x_count]\n" // reset x counter
#        // sRow++;
#        "inc %[sRow]\n"
#        "clr __zero_reg__\n"
#        // sprite_ofs += (w - rendered_width) * 2;
#        "add %A[sprite_ofs], %A[sprite_ofs_jump]\n"
#        "adc %B[sprite_ofs], __zero_reg__\n"
#        // buffer_ofs += WIDTH - rendered_width;
#        "add %A[buffer_ofs], %A[buffer_ofs_jump]\n"
#        "adc %B[buffer_ofs], __zero_reg__\n"
#        // buffer_ofs_page_2 += WIDTH - rendered_width;
#        "add r28, %A[buffer_ofs_jump]\n"
#        "adc r29, __zero_reg__\n"
#
#        "rjmp loop_y\n"
#        "finished:\n"
#        // put the Y register back in place
#        "pop r29\n"
#        "pop r28\n"
#        "clr __zero_reg__\n" // just in case
#        : [xi] "+&a" (xi),
#        [yi] "+&a" (loop_h),
#        [sRow] "+&a" (sRow), // CPI requires an upper register (r16-r23)
#        [data] "=&l" (data),
#        [mask_data] "=&l" (mask_data),
#        [bitmap_data] "=&l" (bitmap_data)
#        :
#        [screen_width] "M" (WIDTH),
#        [x_count] "l" (rendered_width), // lower register
#        [sprite_ofs] "z" (bofs),
#        [buffer_ofs] "x" (sBuffer+ofs),
#        [buffer_ofs_jump] "a" (WIDTH-rendered_width), // upper reg (r16-r23)
#        [sprite_ofs_jump] "a" ((w-rendered_width)*2), // upper reg (r16-r23)
#
#        // [sprite_ofs_jump] "r" (0),
#        [yOffset] "l" (yOffset), // lower register
#        [mul_amt] "l" (mul_amt) // lower register
#        // NOTE: We also clobber r28 and r29 (y) but sometimes the compiler
#        // won't allow us, so in order to make this work we don't tell it
#        // that we clobber them. Instead, we push/pop to preserve them.
#        // Then we need to guarantee that the the compiler doesn't put one of
#        // our own variables into r28/r29.
#        // We do that by specifying all the inputs and outputs use either
#        // lower registers (l) or simple (r16-r23) upper registers (a).
#        : // pushes/clobbers/pops r28 and r29 (y)
#      );
#      break;
#  }""".}

template drawBitmap*[count, w, h: static[int]](x, y: int16, bitmap, mask: Sprite[count, w, h] | NoMaskType, draw_mode: SpriteMode) =
  when defined(newimpl):
    when mask is NoMaskType:
      drawBitmapImpl(x, y, cast[ptr uint8](bitmap.unsafeAddr), nil, w, h, rw ,rh, draw_mode)
    else:
      drawBitmapImpl(x, y, cast[ptr uint8](bitmap.unsafeAddr), cast[ptr uint8](mask.unsafeAddr), w, h, rw, rh, draw_mode)
  else:
    when mask is NoMaskType:
      drawBitmap(x, y, cast[ptr uint8](bitmap.unsafeAddr), nil, w, h, draw_mode.uint8)
    else:
      drawBitmap(x, y, cast[ptr uint8](bitmap.unsafeAddr), cast[ptr uint8](mask.unsafeAddr), w, h, draw_mode.uint8)

template drawBitmap*[count, w, h: static[int]](x, y: int16, bitmap: Sprite[count, w, h]) =
  drawBitmap(x, y, bitmap, NoMask, SpriteUnMasked)
