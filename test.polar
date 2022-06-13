include "std.polar"

memory fd 8 end

// Mode (user read, write)
36

// Flags (write, truncate and create)
O_WRONLY O_CREAT O_TRUNC bor bor

// Filename
"new_file.s"c

// Open
f_open

fd swap .64

fd ,64 0 < if
  "Failed to open file\n" puts -1 exit
end

"Hello World!\n" fd ,64 f_write

fd ,64 f_close

