
include "std.polar"

memory s sizeof(Str) end
memory out sizeof(Str) end

s "hei halla\nbip_bop!\n" .Str

s '\n' out str_cut_to_delimiter
out ,Str puts


