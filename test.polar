fun main in
  mem 0 + 97 .
  mem 1 + 98 .
  mem 2 + 99 .

  0
  while dup 3 < do
    dup mem + , dump
    1 +
  end
end

