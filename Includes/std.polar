
macro STDIO 1 end

macro write 1 syscall3 end
macro exit  60   syscall1 end

macro puts
  STDIO write
end

macro strlen
  0 while 2dup + , 0 > do
    1 +
  end swap drop
end

macro streq
  
end
