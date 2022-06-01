
macro puts 1 1 syscall3 end

proc test
  3 = if
    "Yas" puts
  else
    "Nas" puts
  end
end

3 test

// n*(n-1)!
//proc factorial
//  dup 1 -
//  factorial * dump
//end
//
//5 factorial

