fun main in
  0
  while dup 10 < do
    dup .
    1 +
  end
end





while_label:
  code
  test > and push
do_label:
  jz end_label
  code
  jmp while_label
end_label:
