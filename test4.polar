
//include "std.polar"

macro puts 1 1 syscall3 drop end

// n i b
//2 0 while dup 5 = if swap dup 2 = rot rot swap rot else dup 10 < end do
//  dup dump
//  1 +
//end

//0 while dup 7 < do
//  dup 1 = if
//    "One\n" puts
//  else dup 2 = elif
//    "Two\n" puts
//  else dup 3 = elif
//    "Three\n" puts
//  else dup 4 = elif
//    "Four\n" puts
//  else dup 5 = elif
//    "Five\n" puts
//  else dup 6 = elif
//    "Six\n" puts
//  else
//    "Unknown\n" puts
//  end
//1 +
//end drop

include "std.polar"

//
"Hola\0" str_to_cstr

dup "Hei\0" str_to_cstr cstreq if
  "Hei"
else dup "Hallo\0" str_to_cstr cstreq elif
  "Hei"
else dup "Bonojour\0" str_to_cstr cstreq elif
  "Bonojour"
else dup "Hola\0" str_to_cstr cstreq elif
  "Hola"
else
  "Nein"
end puts


