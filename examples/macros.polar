
macro puts 1 1 syscall3 end

macro helloworld
  5 while dup 0 > do
    "Hello World!\n" puts
    1 -
  end drop
end

macro better_helloworld
  3 while dup 0 > do
    helloworld
    "--------------------\n" puts
    1 -
  end drop
end

better_helloworld
