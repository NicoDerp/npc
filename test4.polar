
//include "std.polar"

macro puts 1 1 syscall3 drop end

//0 while dup 8 < do
5
dup 1 = if
  "One\n"
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
drop
//1 +
//end drop

//"\n---------------\n\n" puts
//"Hola\0" str_to_cstr
//dup "Hei\0" str_to_cstr cstreq if
//  "Hei"
//else dup "Hallo\0" str_to_cstr cstreq elif
//  "Hallo"
//else dup "Bonojour\0" str_to_cstr cstreq elif
//  "Bonojour"
//else dup "Hola\0" str_to_cstr cstreq elif
//  "Hola"
//else
//  "Nein"
//end puts drop


