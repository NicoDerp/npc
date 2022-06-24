
macro NULL 0 cast(ptr) end
macro sizeof(ptr) 8 end
macro sizeof(bool) 1 end
macro sizeof(char) 1 end
macro sizeof(uint) 1 end
macro sizeof(uint8) 8 end

macro STDIN  0 end
macro STDOUT 1 end
macro STDERR 2 end

macro st_dev 0 +        end 
macro st_ino 8 +        end 
macro st_mode 24 +      end 
macro st_nlink 16 +     end 
macro st_uid 28 +       end
macro st_gid 32 +       end
macro st_rdev 40 +      end
macro st_size 48 +      end
macro st_blksize 56 +   end
macro st_blocks 64 +    end
macro st_atime 72 +     end
macro st_mtime 88 +     end
macro st_ctime 104 +    end
macro sizeof(fstat) 144 end

macro MAP_FAILED -1 end
macro PROT_READ   1 end
macro MAP_PRIVATE 2 end

proc WTERMSIG int -- int in
  127 band
end

proc WIFEXITED int -- bool in
  127 band 0 =
end

proc WEXITSTATUS int -- int in
  65280 band 8 shr
end

macro true  1 cast(bool) end
macro false 0 cast(bool) end

macro S_IRWXU 448 end // 00700 user (file owner) has read, write, and execute permission
macro S_IRUSR 256 end // 00400 user has read permission
macro S_IWUSR 128 end // 00200 user has write permission
macro S_IXUSR 64  end // 00100 user has execute permission
macro S_IRWXG 56  end // 00070 group has read, write, and execute permission
macro S_IRGRP 32  end // 00040 group has read permission
macro S_IWGRP 16  end // 00020 group has write permission
macro S_IXGRP 8   end // 00010 group has execute permission
macro S_IRWXO 7   end // 00007 others have read, write, and execute permission
macro S_IROTH 4   end // 00004 others have read permission
macro S_IWOTH 2   end // 00002 others have write permission
macro S_IXOTH 1   end // 00001 others have execute permission

macro O_RDONLY 0   end
macro O_WRONLY 1   end
macro O_RDWR   2   end
macro O_CREAT  64  end
macro O_TRUNC  512 end

macro S_USER_RW S_IRUSR S_IWUSR bor end
macro S_USER_RD S_IRUSR end

macro O_RDONLY_USER S_USER_RD O_RDONLY end

macro sizeof(array) 16 sizeof(ptr) * end
memory array 16 sizeof(ptr) * 1 + end
memory array_i 8 end

macro sizeof(Str) 16 end

proc exit int in
  60 syscall1 drop
end

proc write int ptr int -- int in
  1 syscall3
end

proc read int ptr int -- int in
  0 syscall3
end

proc fork -- int in
  57 syscall0
end

proc wait4 ptr int ptr int -- int in
  61 syscall4
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

proc >= int int -- bool in
  2dup >
  rot rot = lor
end

proc <= int int -- bool in
  2dup <
  rot rot = lor
end

proc ,ptr
    ptr
    --
    ptr
  in

  ,64 cast(ptr)
end

proc ,,ptr
    ptr
    --
    ptr
  in

  ,64 cast(ptr) ,64 cast(ptr)
end

proc ,bool
    ptr
    --
    bool
  in

  , cast(bool)
end

proc ?str_empty
    ptr
    --
    bool
  in

  8 + ,64 0 =
end

proc ,Str
    ptr
    --
    int
    ptr
  in

  dup 8 + ,64
  swap ,ptr
end

proc .Str
    ptr // Dst
    int // Count
    ptr // ptr
  in

  memory dst sizeof(ptr) end
  rot dst swap .64

  dst ,ptr swap .64
  dst ,ptr 8 + swap .64
end

proc ,Str.data
    ptr // Str
    --
    ptr // Str.data
  in

  ,ptr
end

proc ,Str.count
    ptr // Str
    --
    int // Str.count
  in

  8 + ,64
end

// n (n<-1) (n>-4095)
proc ?ferr
    int // File descriptor
    --
    bool // Error
  in

  dup -1 <
  over -4095 >
  land swap drop
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

proc f_write
    int // Count
    ptr // Buf
    int // Fd
  in

  1 syscall3 drop
end

//proc f_writec
//    int // Char
//    int // Fd
//  in
//
//  // 1 putc_char fd
//  swap putc_char swap .
//  1 swap putc_char swap
//  f_write
//end

proc f_close
    int // Fd
  in

  3 syscall1 drop
end

proc puts int ptr -- in
  STDOUT write drop
end

proc putc int -- in
  memory char sizeof(char) end
  char swap .
  1 char puts
end

proc putb bool -- in
  0 = if
    "false\n"
  else
    "true\n"
  end puts
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

