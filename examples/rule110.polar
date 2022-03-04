// [                    ] [                    ]
//        0 - 99                100 - 200

//fun main in
  // Write '\n' to mem 200
  mem 200 + '\n' .

  // Start with a single dot
  mem 98 + 1 .

  0 while dup 98 < do
    0 while dup 100 < do
      dup mem + , 1 = if
        dup mem + 100 + '*' .
        // Write '*' to stdout
        //1 mem 102 + 1 1 syscall3
      else
        dup mem + 100 + ' ' .
        // Write ' ' to stdout
        //1 mem 101 + 1 1 syscall3
      end
      1 +
    end drop

    // Write all characters to stdout, the last is '\n'
    101 mem 100 +
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
//end
