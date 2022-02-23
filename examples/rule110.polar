// [                           ]   '\n'   ' '   '*'
//            0 - 99               103    104   105

fun main in
  // Write '\n' to mem
  mem 100 + 10 .

  // Write ' ' to mem
  mem 101 + 32 .

  // Write '*' to mem
  mem 102 + 42 .

  // Start with a single dot
  mem 98 + 1 .

  0 while dup 98 < do
    0 while dup 100 < do
      dup mem + , if
        // Write '*' to stdout
        1 mem 102 + 1 1 syscall3
      else
        // Write ' ' to stdout
        1 mem 101 + 1 1 syscall3
      end
      1 +
    end drop

    // '\n'
    1 mem 100 +
    1 1 syscall3

    // (*mem << 1) | (*(mem + 1))
    // pattern
    mem , 1 shl mem 1 + , bor
    // (pattern stuff) j (mem + j) (110 >> (((pattern << 1) & 7) | *(mem + j + 1)))
    1 while dup 98 < do
      swap
      1 shl 7 band
      swap over mem + 1 + , bor
      over
      swap over mem + swap
      110 swap shr 1 band .
      1 +
    end drop drop
    1 +
  end drop
end
