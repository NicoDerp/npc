// [                    ] [                    ]
//        0 - 99                100 - 200

macro width 300 end

macro rule110
  // Write '\n' to mem 200
  mem width width + + '\n' .
  
  // Start with a single dot
  mem width 2 - + 1 .
  
  0 while dup width 2 - < do
    0 while dup width < do
      dup mem + , 1 = if
        dup mem + width + '*' .
        // Write '*' to stdout
        //1 mem 102 + 1 1 syscall3
      else
        dup mem + width + ' ' .
        // Write ' ' to stdout
        //1 mem 101 + 1 1 syscall3
      end
      1 +
    end drop
  
    // Write all characters to stdout, the last is '\n'
    width 1 + mem width +
    1 1 syscall3
  
    // (*mem << 1) | (*(mem + 1))
    // pattern
    mem , 1 shl mem 1 + , bor
    // (pattern stuff) j (mem + j) (110 >> (((pattern << 1) & 7) | *(mem + j + 1)))
    1 while dup width 2 - < do
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

rule110
