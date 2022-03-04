
// Print 'Hello world!' 3 times
macro helloworld
  3 while dup 0 > do
     "Hello World!\n" 1 1 syscall3
     1 -
  end drop
end

macro helloworld2
  helloworld
  "-----------\n" 1 1 syscall3
  helloworld
end

helloworld2
idah


