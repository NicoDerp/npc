
include "std.polar"


macro OP_PUSH_INT 1 end
macro OP_PLUS     2 end
macro OP_SUB      3 end
macro OP_DUMP     4 end

macro sizeof(Op) 16 end
memory op-count 8 end
memory op-start sizeof(Op) 256 * end
memory argc 1 end

macro sizeof(input_fn) 128 end
memory input_fn sizeof(input_fn) 1 - end

macro sizeof(input_buf) 4096 end
memory input_buf sizeof(input_buf) 1 - end
memory input_fd 8 end

// Max word-size is 32 characters
macro sizeof(word) 32 end

memory lex_buf sizeof(word) end
memory lex_i 1 end

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
  input_buf strlen 0 while 2dup > do
    dup input_buf + ,
    dup ?wspace
    if
      drop // Drop the character

      // Check if the buffer is not empty
      lex_i , 0 != if
        // Print the contents of the buffer
        lex_buf cstr_to_str puts '\n' putc
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
  end drop drop drop
end

argc swap .

argc , 1 = if
  print_help 0 exit
end

// Dont care about the first arg
argc dec
drop

// If the first is '--help'
dup "--help\0" str_to_cstr cstreq if
  print_help 0 exit
end

// Copy the second argument to a buffer (the filename to compile)
sizeof(input_fn) swap input_fn memcpy
argc dec

// Print the filename
"'" puts input_fn cstr_to_str puts "'\n" puts

// Loop over args and do stuff
while argc , 0 > do
  cstr_to_str puts '\n' putc
  argc dec
end

// Open file
O_READONLY_OWNER input_fn f_open

// Save file descriptor
input_fd swap .64

// Check for errors (-4095 < fd < -1)
input_fd ,64 -1 <
input_fd ,64 -4095 >
land
if
  "[ERROR] failed to open file\n" puts 0 exit
else
  // Read
  sizeof(input_buf) input_buf input_fd ,64 f_read
  
  // Close
  input_fd ,64 f_close
  
  //input_buf cstr_to_str puts
  parse_file
end

//0 exit

//OP_PUSH_INT 48 push_op
//OP_PUSH_INT 12 push_op
//OP_PLUS     0  push_op
//OP_DUMP     0  push_op

"Program:\n" puts
dump_ops
"Assembly:\n\n" puts
compile_program

