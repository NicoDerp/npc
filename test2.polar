
include "std.polar"


macro sizeof(buf) 1023 end

memory fd 8 end
memory buf sizeof(buf) 1 + end


// Open file
// mode flags filename 2 syscall3
//O_PERMISSIONS O_READONLY "./test2.polar\0" str-to-cstr 2 syscall3

O_READONLY_OWNER "./tet2.polar\0" str-to-cstr f_open

// Save file descriptor
fd swap .64

fd ,64 -1 <
fd ,64 -4095 >
land
if
  "[ERROR] failed to open file\n" puts
else
  // Read
  // count buf fd 0 syscall3
  //1024 buf fd , 0 syscall3 drop
  sizeof(buf) buf fd , f_read
  
  // Close
  // fd 3 syscall1
  // fd , 3 syscall1
  fd , f_close
  
  
  // count buf 1 1 syscall3
  buf cstr-to-str puts
end

