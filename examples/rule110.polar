// [                    ] [                    ]
//        0 - 99                100 - 200

macro width 500 end

memory nums width end
memory chars width end

macro rule110
  // Write '\n' to mem 200
  chars width + '\n' .
  
  // Start with a single dot
  nums width + 2 - 1 .
  
  0 while dup width 2 - < do
    0 while dup width < do
      dup nums + , cast(bool) if
        dup chars + '*' .
      else
        dup chars + ' ' .
      end
      1 +
    end drop

    // Write all characters to stdout, the last is '\n'
    // count   ptr
    width 1 + chars
    1 1 syscall3

    // (*mem << 1) | (*(mem + 1))
    // pattern
    nums , 1 shl nums 1 + , bor
    // (pattern stuff) j (mem + j) (110 >> (((pattern << 1) & 7) | *(mem + j + 1)))

    // j (pattern-stuff) (nums+j)
    1 while dup width 2 - < do
      swap
      1 shl 7 band
      over nums + 1 + , bor
      over nums +
      over 110 swap shr 1 band .
      swap 1 +
    end drop drop
    1 +
  end drop
end

rule110

