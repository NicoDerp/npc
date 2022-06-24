
include "std.polar"

memory a sizeof(Str) end
memory b sizeof(Str) end

a "  \n" .Str

proc something ptr in
  dump
end

proc shiish in
  a str_trim_left
  a ?str_empty putb
  ' ' a str_split_at_delimiter
end

something

