
include "std.polar"

macro puts 1 1 syscall3 drop end

0 while dup 8 < do
  dup 1 = if
    "One\n"
    1 2 = if
      "123" puts
    end
    //else 2 3 = elif
    //  "234" puts
    //else
    //  "345" puts
    //end
  else dup 2 = elif
    "Two\n"
  else dup 1 = elif
    "Three\n"
  else dup 4 = elif
    "Four\n"
  else dup 5 = elif
    "Five\n"
  else dup 6 = elif
    "Six\n"
  else
    "Unknown\n"
  end puts
  1 +
end drop

"\n---------------\n\n" puts

"Hola\0" str_to_cstr

dup "Hei\0" str_to_cstr cstreq if
  "Hei"
else dup "Hallo\0" str_to_cstr cstreq elif
  "Hallo"
else dup "Bonojour\0" str_to_cstr cstreq elif
  "Bonojour"
else dup "Hola\0" str_to_cstr cstreq elif
  "Hola"
else
  "Nein"
end puts drop


