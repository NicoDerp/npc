
macro puts 1 1 syscall3 end

proc factorial
  dup 1 != if
    dup 1 - factorial *
  end
end

52 factorial dump

