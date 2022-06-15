include "std.polar"


macro OP_PUSH_INT 1 end
macro OP_PLUS     2 end
macro OP_SUB      3 end
macro OP_DUMP     4 end
macro OP_EQU      5 end
macro OP_IF       6 end
macro OP_END_IF   7 end

macro sizeof(Op) 16 end
memory op-count 8 end
memory op-start sizeof(Op) 256 * end

macro sizeof(input_fn) 128 end
memory input_fn sizeof(input_fn) 1 - end

memory input_fd 8 end
memory input_buf 8 end

memory out_fd 8 end

memory stat sizeof(fstat) end

// Max word-size is 32 characters
macro sizeof(word) 32 end

memory lex_buf sizeof(word) end
memory lex_i 1 end

memory gen_i 8 end

// [ - - - - - - - v ]
memory argbits 1 end

proc is_verbose -- bool in
  argbits , 1 band cast(bool)
end

proc print_help in
  "Usage: npc <file> [options]\n\n"					puts
  "Options:\n"								puts
  "  -o <file>    Place the output into file\n"				puts
  "  -S           Do not assemble, output is assembly code\n"		puts
  "  -r           Run the program after a succesful compilation\n"	puts
  "  --unsafe     Disable type-checking\n"				puts
  "  --help       Display this information and exit\n"			puts
end

// [                                                 ]
//   op-count  op-type op-value  op-type op-value ...
//             0       8         16      24

// n op (count*size)
proc push_op
    int // op_type
    int // op_value
in
  
  swap
  op-count , sizeof(Op) * op-start +

  dup rot .
  8 + swap .

  // Increment ops count
  op-count inc64
end

// ptr
proc dump_ops in
  "------------\nop-count: "
  puts op-count , dump
  "------------\n" puts
  0 while dup op-count , < do
    dup sizeof(Op) * op-start +
    
    "Type    : " puts dup     , dump
    "Operand : " puts dup 8 + , dump
    "----\n" puts

    drop
    1 +
  end drop
end

macro NotImplemented "NotImplemented" puts 0 exit end
macro Unreachable    "Unreachable"    puts 0 exit end
macro MEM_CAPACITY 4096 end

proc compile_ops in
  0 while dup op-count , < do
    dup sizeof(Op) * op-start +

    dup , OP_PUSH_INT = if
      "\n;; -- OP_PUSH_INT -- ;;\n"	out_fd ,64 f_write
      "    push    42\n"		out_fd ,64 f_write
      //dup 8 + , dump
    else dup , OP_PLUS = elif
        "\n;; -- OP_PLUS -- ;;\n"	out_fd ,64 f_write
	"    pop     rcx\n"		out_fd ,64 f_write
	"    pop     rax\n"		out_fd ,64 f_write
	"    add     rax, rcx\n"	out_fd ,64 f_write
	"    push    rax\n"		out_fd ,64 f_write
    else dup , OP_SUB = elif
        "\n    ;; -- SUB -- ;;\n"	out_fd ,64 f_write
        "    pop     rax\n"		out_fd ,64 f_write
        "    pop     rcx\n"		out_fd ,64 f_write
        "    sub     rcx, rax\n"	out_fd ,64 f_write
        "    push    rcx\n"		out_fd ,64 f_write
    else dup , OP_DUMP = elif
      "\n;; -- OP_DUMP -- ;;\n"		out_fd ,64 f_write
      "    pop     rdi\n"		out_fd ,64 f_write
      "    call    dump\n"		out_fd ,64 f_write
    else dup , OP_EQU = elif
      "\n    ;; -- EQU -- ;;\n"		out_fd ,64 f_write
      "    xor     rdx, rdx\n"		out_fd ,64 f_write
      "    mov     rbx, 1\n"		out_fd ,64 f_write
      "    pop     rax\n"		out_fd ,64 f_write
      "    pop     rcx\n"		out_fd ,64 f_write
      "    cmp     rax, rcx\n"		out_fd ,64 f_write
      "    cmove   rdx, rbx\n"		out_fd ,64 f_write
      "    push    rdx\n"		out_fd ,64 f_write
    else dup , OP_IF = elif
      gen_i inc64
      "\n    ;; -- IF -- ;;\n"		out_fd ,64 f_write
      "    pop     rax\n"		out_fd ,64 f_write
      "    test    rax, rax\n"		out_fd ,64 f_write
      "    jz      41\n"		out_fd ,64 f_write
      //gen_i ,64 dump
    else dup , OP_END_IF = elif
	"\n;; -- END -- ;;\n"		out_fd ,64 f_write
	gen_i ,64 dump ":"		out_fd ,64 f_write
    else
       Unreachable
    end
    drop
    1 +
  end drop
end

