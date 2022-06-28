
include "test.polar"

"Hei\n\n" 1 1 syscall3
"Bip bop\n" 1 1 syscall3

20 0 while 2dup > do
  dup dump
  1 +
end

