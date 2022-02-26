
// Write 'abc' into the memory
mem 0 + 97 .
mem 1 + 98 .
mem 2 + 99 .

3 mem 1 1 syscall3 // Write to stdout

// Add all characters with 1: bcd
mem 0 + mem 0 + , 1 + .
mem 1 + mem 1 + , 1 + .
mem 2 + mem 2 + , 1 + .
  
3 mem 1 1 syscall3 // Write to stdout

0 60 syscall1 // Exit (not actually needed)
