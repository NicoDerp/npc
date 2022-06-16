include "std.polar"

//125 uint_to_cstr cputs

macro sizeof(ptr) 8 end
macro sizeof(array) 8 sizeof(ptr) * end
memory array sizeof(array) end
memory array_i 8 end

// ptr (array+i*8)
proc array_append
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

"/usr/bin/nasm"c   array_append
//"test.polar"c array_append
//"bip bop"c array_append

array exec_cmd dup dump
EXEC_FAILED = if
  "Failed to execute file\n" puts
  -1 exit
end

