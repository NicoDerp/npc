
include "std.polar"

memory a sizeof(Str) end
memory b sizeof(Str) end

a "hei halla" .Str
b "hei halla" .Str

a str_chop_left drop
a str_chop_right drop
a ,Str puts

