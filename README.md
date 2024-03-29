# npc

## Nico's Polar Compiler

Polar is a stack-based concatinative language.
Polar uses [reverse polish notation](https://en.wikipedia.org/wiki/Reverse_Polish_notation). There are no variables, and I plan it to be that way.

Inspired by [Alexey Kutepov's Porth compiler](https://gitlab.com/tsoding/porth/) and [Forth](https://forth-standard.org/).

## Milestones

Polar is planned to
- [x] Be [Turing-complete](https://en.wikipedia.org/wiki/Turing_completeness)
- [ ] Have a complete standard library
- [ ] Be self-hosted
- [x] Be optimized
- [x] Have advanced type-checking

## Features
- [x] Procedures and macros
- [x] C-style strings
- [x] Support includes

## Examples

Hello world:

```
include "std.polar"

"Hello world!\n" puts
```

Simple program that prints the numbers from 0 to 99 in ascending order:

```
0 while dup 100 < do
  dup dump
  1 +
end drop
```

More examples are located at the examples folder.

Rule110 proves polar's turing completeness. The program will print out a type of triangle.
You can change the width by altering WIDTH variable in the start, and recompiling.

An example output produced with 500 characters width:

![Rule110](https://github.com/NicoDerp/npc/blob/master/images/rule110.png)

## Quick start

Only works on linux
First, make sure you have [nasm](https://www.nasm.us/) installed and that it is available in `$PATH`.

Then you can clone this repository:
```shell
$ git clone https://github.com/NicoDerp/npc.git
```
Feel free to make changes as you like.

### Compilation

```
$ cat program.polar

242 178 + dump

$ ./npc program.polar -o program
...
... Compilation logs
...

$ ./program
420
```

### Usage

```shell
$ ./npc --help
Usage: npc <file> [options]

Options:
  -o <file>    Place the output into file
  -S           Do not assemble, output is assembly code
  -r           Run the program after a succesful compilation
  --unsafe     Disable type-checking
  --help       Display this information and exit
```

## Language reference

This is what the language supports so far. May change.

In Polar, every word does something. Since Polar uses reverse polish notation, you can read this language left-to-right.

### Literals

#### Integers

An integer is a sequence of decimal digits. Negative numbers are currently not supported.

When an integer is encountered, the number is pushed on the stack.
Example:
```shell
10 20 +
```
This will push 10 and 20 on the stack, and sum them up with the `+` operation.

#### String

A string is a sequence of characters between two `"`.
Newlines inside strings are not allowed. Special characters (like newlines) are expressed by these escape characters:

- `\n` - new line
- `\r` - carriage return
- `\\` - backslash
- `\"` - double quote
- `\'` - single quote
- '\0' - a zero number

When the compiler encounters a string:
1. The size of the string is pushed onto the stack
2. The bytes of the string are copied to somewhere in memory
3. The pointer to that place in memory is pushed onto the stack

Example:
```
"Hello world!\n"
```
This will push 13 onto the stack.
Then the bytes are copied into memory with `\n` translated to a newline.
Last the pointer to the memory location is pushed onto the stack.
Example of the stack afterwards:
```
13 420123
```

#### C-style strings

These are like strings, but they only push the pointer and not the size.
These strings ends with 0, and are used in C and in the linux kernel.
To specify that a string is a c-style string, it ends with a 'c'.

Example:
```
"Hello World!"c cputs
```

#### Character

A character is a single byte between two `'`. Escaping works the same as in strings.

When the compiler encounters a character, the character gets pushed onto the stack as an integer. 

Example:
```
'E' dump
```

This program will write the integer `69` to stdout. This is because the ASCII code of the letter `E` is `69`.

### Built-in words

#### Stack manipulation

| Name | Signature | Description |
|------|:----------|-------------|
| `dup`  | `a -- a a`       | duplicate the top element of the stack        |
| `swap` | `a b -- b a`     | swap the top two elements of the stack        |
| `drop` | `a b -- a`       | drops the top element of the stack            |
| `dump` | `a b -- a`       | write the top element of the stack to stdout  |
| `over` | `a b -- a b a`   | duplicated the second element of the stack    |
| `rot`  | `a b c -- b c a` | rotates the top three elements of the stack   |

#### Comparison

| Name | Signature | Description |
|------|:----------|-------------|
| `=`  | `[a: int] [b: int] -- [a == b: bool]` | checks if the top two elements of the stack are equal |
| `>` | `[a: int] [b: int] -- [a > b: bool]`   | applies the greater than comparison on the top two elements of the stack |
| `<` | `[a: int] [b: int] -- [a < b: bool]`   | applies the less than comparison on the top two elements of the stack |

#### Arithmatic

| Name | Signature | Description |
|------|:----------|-------------|
| `+`  | `[a: int] [b: int] -- [a + b: int]` | sum the top two elements of the stack      |
| `-`  | `[a: int] [b: int] -- [a - b: int]` | subtract the top two elements of the stack |
| `*`  | `[a: int] [b: int] -- [a * b: int]` | multiply the top two elements of the stack |
| `/`  | `[a: int] [b: int] -- [a / b: int]` | divide the top two elements of the stack   |
| `/%`  | `[a: int] [b: int] -- [a / b: int] [a % b: int]` | perform euclidean division on the top two elements of the stack   |

#### Bitwise

|  Name  | Signature | Description |
|--------|:----------|-------------|
| `shr`  | `[a: int] [b: int] -- [a >> b: int]` | right unsigned bit shift |
| `shl`  | `[a: int] [b: int] -- [a << b: int]` | left unsigned bit shift |
| `bor`  | `[a: int] [b: int] -- [a \| b: int]`  | bitwise or |
| `band` | `[a: int] [b: int] -- [a & b: int]`  | bitwise and |

#### Logical

|  Name  | Signature | Description |
|--------|:----------|-------------|
| `lor`  | `[a: int] [b: int] -- [a \|\| b: int]`  | logical or |
| `land`  | `[a: int] [b: int] -- [a && b: int]` | logical and |

#### Memory

| Name | Signature | Description |
|------|:----------|-------------|
| `,`  | `[loc: int] -- [byte: int]`  | read a byte from location in memory            |
| `.`  | `[loc: int] [byte: int] --`  | store byte into location in memory             |
| `,64`| `[loc: int] -- [byte: int]`  | read an 8-byte word from a location in memory  |
| `.64`| `[loc: int] [byte: int] --`  | store an 8-byte word from a location in memory |

#### System

- `syscall<n>`  - perform a [syscall](https://chromium.googlesource.com/chromiumos/docs/+/HEAD/constants/syscalls.md) with n number of arguments where n is in range [0-6]. (eg syscall1, syscall2)

This will firstly pop a single number which will be the syscall number.
Then n arguments will be popped and moved to the corresponding registers.
Lastly `syscall` is called.

### Control flow

#### If and else

The else is optional. Else ifs are currently not supported.
```
<condition> if
  <body>
else
  <body>
<end>
```

#### While loops

```
while <condition> do
  <body>
end
```
### Memory


You can reserve memory by using the `memory` keyword. 
Inside you spesify the amount of bytes you want.
Memory reservation supports simple compile-time evauluation.

```
macro name_size 16 end
memory names name_size 32 * end
```

This simple program will reserve 32*16 bytes, which is 512 bytes.
To access the memory, simple write the name of the memory and a pointer with it's address will be pushed onto the stack.

```
number 123 .
number , dump
```

The result:
```
123
```

### Macros

```
macro <id>
  <body>
end

<id>
```

When <id> is written in code, then that macro's <body> is copied over.

### Including

```
include "file.polar"
```

This will copy a file's contents to where that include was written.

### Procedures

```
proc <id> <args_in> -- <args_out> in
  <body>
end
```

If you have no <args_out> then you can drop the `--`.

