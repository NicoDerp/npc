# npc

## Nico's Polar Compiler

Polar is a stack-based concatinative language.
Polar uses [reverse polish notation](https://en.wikipedia.org/wiki/Reverse_Polish_notation). There are no variables, and I plan it to be that way.

Inspired by [Alexey Kutepov's Porth compiler](https://gitlab.com/tsoding/porth/).

## Milestones

Polar is planned to
- [x] Be Turing-complete
- [ ] Have a standard library
- [ ] Be self-hosted
- [ ] Be optimized
- [ ] Have better type-checking

## Features
- [x] Support strings
- [ ] Inline functions or macros
- [ ] Support includes

## Examples

Hello world:

```polar
fun main in
  "Hello world!\n" 1 1 syscall3
end
```

Simple program that prints the numbers from 0 to 99 in ascending order:

```polar
fun main in
  100 0 while 2dup > do
    dup dump
    1 +
  end drop drop
end
```

More examples are located at ./examples folder.

## Quick start

Pretty sure it only works on linux.
First, make sure you have [nasm](https://www.nasm.us/) installed and that it is available in `$PATH`.

Then you can clone this repository:
```shell
$ git clone https://github.com/NicoDerp/npc.git
```
Feel free to make changes as you like.

### Compilation

This will first generate assembly, and then assemble with nasm, and then link with ld.

```shell
$ cat program.polar
fun main in
  242 178 + dump
end
$ ./npc program.polar -o program
...
... Compilation stuff
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
  -p           Pretty-print the AST of the program
  -S           Do not assemble, output is assembly code
  -r           Run the program after a succesful compilation
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

A string is a sequence of characters between two `"` or two `'`.
Newlines inside strings are not allowed. Special characters (like newlines) are expressed by these escape characters:

- `\n` - new line
- `\r` - carriage return
- `\\` - backslash
- `\"` - double quote
- `\'` - single quote

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

### Built-in words

#### Stack manipulation

| Name | Signature | Description |
|------|:----------|-------------|
| `dup`  | `a -- a a`     | duplicate the top element of the stack |
| `swap` | `a b -- b a`   | swap the top two elements of the stack |
| `drop` | `a b -- a`     | drops the top element of the stack     |
| `dump` | `a b -- a`     | write the top element of the stack to stdout |
| `over` | `a b -- a b a` | duplicated the second element of the stack |

#### Comparison

| Name | Signature | Description |
|------|:----------|-------------|
| `=`  | `[a: int] [b: int] -- [a == b: bool]` | checks if the top two elements of the stack are equal |
| `>` | `[a: int] [b: int] -- [a > b: bool]`   | applies the greater than comparison on the top two elements of the stack |
| `<` | `[a: int] [b: int] -- [a < b: bool]`   | applies the less than comparison on the top two elements of the stack |

#### Arithmatic

| Name | Signature | Description |
|------|:----------|-------------|
| `+`  | `[a: int] [b: int] -- [a + b: int]` | sum the top two elements of the stack |
| `-` | `[a: int] [b: int] -- [a - b: int]`  | subtract the top two elements of the stack |

#### Bitwise

| Name | Signature | Description |
|------|:----------|-------------|
| `shr`  | `[a: int] [b: int] -- [a >> b: int]` | right unsigned bit shift |
| `shl` | `[a: int] [b: int] -- [a << b: int]`  | left unsigned bit shift |
| `bor` | `[a: int] [b: int] -- [a | b: int]`   | bit `or` |
| `band` | `[a: int] [b: int] -- [a & b: int]`  | bit `and` |

#### Memory

| Name | Signature | Description |
|------|:----------|-------------|
| `mem`  | `-- [mem: int]` | pushes memory location on top of the stack |
| `,` | `[loc: int] -- [byte: int]`  | read a byte from location in memory |
| `.` | `[loc: int] [byte: int] --`   | store byte into location in memory |

#### System

- `syscall<n>`  - perform a [syscall](https://chromium.googlesource.com/chromiumos/docs/+/HEAD/constants/syscalls.md) with n number of arguments where n is in range [0-6]. (eg syscall1, syscall2)

This will firstly pop a single number which will be the syscall number.
Then n arguments will be popped and moved to the corresponding registers.
Lastly `syscall` is called.

### Control flow

#### If condition

The else is optional.
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

Each program has reserved 4kb of memory. You can access the memory with the `,` (read) and `.` (write) operations. The pointer will be `mem` + an offset.

Example:
```
mem 17 +
mem 4 + , 1 +
.
```

This will read the contents of offset 4, add 1, then store that number into offset 17.

### Procedures

```
fun <id> in
  <body>
end
```

Even though Polar uses `fun`, it is not functions, just procedures.
You never return anything, since there is only one stack.
