
macro STDIO 1 end

macro true  1 cast(bool) end
macro false 0 cast(bool) end
macro O_READONLY_OWNER 400 0 end

memory memcpy_src 8 end
memory memcpy_dst 8 end
memory memcpy_size 8 end

memory putc_char 1 end

proc exit int in
  60 syscall1
end

proc write int ptr int -- int in
  1 syscall3
end

proc inc ptr in
  dup , 1 + .
end

proc dec ptr in
  dup , 1 - .
end

proc inc64 ptr in
  dup ,64 1 + .64
end

proc dec64 ptr in
  dup ,64 1 - .64
end

proc f_open
    int // Permissions
    int // Flags
    ptr // String
    --
    int // Fd / error-code
  in

  2 syscall3
end

proc f_read
    int // Count
    ptr // Buf
    int // Fd
    --
  in
  
  0 syscall3 drop
end

proc f_close
    int // Fd
  in

  3 syscall1 //drop
end

proc puts int ptr -- in
  STDIO write drop
end

proc putc int -- in
  putc_char swap .
  1 putc_char puts
end

// ptr i
proc strlen ptr -- ptr int in
  0 while 2dup + , 0 > do
    1 +
  end
  // swap
  // drop
end

// ptr
proc cstr_to_str ptr -- int ptr in
  strlen swap
end

proc str_to_cstr int ptr -- ptr in
  swap drop
end

// ptr2 ptr1
proc cstreq ptr ptr -- bool in
  while
    2dup , 0 != swap , 0 != land
    if
      // Both of the characters aren't zero
      // Checks if they are equal
      2dup , swap , =
      //dup
    else
      // Both of the characters are zero
      false
    end
  do
    // Move ptr1 and ptr2 one byte up
    1 + swap 1 + swap
  end

  // If they both are zero they are the same
  , swap , land 1 -
end

// count ptr num
proc format int ptr int in
  rot rot
  puts dump
end

// size src dst
proc memcpy
    int // Size
    ptr // Src
    ptr // Dst
  in
  
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


