
macro STDIO 1 end

macro true  1 cast(bool) end
macro false 0 cast(bool) end
macro O_READONLY_OWNER 400 0 end

memory memcpy_src 8 end
memory memcpy_dst 8 end
memory memcpy_size 8 end

memory memset_size 8 end
memory memset_dst 8 end
memory memset_val 1 end

memory putc_char 1 end

memory cstr_to_int_out 8 end
memory cstr_to_int_str 8 end
memory cstr_to_int_suc 1 end

memory str_conc_buf 8 end

memory streq_ptr 8 end

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

proc cstreq
    ptr // Str1
    ptr // Str2
    --
    bool // Str1 == Str2
  in
  
  while
    // Check if both of the characters aren't zero
    2dup , 0 != swap , 0 != land
    if
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
  , 0 = swap , 0 = land
end

proc streq
    int ptr // Str1
    int ptr // Str2
    --
    bool // Str1 == Str2
  in

  // ptr int int
  streq_ptr swap .64
  rot
  2dup = if
    // Same length start checking chars
    drop
    // ptr int
    1 -
    while
      // If index is greater than zero
      dup 0 > if
        // If the characters are the same
        2dup + ,
        over streq_ptr ,64 cast(ptr) + ,
        =
      else
        false
      end
    do
      // Decrement index
      1 -
    end
    swap drop
    // If the index is zero it means they are equal
    0 =
  else
    drop drop drop false
  end
end

proc format ptr int ptr in
  puts dump
end

proc memcpy
    int // Size
    ptr // Src
    ptr // Dst
  in
  
  memcpy_dst swap .64
  memcpy_src swap .64
  memcpy_size swap .64

  //memcpy_src "Src: " format
  //memcpy_src ,64 "*Src: " format "\n" puts

  // i i *dst
  0 while dup memcpy_size ,64 < do
    //memcpy_dst ,64 "*Dst: " format
    dup memcpy_dst ,64 + cast(ptr)
    over memcpy_src ,64 + cast(ptr) ,
    //drop drop
    .
    1 +
  end drop
end

proc memset
     int // Size
     ptr // Dst
     int // Val
   in

  memset_val swap .
  memset_dst swap .64
  memset_size swap .64

  0 while dup memset_size ,64 < do
    dup memset_dst ,64 cast(ptr) + memset_val , .
    1 +
  end drop
end

proc cstr_to_int
     ptr // Cstr
     --
     int // int(cstr)
     bool // succeed
  in

  cstr_to_int_str swap .64
  cstr_to_int_out 0 .64
  cstr_to_int_suc 1 .

  // strlen 0 digit
  cstr_to_int_str ,64 strlen swap drop
  0 while 2dup > do
    dup cstr_to_int_str ,64 + cast(ptr) ,

    dup '0' <
    over '9' >
    lor if
      // Basically break
      // Since index == strlen
      drop drop dup
      cstr_to_int_suc 0 .
    else
      '0' -
      cstr_to_int_out ,64 10 * + cstr_to_int_out swap .64
      1 +
    end
  end drop drop
  
  cstr_to_int_out ,64
  cstr_to_int_suc , cast(bool)
end

proc power
    int // a
    int // b
    --
    int // a^b
  in

  over swap
  
  while dup 1 > do
    rot rot
    swap over *
    swap rot
    1 -
  end
  drop drop
end

proc str_conc
    int // Str1-size
    ptr // Str1-ptr
    int // Str2-size
    ptr // Str2-size
    ptr // Buffer
    --
  in

  str_conc_buf swap .64
  over swap str_conc_buf ,64 memcpy
  str_conc_buf ,64 + memcpy
end

proc cputs
    ptr // Cstr
    --
  in

  cstr_to_str puts
end

proc ?wspace
    int // Char
    --
    bool // Whitespace (0, '\n', ' ')
  in

  dup ' ' =
  over '\n' = lor
  over 0 = lor
  swap drop
end

proc nth_argv
    int // n
    --
    int
  in

  8 * argv + ,64
end

