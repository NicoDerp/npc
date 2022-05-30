
macro puts 1 1 syscall3 end


proc push_1
  "Changed stack" puts
  1
end

proc hello
  "Hello world!\n" puts
  push_1
  dump
end


hello

