include "std.polar"


macro sizeof(buf) 1023 end

memory fd 8 end
memory buf sizeof(buf) 1 + end


// Open file
O_READONLY_OWNER "./files.polar\0" str-to-cstr f_open

// Save file descriptor
fd swap .64

// If -4095 < fd < -1 it's an error
fd ,64 -1 <
fd ,64 -4095 >
land
if
  "[ERROR] failed to open file\n" puts
else
  // Read
  sizeof(buf) buf fd , f_read
  
  // Close
  fd , f_close

  // Print contents of buffer
  buf cstr-to-str puts
end

