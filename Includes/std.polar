
macro STDIO 1 end

macro write 1 syscall3 end
macro exit  60   syscall1 end

macro true  1 cast(bool) end
macro false 0 cast(bool) end

macro puts
  STDIO write
end

// ptr i
macro strlen
  0 while 2dup + , 0 > do
    1 +
  end
  // swap
  // drop
end

// ptr
macro cstr-to-str
  strlen swap
end

// ptr2 ptr1
macro cstreq
  while
    2dup , 0 != cast(int) swap , 0 != cast(int) band cast(bool)
    if
      // Both of the characters aren't zero
      // Checks if they are equal
      2dup , swap , =
      dup
    else
      // Both of the characters are zero
      false
    end
  do
    // Move ptr1 and ptr2 one byte up
    1 + swap 1 + swap
  end

  // If they both are zero they are the same
  , swap , land
end
