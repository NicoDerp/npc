
macro puts 1 1 syscall3 end

proc factorial int -- int in
  dup 1 != if
    dup 1 - factorial *
  end
end

5 factorial dump

