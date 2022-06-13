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
      "\n;; -- OP_PUSH_INT -- ;;\n" puts
      "    push    " puts dup 8 + , dump
    else dup , OP_PLUS = elif
        "\n;; -- OP_PLUS -- ;;\n" puts
	"    pop     rcx\n"       puts
	"    pop     rax\n"       puts
	"    add     rax, rcx\n"  puts
	"    push    rax\n"       puts
    else dup , OP_SUB = elif
        "\n    ;; -- SUB -- ;;\n"	puts
        "    pop     rax\n"		puts
        "    pop     rcx\n"		puts
        "    sub     rcx, rax\n"	puts
        "    push    rcx\n"		puts
    else dup , OP_DUMP = elif
      "\n;; -- OP_DUMP -- ;;\n" puts
      "    pop     rdi\n"       puts
      "    call    dump\n"      puts
    else dup , OP_EQU = elif
      "\n    ;; -- EQU -- ;;\n" puts
      "    xor     rdx, rdx\n"	puts
      "    mov     rbx, 1\n"	puts
      "    pop     rax\n"	puts
      "    pop     rcx\n"	puts
      "    cmp     rax, rcx\n"	puts
      "    cmove   rdx, rbx\n"	puts
      "    push    rdx\n"	puts
    else dup , OP_IF = elif
      gen_i inc64
      "\n    ;; -- IF -- ;;\n"	puts
      "    pop     rax\n"	puts
      "    test    rax, rax\n"	puts
      "    jz      " puts gen_i ,64 dump
    else dup , OP_END_IF = elif
	"\n;; -- END -- ;;\n" puts
	gen_i ,64 dump ":" puts
    else
       Unreachable
    end
    drop
    1 +
  end drop
end

proc compile_program in
  "section .text\n"				puts
  "global _start\n"				puts
  "BITS 64\n"					puts
  "dump:\n"					puts
  "    mov     r9, -3689348814741910323\n"	puts
  "    sub     rsp, 40\n"			puts
  "    mov     BYTE [rsp+31], 10\n"		puts
  "    lea     rcx, [rsp+30]\n"			puts
  ".L1:\n"					puts
  "    mov     rax, rdi\n"			puts
  "    lea     r8, [rsp+32]\n"			puts
  "    mul     r9\n"				puts
  "    mov     rax, rdi\n"			puts
  "    sub     r8, rcx\n"			puts
  "    shr     rdx, 3\n"			puts
  "    lea     rsi, [rdx+rdx*4]\n"		puts
  "    add     rsi, rsi\n"			puts
  "    sub     rax, rsi\n"			puts
  "    add     eax, 48\n"			puts
  "    mov     BYTE [rcx], al\n"		puts
  "    mov     rax, rdi\n"			puts
  "    mov     rdi, rdx\n"			puts
  "    mov     rdx, rcx\n"			puts
  "    sub     rcx, 1\n"			puts
  "    cmp     rax, 9\n"			puts
  "    ja      .L1\n"				puts
  "    lea     rax, [rsp+32]\n"			puts
  "    mov     edi, 1\n"			puts
  "    sub     rdx, rax\n"			puts
  "    xor     eax, eax\n"			puts
  "    lea     rsi, [rsp+32+rdx]\n"		puts
  "    mov     rdx, r8\n"			puts
  "    mov     rax, 1\n"			puts
  "    syscall\n"				puts
  "    add     rsp, 40\n"			puts
  "    ret\n"					puts
  "_start:\n"					puts
  
  compile_ops
  
  "    xor     rdi, rdi\n"	puts
  "    mov     rax, 60\n"	puts
  "    syscall\n"		puts
  
  "\nsegment .data\n"   puts
  // Strings
  "\nsegment .bss\n"	puts
  "mem:\n"		puts
  "    resb    "	puts MEM_CAPACITY dump
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
O_RDONLY_OWNER input_fn f_open

// Save file descriptor
input_fd swap .64

// Check for errors (-4095 < fd < -1)
input_fd ,64 -1 <
input_fd ,64 -4095 >
land
if
  "[ERROR] failed to open file\n" puts -1 exit
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

"Assembly:\n\n" puts
compile_program

