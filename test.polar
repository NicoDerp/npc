
macro sizeof(ptr) 8 end

proc ,ptr
    ptr
    --
    ptr
  in

  ,64 cast(ptr)
end

proc inc64 ptr in
  dup ,64 1 + .64
end

proc memcpy
    int // Size
    ptr // Src
    ptr // Dst
  in

  memory src sizeof(ptr) end
  memory dst sizeof(ptr) end

  dst swap .64
  src swap .64
  while dup 0 > do
    dst ,ptr
    src ,ptr , .
    src inc64
    dst inc64
    1 -
  end drop
end

memory buf 256 end

"Ooga booga" buf memcpy
10 buf 1 1 syscall3 drop

