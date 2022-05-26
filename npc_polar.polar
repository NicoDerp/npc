include "std.polar"


macro OP_PUSH_INT 1 end
macro OP_PLUS     2 end
macro OP_DUMP     3 end

macro op-count mem          end
macro op-start op-count 8 + end

macro sizeof(Op) 16 end

// [                                                 ]
//   op-count  op-type op-value  op-type op-value ...
//             0       8         16      24

macro inc64 dup , 1 + . end

macro push_op
  swap
  op-count , sizeof(Op) * op-start +

  dup rot .
  8 + swap .

  // Increment ops count
  op-count inc64
end

// ptr
macro dump_ops
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

// ptr type
macro compile_ops
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
  "_start:\n"			puts	
  "    call    _main_\n"	puts
  "    xor     rdi, rdi\n"	puts
  "    mov     rax, 60\n"	puts
  "    syscall\n"		puts
  "_main_:"			puts
  0 while dup op-count , < do
    dup sizeof(Op) * op-start +

    dup , OP_PUSH_INT = if
      "\n;; -- OP_PUSH_INT -- ;;\n" puts
      "    push    " puts dup 8 + , dump "\n" puts
    else
      dup , OP_PLUS = if
        "\n;; -- OP_PLUS -- ;;\n" puts
	"    pop     rcx\n"       puts
	"    pop     rax\n"       puts
	"    add     rax, rcx\n"  puts
	"    push    rax\n"       puts
      else
        dup , OP_DUMP = if
	  "\n;; -- OP_DUMP -- ;;\n" puts
	  "    pop     rdi\n"       puts
	  "    call    dump\n"      puts
	else
	  Unreachable
	end
      end
    end
    drop
    1 +
  end drop
  "\n    ret\n"		puts
  "\nsegment .bss\n"	puts
  "mem:\n"		puts
  "    resb    "	puts MEM_CAPACITY dump
end

// ... argv[1] argv[0] argc

//dump dump dump dump dump

//0 exit

//drop

//while dup 0 > do
//  swap dup strlen swap puts
//  "\n" puts
//  1 -
//end

OP_PUSH_INT 48 push_op
OP_PUSH_INT 12 push_op
OP_PLUS     0  push_op
OP_DUMP     0  push_op

"Program:\n" puts
dump_ops
"Assembly:\n\n" puts
compile_ops

