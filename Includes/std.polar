
macro STDIO 1 end

macro write 1 syscall3 end
macro exit  60   syscall1 end

macro true  1 cast(bool) end
macro false 0 cast(bool) end

memory memcpy_src 8 end
memory memcpy_dst 8 end
memory memcpy_size 8 end

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

// count ptr num
macro format
  rot rot
  puts dump
end

// size src dst
macro memcpy
  memcpy_dst swap .64
  memcpy_src swap .64
  memcpy_size swap .64

  // i (i+*mem_dst) *(i+*src)
  0 while dup memcpy_size ,64 < do
    dup memcpy_dst ,64 + cast(ptr)
    over memcpy_src ,64 + cast(ptr) ,
    .
    1 +
    //memcpy_size ,64 dump
  end drop
end