proc pstreq
    ptr // Str2
    ptr // Str1
    --
    bool // Str1 == Str2
  in

  memory s1 sizeof(ptr) end
  s1 swap .64
  memory s2 sizeof(ptr) end
  s2 swap .64

  s1 ,ptr ,Str.count
  s2 ,ptr ,Str.count
  = if
    s1 ,ptr ,Str.count 1 -
    while
      // If index is greater than or equal to zero
      dup 0 > if
        // If the characters are the same
        // index char
        dup  s1 ,ptr ,Str.data + ,
        over s2 ,ptr ,Str.data + ,
        =
      else
        false
      end
    do
      // Decrement index
      1 -
    end
    // If the last characters are equal they are the same
    // And the index is 0
    // bool
    0 = if
      s1 ,ptr ,Str.data ,
      s2 ,ptr ,Str.data ,
      =
    else
      false
    end
  else
    false
  end
end

proc streq
    int ptr // Str1
    int ptr // Str2
    --
    bool // Str1 == Str2
  in

  memory p1 sizeof(ptr) end
  memory p2 sizeof(ptr) end

  // size
  p1 swap .64
  swap
  p2 swap .64
  over = if
    1 -
    while
      // If index is greater than or equal to zero
      dup 0 >= if
        // If the characters are the same
        p1 ,ptr ,
        p2 ,ptr ,
        =
      else
        false
      end
    do
      // Decrement index
      1 -
      p1 inc64
      p2 inc64
    end
    // If the last characters are equal they are the same
    // And the index is -1
    // bool
    -1 = if
      p1 ,ptr 1 - ,
      p2 ,ptr 1 - ,
      =
    else
      false
    end
  else
    drop false
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

  memory src sizeof(ptr) end
  memory dst sizeof(ptr) end

  dst swap .64
  src swap .64
  
  while dup 0 > do
    dst ,ptr
    src ,ptr , .
    src inc64
    dst inc64
    1 -
  end drop
end

proc memset
     int // Size
     ptr // Dst
     int // Val
  in

  memory dst sizeof(ptr) end
  memory val sizeof(char) end

  val swap .
  dst swap .64

  while dup 0 > do
    dst ,ptr val , .
    dst inc64
    1 -
  end drop
end

proc cstr_to_int
     ptr // Cstr
     --
     int // int(cstr)
     bool // success
  in

  memory str sizeof(ptr) end
  memory out 8 end
  memory success sizeof(bool) end

  str swap .64
  out 0 .64
  success true .

  // strlen 0 digit
  str ,ptr strlen swap drop
  0 while 2dup > do
    dup str ,ptr + ,

    dup '0' <
    over '9' >
    lor if
      // Basically break
      // Since index == strlen
      drop drop dup
      success false .
    else
      '0' -
      out ,64 10 * + out swap .64
      1 +
    end
  end drop drop
  
  out ,64
  success ,bool
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
  in

  memory buf sizeof(ptr) end
  
  buf swap .64
  over swap buf ,ptr memcpy
  buf ,ptr + memcpy
end

proc cputs
    ptr // Cstr
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
    ptr
  in

  8 * argv + ,ptr
end

proc uint_to_cstr
    int
    --
    ptr
  in

  memory buf 32 end
  memory index 1 end

  32 buf 0 memset
  index 30 . // size-2

  // div (buf+*i) char
  while
    10 /% '0' +
    buf index , + swap .
    dup 0 !=
  do
    index dec
  end drop

  buf index , +
end

// ptr -> argv[0] -> '/' // Filename
//                   'u'
//                   's'
//                   'r'
//                   '/'
//                   'b'
//                   'i'
//                   'n'
//                   '/'
//                   'n'
//                   'a'
//                   's'
//                   'm'
//        argv[1] -> ... // Args
//        argv[2] -> ...
//        argv[3] -> ...
//        ...     -> ...

// 0 ptr ptr
proc exec_cmd
    ptr // Array of cstrs as arguments
    --
    int // Error
  in

  0 swap
  dup ,64
  59 syscall3
end

// ptr pid
proc subp_exec_cmd
    ptr // Array of cstrs as arguments
    --
    bool // Error
  in

  memory wstatus sizeof(ptr) end
  memory err sizeof(bool) end

  fork
  dup -1 = if
    err true .
    //"[ERROR] Could not fork for exec_cmd\n" puts 1 exit
  else dup 0 > elif
    // Parent process. Wait for child to finish
    while
      NULL 0 wstatus -1 wait4
      0 < if
        //"[ERROR] Could not wait for process to finish\n" puts
	//1 exit
        err true .
        false
      else
        // int
        wstatus ,64
        dup WIFEXITED if
          dup WEXITSTATUS
          dup 0 != if
            err true .
            //dup exit // Exit with the child's exit code if fail
          end
          drop // Drop exit-code
          false // Break
        else // Check stopped and continue??
          true
        end swap drop // Drop *wstatus
      end
    do end
      
  else dup 0 = elif
    // Child process
    over exec_cmd
    0 < if
      1 exit
      //"Failed to execute command\n" puts 1 exit
    end
  end drop drop
  err ,bool
end

proc array_push
    ptr // Cstr
  in

  array array_i ,64 sizeof(ptr) * +
  swap .64
  array_i inc64
end

proc array_clean in
  sizeof(array) array 0 memset
  array_i 0 .64
