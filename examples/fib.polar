
memory a 8 end
memory b 8 end

b 1 .64

// i (*a+*b)
0 while dup 10 < do
  a ,64 b ,64 +
  a b ,64 .64
  b swap .64
  a ,64 dump
  b ,64 dump
  "--\n" 1 1 syscall3
  1 +
end drop

