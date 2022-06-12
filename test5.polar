
include "std.polar"

memory fd 8 end
memory stat sizeof(fstat) end

// Open file
O_READONLY_OWNER "test5.polar"c f_open

// Check if file opening failed
fd swap .64
fd ,64 0 < if
  "Failed to open file\n" puts
  -1 exit
end

// Get fstat and check status
stat fd ,64 5 syscall2
0 < if
  "Failed to open file\n" puts
  -1 exit
end

"File descriptor: " puts fd ,64 dump
"File size: " puts stat st_size ,64 dump

// Memory map file
0 fd ,64 MAP_PRIVATE PROT_READ stat st_size , 0 9 syscall6
dup MAP_FAILED = if
  "Failed to memory map file\n" puts
  -1 exit
end

cast(ptr) cputs

// Close file
//fd ,64 f_close

//memory buf 256 end
//5 buf STDIN read dump
//buf cputs

