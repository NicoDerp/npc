
include "std.polar"

memory s sizeof(Str) end
memory out sizeof(Str) end

s "hei halla\nbip_bop!a" .Str

s '\n' out str_split_at_delimiter
out ,Str puts
s ,Str puts


