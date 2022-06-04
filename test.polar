include "std.polar"

//macro puts 1 1 syscall3 end

memory argv 8 end
memory argc 1 end

//drop

argc swap .

memory i 1 end

while i , argc , < do
  0 while over strlen swap drop over > do
    2dup + , putc
    1 +
  end drop drop
  '\n' putc
  i , 1 + i swap .
end
//dump

// argc argv
//dup argv swap .64
//over argc swap .

//argv , dump

// i *argv
//0 while dup 5 < do
// argv ,64 over + , dump
// 1 +
//end
// n*(n-1)!
//proc factorial
//  dup 1 -
//  factorial * dump
//end
//
//5 factorial

