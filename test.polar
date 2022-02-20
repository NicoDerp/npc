fun main in
  5 4 = if
    10 .
    5 5 = if
      12 .
    else
      14 .
    end
  else
    16 .
  end
end




if
  code
else
  code
end

_start:

  pop rax
  test rax, rax
  jz L2
  ; if code
L1:
  jmp L3
L2:
  ; else code
L3:




if
  code
end


_start:

  pop rax
  test rax, rax
  jz L2
  ; if code
L1:
  jmp L3
L3:


if
  if
    code
  end
end

_start:

  pop rax
  test rax, rax
  jz L2
  ; if code

  pop rax
  test rax, rax
  jz L5
  ; if code
L4:
  jmp L6
L5:
  ; else code
L6:

L1:
  jmp L3
L2:
  ; else code
L3:
