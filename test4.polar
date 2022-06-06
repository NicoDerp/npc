
//include "std.polar"

macro puts 1 1 syscall3 end

// n i b
//2 0 while dup 5 = if swap dup 2 = rot rot swap rot else dup 10 < end do
//  dup dump
//  1 +
//end

2
dup 1 = if
  "One" puts
else dup 2 = elif
  "Two" puts
else dup 3 = elif
  "Three" puts
else
  drop
  "Unknown" puts
end

//include "std.polar"

//
//"Hola\0" str_to_cstr
//
//dup "Hei\0" str_to_cstr cstreq if
//  "Hei"
//else dup "Hallo\0" str_to_cstr cstreq elif
//  "Hei"
//else dup "Bonojour\0" str_to_cstr cstreq elif
//  "Bonojour"
//else dup "Hola\0" str_to_cstr cstreq elif
//  "Hola"
//else
//  "Nein"
//end puts
//
//