end

// (array+i*size(ptr))
proc array_pop
    --
    int // Out
  in

  array_i ,64 0 = if
    "Pop from empty list!\n" puts 1 exit
  end
  
  array_i dec64
  array array_i ,64 sizeof(ptr) * +
  ,64
end

proc array_top
    --
    ptr // Out
  in

  array array_i ,64 1 - sizeof(ptr) * +
end

proc ?array_empty -- bool in
  array_i ,64 0 =
end

proc lnot bool -- bool in
  false =
end

proc rmfile
    ptr // Cstr filename
    --
    int // Error
  in

  87 syscall1
end

proc char_in_cstr
    ptr // Str
    int // Char
    --
    bool
  in

  memory out sizeof(bool) end

  // ptr char
  while
    over ,
    dup 0 != if
      over = if out true . end
      true
    else
      drop false
    end
  do
    swap 1 + swap
  end drop drop
  out ,bool
end

proc cstr_leftmost_char
    ptr // Cstr
    --
    ptr // Cstr
    int // Char
  in

  dup ,
end

proc cstr_rightmost_char
    ptr // Cstr
    --
    ptr // Cstr
    int // Char
  in

  // ptr int
  dup strlen 1 - + ,
end

proc ?cstr_empty
    ptr // Cstr
    --
    bool // Empty
  in

  , 0 =
end

proc cstr_chop_left
    ptr // Cstr
    --
    ptr // Cstr
    int // Char
  in

  // ptr char
  dup ,
  swap 1 + swap
end

proc cstr_chop_right
    ptr // Cstr
    --
    ptr // Cstr
    int // Char
  in

  strlen 1 -
  over +
  dup ,
  swap 0 .
end

proc cstr_starts_with
    ptr // Cstr
    int // Char
    --
    bool // Out
  in

  swap , =
end

proc lflip ptr in
  dup ,bool lnot .
end

proc cstr_trim_left
    ptr // Cstr
    --
    ptr // Cstr
  in

  // ptr c bool
  while
    dup ,
    dup ' ' =
    swap '\n' =
    lor if
      true
    else
      false
    end
  do 1 + end
end

proc cstr_cut_to_delimiter
    ptr // Cstr
    int // Delimiter
    ptr // The cut
  in

  memory buf sizeof(ptr) end
  buf swap .64

  while
   over ,
   2dup = if
     drop false
   else
     buf ,ptr swap .
     buf inc64
     true
   end
  do
    swap 1 + swap
  end drop drop
end

proc str_split_at_delimiter
    ptr // The cut
    int // Delimiter
    ptr // Str
  in

  memory out sizeof(ptr) end
  memory empty sizeof(bool) end
  empty false .
  
  rot out swap .64 // Set out buffer
  out ,ptr 8 + 0 .64 // Set out.counter to 0

  swap

  over ,Str.data out ,ptr swap .64 // Set out.data to in.data
  while
    // (data|count) del bool
    over ,Str.count 0 = if
      empty true .
      false
    else
      over ,Str.data , // *in.data
      over =
      if
        false
      else
        out ,ptr 8 + inc64 // Increment out.counter
        over dup inc64 // Increment in.ptr
        8 + dec64 // Decrement in.count
        true
      end
    end
  do end drop // Delimiter
  empty ,bool lnot if
    // Remove first character
    dup inc64 // Increment in.ptr
    8 + dec64 // Decrement in.count
  else
    drop
  end
end

proc str_chop_left
    ptr // Str
    --
    int // Char
  in

  // char ptr
  dup ,Str.data ,
  swap dup inc64
  8 + dec64
end

proc str_chop_right
    ptr // Str
    --
    int // Char
  in

  // ptr char
  dup ,Str.count 1 -
  over ,Str.data + ,
  swap 8 + dec64
end

proc str_trim_left
    ptr // Str
  in

  memory s sizeof(ptr) end
  s swap .64

  // (data|count)
  while
    s ,ptr ,Str.count 0 != if
      s ,ptr ,Str.data ,
      dup ' ' =
      swap '\n' =
      lor if
        true
      else
        false
      end
    else
      false
    end
  do s ,ptr str_chop_left drop end
end

proc str_to_int
     ptr // Str
     --
     int // int(str)
     bool // success
  in

  memory str sizeof(ptr) end
  memory out 8 end
  memory success sizeof(bool) end

  str swap .64
  out 0 .64
  success true .

  // strlen 0 digit
  str ,ptr ,Str.count
  0 while 2dup > do
    dup str ,ptr ,Str.data + ,

    dup '0' <
    over '9' >
    lor if
      // Basically break
      // Since index == strlen
      drop drop dup
      success false .
    else
      '0' -
      out ,64 10 * + out swap .64
      1 +
    end
  end drop drop
  
  out ,64
  success ,bool
end

proc str_leftmost_char
    ptr // Str
    --
    int // Char
  in

  ,Str.data ,
end

proc str_rightmost_char
    ptr // Str
    --
    int // Char
  in

  ,Str swap 1 - + ,
end