proc compile_program in
  "section .text\n"				out_fd ,64 f_write
  "global _start\n"				out_fd ,64 f_write
  "BITS 64\n"					out_fd ,64 f_write
  "dump:\n"					out_fd ,64 f_write
  "    mov     r9, -3689348814741910323\n"	out_fd ,64 f_write
  "    sub     rsp, 40\n"			out_fd ,64 f_write
  "    mov     BYTE [rsp+31], 10\n"		out_fd ,64 f_write
  "    lea     rcx, [rsp+30]\n"			out_fd ,64 f_write
  ".L1:\n"					out_fd ,64 f_write
  "    mov     rax, rdi\n"			out_fd ,64 f_write
  "    lea     r8, [rsp+32]\n"			out_fd ,64 f_write
  "    mul     r9\n"				out_fd ,64 f_write
  "    mov     rax, rdi\n"			out_fd ,64 f_write
  "    sub     r8, rcx\n"			out_fd ,64 f_write
  "    shr     rdx, 3\n"			out_fd ,64 f_write
  "    lea     rsi, [rdx+rdx*4]\n"		out_fd ,64 f_write
  "    add     rsi, rsi\n"			out_fd ,64 f_write
  "    sub     rax, rsi\n"			out_fd ,64 f_write
  "    add     eax, 48\n"			out_fd ,64 f_write
  "    mov     BYTE [rcx], al\n"		out_fd ,64 f_write
  "    mov     rax, rdi\n"			out_fd ,64 f_write
  "    mov     rdi, rdx\n"			out_fd ,64 f_write
  "    mov     rdx, rcx\n"			out_fd ,64 f_write
  "    sub     rcx, 1\n"			out_fd ,64 f_write
  "    cmp     rax, 9\n"			out_fd ,64 f_write
  "    ja      .L1\n"				out_fd ,64 f_write
  "    lea     rax, [rsp+32]\n"			out_fd ,64 f_write
  "    mov     edi, 1\n"			out_fd ,64 f_write
  "    sub     rdx, rax\n"			out_fd ,64 f_write
  "    xor     eax, eax\n"			out_fd ,64 f_write
  "    lea     rsi, [rsp+32+rdx]\n"		out_fd ,64 f_write
  "    mov     rdx, r8\n"			out_fd ,64 f_write
  "    mov     rax, 1\n"			out_fd ,64 f_write
  "    syscall\n"				out_fd ,64 f_write
  "    add     rsp, 40\n"			out_fd ,64 f_write
  "    ret\n"					out_fd ,64 f_write
  "_start:\n"					out_fd ,64 f_write
  
  compile_ops
  
  "    xor     rdi, rdi\n"	out_fd ,64 f_write
  "    mov     rax, 60\n"	out_fd ,64 f_write
  "    syscall\n"		out_fd ,64 f_write
  
  "\nsegment .data\n"   out_fd ,64 f_write
  // Strings
  "\nsegment .bss\n"	out_fd ,64 f_write
  "mem:\n"		out_fd ,64 f_write
  "    resb    4096\n"	out_fd ,64 f_write
  //MEM_CAPACITY dump
end

proc parse_word in
  lex_buf cstr_to_str
  2dup "+" streq if
    OP_PLUS 0 push_op
  else 2dup "-" streq elif
    OP_SUB 0 push_op
  else 2dup "dump" streq elif
    OP_DUMP 0 push_op
  else 2dup "=" streq elif
    OP_EQU 0 push_op
  else 2dup "if" streq elif
    OP_IF 0 push_op
  else 2dup "end" streq elif
    OP_END_IF 0 push_op
  else
    lex_buf cstr_to_int
    false = if
      "Unable to parse word '" puts lex_buf cputs "'\n" puts
      0 exit
    end
    
    OP_PUSH_INT swap push_op
  end drop drop
end

proc parse_file in
  // buf_size i
  stat st_size ,64 0 while 2dup > do
    dup input_buf ,64 cast(ptr) + ,
    dup ?wspace
    if
      drop // Drop the character

      // Check if the buffer is not empty
      lex_i , 0 != if
        // Print the contents of the buffer
        //lex_buf cputs '\n' putc
        parse_word
  
        // Reset stuff
        lex_i 0 .
        sizeof(word) lex_buf 0 memset
      end
    else
      // Append character
      lex_buf lex_i , + swap .
      // Increment index
      lex_i inc
    end
    1 +
  end drop drop
end

argc 1 = if
  print_help 0 exit
end

// If the first is '--help'
1 nth_argv "--help"c cstreq if
  print_help 0 exit
end

// Copy the second argument to a buffer (the filename to compile)
sizeof(input_fn) 1 nth_argv input_fn memcpy

// Loop over args and do stuff
2 while dup argc < do
  "Parsing arg: '" puts dup nth_argv cputs "'\n" puts
  dup nth_argv "-v"c cstreq if argbits argbits , 1 bor . end
  1 +
end drop

// Open file
O_RDONLY_USER input_fn f_open

// Save file descriptor
input_fd swap .64

// Check for errors (-4095 < fd < -1)
input_fd ,64 ?ferr
if
  "[ERROR] failed to open input file: '" puts
  input_fn cputs "'\n" puts
  -1 exit
end

// Get fstat and check status
stat input_fd ,64 5 syscall2
0 < if
  "Failed to open file\n" puts
  -1 exit
end


// TODO:
// - Make a 'stack' for blocks?
// - Arg stuff
// - Use nasm

is_verbose if
  "\nCompiling file: '" puts input_fn cputs "'\n" puts
  "File descriptor: " puts input_fd ,64 dump
  "File size: " puts stat st_size ,64 dump
  "\n" puts
end

// Memory map file
0 input_fd ,64 MAP_PRIVATE PROT_READ stat st_size , 0 9 syscall6
dup MAP_FAILED = if
  "Failed to memory map file\n" puts
  -1 exit
end

input_buf swap .64

parse_file

is_verbose if
  "Program:\n" puts
  dump_ops "\n" puts
end

S_IRUSR S_IWUSR S_IRGRP + +
O_WRONLY O_CREAT O_TRUNC bor bor
"./out_asm.s"c f_open
out_fd swap .64

out_fd ,64 ?ferr
if
  "[ERROR] failed to open output file\n" puts -1 exit
end

compile_program

out_fd ,64 f_close

//"Assembly:\n\n" puts
//compile_program

