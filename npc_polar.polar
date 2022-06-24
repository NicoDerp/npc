include "std.polar"


macro OP_PUSH_INT   1  end
macro OP_PUSH_STR   2  end
macro OP_PLUS       3  end
macro OP_SUB        4  end
macro OP_DUMP       5  end
macro OP_EQU        6  end
macro OP_GT         7  end
macro OP_LT         8  end
macro OP_DUP        9  end
macro OP_2DUP       10 end
macro OP_DROP       11 end
macro OP_SYSCALL3   12 end
macro KEY_IF        13 end
macro KEY_ELIF      14 end
macro KEY_ELSE      15 end
macro KEY_END_IF    16 end
macro KEY_END_WHILE 17 end
macro KEY_WHILE     18 end
macro KEY_DO        19 end
macro KEY_INCLUDE   20 end

memory out_fn sizeof(ptr) end
memory out_fd 8 end

// 0     16     32         48    56
//    16     16     16         8
// [ buf | line | file_path | row ]
macro Lexer.buffer    0  end
macro Lexer.line      8  end
macro Lexer.file_path 24 end
macro Lexer.row       16 end
macro sizeof(Lexer)   56 end

macro Loc.file_path 0 end
macro Loc.row 8 end
macro Loc.col 16 end
macro sizeof(Loc) 24 end

macro Token.type 0 end
macro Token.value 8 end
macro Token.loc 16 end
macro sizeof(Token) 24 end

memory op_count 8 end
memory op_start sizeof(Op) 256 * end

memory inside_while sizeof(bool) end
memory block_i 8 end

macro sizeof(strbuf) 64 256 * end
memory strbuf_start 64 256 * end
memory strbuf_i 8 end

memory str_start sizeof(ptr) end
memory str_count 8 end

memory strings 64 sizeof(Str) * end
memory strings_i 8 end

proc ,Token.type
    ptr
    --
    int
  in

  Token.type + ,64
end

proc ,Token.value
    ptr
    --
    int
  in

  Token.value + ,64
end

proc strbuf_append_char
    int // Char
  in

  strbuf_i ,64 sizeof(strbuf) = if
    "[ERROR] Can't append character since strbuf is full!\n" puts 1 exit
  end

  strbuf_start strbuf_i ,64 +
  swap .64
  strbuf_i inc64
end

proc strbuf_end -- ptr in
  strbuf_start strbuf_i ,64 +
end

proc append_str
    int // Count
    ptr // Ptr
    --
    int // Index
  in

  strings_i ,64
  dup sizeof(Str) * strings +
  rot over swap .64
  8 + rot .64
  strings_i inc64
end

// [ - - - - - - - v ]
memory argbits 1 end

proc is_verbose -- bool in
  argbits , 1 band cast(bool)
end

proc ?inside_while -- bool in
  inside_while ,bool
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
//   op_count  op-type op-value  op-type op-value ...
//             0       8         16      24

// n op (count*size)
proc push_op
    int // op_type
    int // op_value
in
  
  swap
  op_count ,64 sizeof(Op) * op_start +

  dup rot .
  8 + swap .

  // Increment ops count
  op_count inc64
end

// ptr
proc dump_ops in
  "------------\nop_count: "
  puts op_count ,64 dump
  "------------\n" puts
  0 while dup op_count ,64 < do
    dup sizeof(Op) * op_start +
    
    "Type    : " puts dup     , dump
    "Operand : " puts dup 8 + , dump
    "----\n" puts

    drop
    1 +
  end drop
end

proc compile_ops in
  block_i 0 .64
  0 while dup op_count ,64 < do
    dup sizeof(Op) * op_start +

    dup , OP_PUSH_INT = if
      "\n;; -- OP_PUSH_INT -- ;;\n"	   out_fd ,64 f_write
      "    push    "			   out_fd ,64 f_write
      dup 8 + , uint_to_cstr cstr_to_str   out_fd ,64 f_write
      "\n"				   out_fd ,64 f_write
    
    else dup , OP_PUSH_STR = elif
      "\n;; -- OP_PUSH_STR -- ;;\n"	   out_fd ,64 f_write
      "    mov     rax, "		   out_fd ,64 f_write
      dup 8 + ,64 sizeof(str) * strings + 8 + ,64
      uint_to_cstr cstr_to_str             out_fd ,64 f_write 
      "\n    push    rax\n"		   out_fd ,64 f_write
      "    push    str_"		   out_fd ,64 f_write
      dup 8 + ,64 uint_to_cstr cstr_to_str out_fd ,64 f_write  
      "\n"                                 out_fd ,64 f_write 

    else dup , OP_PLUS = elif
      "\n;; -- OP_PLUS -- ;;\n"		   out_fd ,64 f_write
      "    pop     rcx\n"		   out_fd ,64 f_write
      "    pop     rax\n"		   out_fd ,64 f_write
      "    add     rax, rcx\n"		   out_fd ,64 f_write
      "    push    rax\n"		   out_fd ,64 f_write
    
    else dup , OP_SUB = elif
      "\n;; -- OP_SUB -- ;;\n"		   out_fd ,64 f_write
      "    pop     rax\n"		   out_fd ,64 f_write
      "    pop     rcx\n"		   out_fd ,64 f_write
      "    sub     rcx, rax\n"		   out_fd ,64 f_write
      "    push    rcx\n"		   out_fd ,64 f_write
    
    else dup , OP_DUMP = elif
      "\n;; -- OP_DUMP -- ;;\n"		   out_fd ,64 f_write
      "    pop     rdi\n"		   out_fd ,64 f_write
      "    call    dump\n"		   out_fd ,64 f_write
    
    else dup , OP_EQU = elif
      "\n;; -- OP_EQU -- ;;\n"		   out_fd ,64 f_write
      "    xor     rdx, rdx\n"		   out_fd ,64 f_write
      "    mov     rbx, 1\n"		   out_fd ,64 f_write
      "    pop     rax\n"		   out_fd ,64 f_write
      "    pop     rcx\n"		   out_fd ,64 f_write
      "    cmp     rax, rcx\n"		   out_fd ,64 f_write
      "    cmove   rdx, rbx\n"		   out_fd ,64 f_write
      "    push    rdx\n"		   out_fd ,64 f_write

    else dup , OP_GT = elif
      "\n;; -- OP_GT -- ;;\n"		   out_fd ,64 f_write
      "    pop     rax\n"		   out_fd ,64 f_write
      "    pop     rcx\n"		   out_fd ,64 f_write
      "    xor     rdx, rdx\n"		   out_fd ,64 f_write
      "    mov     rbx, 1\n"		   out_fd ,64 f_write
      "    cmp     rcx, rax\n"		   out_fd ,64 f_write
      "    cmovg   rdx, rbx\n"		   out_fd ,64 f_write
      "    push    rdx\n"		   out_fd ,64 f_write

    else dup , OP_LT = elif
      "\n;; -- OP_LT -- ;;\n"		   out_fd ,64 f_write
      "    pop     rax\n"		   out_fd ,64 f_write
      "    pop     rcx\n"		   out_fd ,64 f_write
      "    xor     rdx, rdx\n"		   out_fd ,64 f_write
      "    mov     rbx, 1\n"		   out_fd ,64 f_write
      "    cmp     rcx, rax\n"		   out_fd ,64 f_write
      "    cmovl   rdx, rbx\n"		   out_fd ,64 f_write
      "    push    rdx\n"		   out_fd ,64 f_write

    else dup , OP_DUP = elif
      "\n;; -- OP_DUP -- ;;\n"		   out_fd ,64 f_write
      "    pop     rax\n"		   out_fd ,64 f_write
      "    push    rax\n"		   out_fd ,64 f_write
      "    push    rax\n"		   out_fd ,64 f_write

    else dup , OP_2DUP = elif
      "\n;; -- 2DUP -- ;;\n"		   out_fd ,64 f_write
      "    pop     rax\n"		   out_fd ,64 f_write
      "    pop     rcx\n"		   out_fd ,64 f_write
      "    push    rcx\n"		   out_fd ,64 f_write
      "    push    rax\n"		   out_fd ,64 f_write
      "    push    rcx\n"		   out_fd ,64 f_write
      "    push    rax\n"		   out_fd ,64 f_write

    else dup , OP_DROP = elif
      "\n;; -- DROP -- ;;\n"		   out_fd ,64 f_write
      "    pop     rax\n"    		   out_fd ,64 f_write

    else dup , OP_SYSCALL3 = elif
      "\n    ;; -- SYSCALL3 -- ;;\n"       out_fd ,64 f_write
      "    pop     rax\n"                  out_fd ,64 f_write
      "    pop     rdi\n"                  out_fd ,64 f_write
      "    pop     rsi\n"                  out_fd ,64 f_write
      "    pop     rdx\n"                  out_fd ,64 f_write
      "    syscall\n"                      out_fd ,64 f_write
      "    push    rax\n"                  out_fd ,64 f_write

    else dup , KEY_IF = elif
      "\n;; -- KEY_IF -- ;;\n"		   out_fd ,64 f_write
      "    pop     rax\n"		   out_fd ,64 f_write
      "    test    rax, rax\n"		   out_fd ,64 f_write
      "    jz      .L"			   out_fd ,64 f_write
      dup 8 + ,64 uint_to_cstr cstr_to_str out_fd ,64 f_write
      "\n"				   out_fd ,64 f_write
      block_i inc64

    else dup , KEY_ELIF = elif
      "\n;; -- KEY_ELIF -- ;;\n"           out_fd ,64 f_write
      "    pop     rax\n"		   out_fd ,64 f_write
      "    test    rax, rax\n"		   out_fd ,64 f_write
      "    jz      .L"			   out_fd ,64 f_write
      dup 8 + ,64 uint_to_cstr cstr_to_str out_fd ,64 f_write
      "\n"				   out_fd ,64 f_write
      block_i inc64

    else dup , KEY_ELSE = elif
      "\n;; -- KEY_ELSE -- ;;\n"	   out_fd ,64 f_write
      "    jmp     .L"			   out_fd ,64 f_write
      dup 8 + ,64 uint_to_cstr cstr_to_str out_fd ,64 f_write
      "\n.L"				   out_fd ,64 f_write
      block_i ,64 uint_to_cstr cstr_to_str out_fd ,64 f_write
      ":\n"    	  	       		   out_fd ,64 f_write
      block_i inc64
    
    else dup , KEY_END_IF = elif
      "\n;; -- KEY_END_IF -- ;;\n"	   out_fd ,64 f_write
      ".L"  	     			   out_fd ,64 f_write
      dup 8 + ,64 uint_to_cstr cstr_to_str out_fd ,64 f_write
      ":\n"				   out_fd ,64 f_write
      block_i inc64

    else dup , KEY_END_WHILE = elif
      "\n;; -- KEY_END_WHILE -- ;;\n"	   out_fd ,64 f_write
      "    jmp     .L"	    		   out_fd ,64 f_write
      dup 8 + ,64 uint_to_cstr cstr_to_str out_fd ,64 f_write
      "\n.L"  	     			   out_fd ,64 f_write
      block_i ,64 uint_to_cstr cstr_to_str out_fd ,64 f_write
      ":\n"				   out_fd ,64 f_write
      block_i inc64

    else dup , KEY_WHILE = elif
      "\n;; -- KEY_WHILE -- ;;\n"	   out_fd ,64 f_write
      ".L"  	     			   out_fd ,64 f_write
      dup 8 + ,64 uint_to_cstr cstr_to_str out_fd ,64 f_write
      ":\n"				   out_fd ,64 f_write
      block_i inc64

    else dup , KEY_DO = elif
      "\n;; -- KEY_DO -- ;;\n"		   out_fd ,64 f_write
      "    pop     rax\n"		   out_fd ,64 f_write
      "    test    rax, rax\n"		   out_fd ,64 f_write
      "    jz      .L"			   out_fd ,64 f_write
      dup 8 + ,64 uint_to_cstr cstr_to_str out_fd ,64 f_write
      "\n"				   out_fd ,64 f_write
      block_i inc64

    else
       "Unknown word in code generation with id " puts dup , dump 1 exit
    end
    drop
    1 +
  end drop
end

proc compile_program in
  "section .text\n"			   out_fd ,64 f_write
  "global _start\n"			   out_fd ,64 f_write
  "BITS 64\n"				   out_fd ,64 f_write
  "dump:\n"				   out_fd ,64 f_write
  "    mov     r9, -3689348814741910323\n" out_fd ,64 f_write
  "    sub     rsp, 40\n"		   out_fd ,64 f_write
  "    mov     BYTE [rsp+31], 10\n"	   out_fd ,64 f_write
  "    lea     rcx, [rsp+30]\n"		   out_fd ,64 f_write
  ".L1:\n"				   out_fd ,64 f_write
  "    mov     rax, rdi\n"		   out_fd ,64 f_write
  "    lea     r8, [rsp+32]\n"		   out_fd ,64 f_write
  "    mul     r9\n"			   out_fd ,64 f_write
  "    mov     rax, rdi\n"		   out_fd ,64 f_write
  "    sub     r8, rcx\n"		   out_fd ,64 f_write
  "    shr     rdx, 3\n"		   out_fd ,64 f_write
  "    lea     rsi, [rdx+rdx*4]\n"	   out_fd ,64 f_write
  "    add     rsi, rsi\n"		   out_fd ,64 f_write
  "    sub     rax, rsi\n"		   out_fd ,64 f_write
  "    add     eax, 48\n"		   out_fd ,64 f_write
  "    mov     BYTE [rcx], al\n"	   out_fd ,64 f_write
  "    mov     rax, rdi\n"		   out_fd ,64 f_write
  "    mov     rdi, rdx\n"		   out_fd ,64 f_write
  "    mov     rdx, rcx\n"		   out_fd ,64 f_write
  "    sub     rcx, 1\n"		   out_fd ,64 f_write
  "    cmp     rax, 9\n"		   out_fd ,64 f_write
  "    ja      .L1\n"			   out_fd ,64 f_write
  "    lea     rax, [rsp+32]\n"		   out_fd ,64 f_write
  "    mov     edi, 1\n"		   out_fd ,64 f_write
  "    sub     rdx, rax\n"		   out_fd ,64 f_write
  "    xor     eax, eax\n"		   out_fd ,64 f_write
  "    lea     rsi, [rsp+32+rdx]\n"	   out_fd ,64 f_write
  "    mov     rdx, r8\n"		   out_fd ,64 f_write
  "    mov     rax, 1\n"		   out_fd ,64 f_write
  "    syscall\n"			   out_fd ,64 f_write
  "    add     rsp, 40\n"		   out_fd ,64 f_write
  "    ret\n"				   out_fd ,64 f_write
  "_start:\n"				   out_fd ,64 f_write
  
  compile_ops
  
  "    xor     rdi, rdi\n"                 out_fd ,64 f_write
  "    mov     rax, 60\n"                  out_fd ,64 f_write
  "    syscall\n"                          out_fd ,64 f_write
  
  "\nsegment .data\n"                      out_fd ,64 f_write

  0 while dup strings_i ,64 < do
    // i size (ptr+8)
    "str_"                                 out_fd ,64 f_write
    dup uint_to_cstr cstr_to_str           out_fd ,64 f_write
    
    dup sizeof(str) * strings +
    dup ,64 cast(ptr)
    swap 8 + ,64
    ":\n    db      "                      out_fd ,64 f_write
    // count ptr
    while dup 0 > do
      swap
      dup , uint_to_cstr cstr_to_str       out_fd ,64 f_write
      over 1 != if
        ", "                               out_fd ,64 f_write
      end
      1 + swap
      1 -
    end drop drop
    "\n"                                   out_fd ,64 f_write
    //puts
    1 +
  end drop
  
  "\nsegment .bss\n"                       out_fd ,64 f_write
  "mem:\n"                                 out_fd ,64 f_write
  "    resb    4096\n"                     out_fd ,64 f_write
end

// op-i
proc crossreference_blocks in
  0 while dup op_count ,64 < do
    dup sizeof(Op) * op_start +
    dup , KEY_IF = if
      dup array_push
      block_i inc64
    else dup , KEY_ELIF = elif
      dup array_push
      block_i inc64
    else dup , KEY_ELSE = elif
      block_i ,64
      array_top ,64 cast(ptr)
      dup ,64 KEY_IF = if
        8 + cast(ptr)
        over .64
        over 8 + cast(ptr) swap .64
        dup array_push
        block_i inc64
      else dup ,64 KEY_ELIF = elif
        array_pop drop
        8 + cast(ptr)
        over .64
        over 8 + cast(ptr) swap .64
        dup array_push
        block_i inc64
      end
    else dup , KEY_WHILE = elif
      dup 8 + block_i ,64 .64 // Save n to while block
      dup array_push
      block_i inc64
    else dup , KEY_DO = elif
      dup array_push
      block_i inc64
    else dup , KEY_END_IF = elif
      // op-i op-ptr block_ptr
      array_top ,64 cast(ptr)
      dup ,64 KEY_ELIF = if
        array_pop drop
        8 + cast(ptr)
        block_i inc64
        block_i ,64 .64
      else
        drop
      end

      // op-i op-ptr 0 block_ptr
      0 while
        array_pop cast(ptr)
        dup ,64 KEY_ELSE = if
	  block_i ,64
	  over 8 +
	  over .64
	  drop drop
	  true
	else
	  drop false
	end
      do
        1 +
      end drop
      block_i ,64
      over 8 + swap .64
      block_i inc64
    else dup , KEY_END_WHILE = elif
      // op-i op-ptr n2
      block_i ,64
      array_pop 8 + cast(ptr) swap .64 // Save n to do-block
      array_pop 8 + cast(ptr) ,64 // Get while-block n
      over 8 + swap .64
      block_i inc64
    else dup , KEY_WHILE = elif
      dup array_push
    end
    drop
    1 +
  end drop
end

proc parse_string
    ptr // Cstr
    --
    int // Str.count
    ptr // Str.ptr
    bool // Success
  in

  str_start strbuf_end .64
  str_count 0 .64

  cstr_rightmost_char '"' !=
  swap cstr_leftmost_char '"' !=
  rot lor if
    drop
    0 NULL false
  else
    cstr_chop_left drop
    cstr_chop_right drop
    while
      dup ?cstr_empty lnot if
        cstr_chop_left
	dup '\\' = if
          drop
          cstr_chop_left
          dup 'n' = if
            drop
            '\n' strbuf_append_char
            str_count inc64
	  else dup '\\' = elif
	    drop
	    '\\' strbuf_append_char
	    str_count inc64
	  else dup 't' = elif
	    drop
	    '\t' strbuf_append_char
	    str_count inc64
          else
            "[ERROR] Unreckognized escape sequence '\\" puts
            putc "'\n" puts 1 exit
	  end
	else
	  strbuf_append_char
	  str_count inc64
	end
	true
      else
        false
      end
    do end drop
    str_count ,64 str_start ,64 cast(ptr) true
  end
end

proc lexer_next_line
    ptr // Lexer
  in

  memory lexer sizeof(ptr) end
  lexer swap .64

  lexer ,ptr Lexer.buffer +
  '\n'
  lexer ,ptr Lexer.line +
  str_split_at_delimiter

  // Increment row
  lexer ,ptr Lexer.row + inc64
end

proc parse_next_word
    ptr // Token
    ptr // Lexer
    --
    bool
  in

  memory token sizeof(ptr) end
  memory lexer sizeof(ptr) end
  memory inside_str sizeof(bool) end
  memory word sizeof(Str) end

  memory end_of_file sizeof(bool) end

  lexer swap .64
  token swap .64
  sizeof(Str) word 0 memset

  // Loop over lines until there isn't only whitespace
  // lexer
  lexer ,ptr
  while
    dup Lexer.line + ,ptr
    dup str_trim_left
    ?str_empty if
      dup Lexer.buffer + ,ptr
      ?str_empty if
        end_of_file true .
        false
      else
        true
      end
    else
      false
    end
  do dup lexer_next_line end
  drop // Lexer

  end_of_file ,bool lnot if
    lexer ,ptr Lexer.line + ,ptr
    str_split_at_delimiter
  
    
    
    buf "+"c cstreq if
      OP_PLUS 0
    else buf "-"c cstreq        elif OP_SUB 0
    else buf "dump"c cstreq     elif OP_DUMP 0
    else buf "="c cstreq        elif OP_EQU 0
    else buf ">"c cstreq        elif OP_GT 0
    else buf "<"c cstreq        elif OP_LT 0
    else buf "dup"c cstreq      elif OP_DUP 0
    else buf "2dup"c cstreq     elif OP_2DUP 0
    else buf "drop"c cstreq     elif OP_DROP 0
    else buf "syscall3"c cstreq elif OP_SYSCALL3 0
    else buf "if"c cstreq elif
      ?array_empty lnot if
        array_top inc64
      end KEY_IF 0
    else buf "elif"c cstreq     elif KEY_ELIF 0
    else buf "else"c cstreq     elif KEY_ELSE 0
    else buf "end"c cstreq      elif
      array_top dec64
      array_top ,64 0 =
      if
        array_pop drop
        KEY_END_WHILE 0
      else
        KEY_END_IF 0
      end
    else buf "while"c cstreq elif
      KEY_WHILE 0
      1 array_push
    else buf "do"c cstreq       elif KEY_DO 0
    else buf "include"c cstreq  elif KEY_INCLUDE 0
    else
      buf cstr_to_int
      false = if
        drop
        buf parse_string false = if
          "[ERROR] Unable to parse word '" puts buf cputs "'\n" puts
          1 exit
        end
        append_str
        OP_PUSH_STR swap
      else
        OP_PUSH_INT swap
      end
    end
    token ,ptr Token.value + swap .64
    token ,ptr Token.type + swap .64
    true
  else
    false
  end
end

proc mmap_file
    ptr // Filename
    --
    int // Size
    ptr // Buffer
  in

  memory fn sizeof(ptr) end
  memory fd sizeof(uint8) end
  memory stat sizeof(ptr) end
  
  O_RDONLY_USER fn ,ptr f_open

  // Save file descriptor
  fd swap .64
  
  // Check for errors (-4095 < fd < -1)
  fd ,64 ?ferr
  if
    "[ERROR] Failed to open file: '" puts fn ,ptr cputs "'\n" puts
    1 exit
  end
  
  // Get fstat and check status
  stat fd ,64 5 syscall2
  0 < if
    "[ERROR] Failed to open file: '" puts fn ,ptr cputs "'\n" puts
    1 exit
  end

  // Memory map file
  0 fd ,64 MAP_PRIVATE PROT_READ stat st_size , 0 9 syscall6
  dup MAP_FAILED = if
    "[ERROR] Failed to memory map file: '" puts fn ,ptr cputs "'\n" puts
    1 exit
  end
  stat st_size ,64 swap
end

proc parse_file
    ptr // Cstr filename
  in

  memory file_path sizeof(ptr) end
  file_path swap .64

  memory lexer sizeof(Lexer) end
  sizeof(Lexer) lexer 0 memset
  lexer Lexer.buffer    + file_path ,ptr mmap_file   .Str
  lexer Lexer.file_path + file_path ,ptr cstr_to_str .Str

  is_verbose if
    "Parsing file: '" puts input_fn ,ptr cputs "'\n" puts
    "File descriptor: " puts input_fd ,64 dump
    "File size: " puts stat st_size ,64 dump
    "\n" puts
  end

  memory token sizeof(Token) end
  while tokemn lexer parse_next_word do
    "Parsed token:\n" puts
    "Type: " puts op Op.type + ,64 dump
    "Value: " puts op Op.value + ,64 dump
    
    token ,Op.type
    token ,Op.value
    push_op
  end
end

// If there are no arguments supplied show help message
argc 1 = if
  print_help 0 exit
end

// If the first is '--help'
1 nth_argv "--help"c cstreq if
  print_help 0 exit
end

// Default out
out_fn "a.out"c .64

// Loop over args and do stuff
2 while dup argc < do
  "Parsing arg: '" puts dup nth_argv cputs "'\n" puts
  dup nth_argv "-v"c cstreq if
    argbits argbits , 1 bor .
  else dup nth_argv "-o"c cstreq elif
    1 +
    dup argc = if
      "[ERROR] No filename supplied after '-o'\n" puts 1 exit
    end
    dup nth_argv out_fn swap .64
  end
  1 +
end drop

1 nth_argv parse_file
array_clean

crossreference_blocks
array_clean

is_verbose if
  "Program:\n" puts
  dump_ops "\n" puts
end

S_IRUSR S_IWUSR S_IRGRP + +
O_WRONLY O_CREAT O_TRUNC bor bor
".tmp_file.s"c f_open
out_fd swap .64

out_fd ,64 ?ferr
if
  "[ERROR] failed to open output file\n" puts -1 exit
end

compile_program

out_fd ,64 f_close

"/usr/bin/nasm"c array_push
"-felf64"c       array_push
".tmp_file.s"c   array_push
"-o"c            array_push
".tmp_file.o"c   array_push

array subp_exec_cmd true = if
  "[ERROR] Failed to execute assembler\n" puts 1 exit
end
array_clean

"/usr/bin/ld"c array_push
".tmp_file.o"c array_push
"-o"c          array_push
out_fn ,64     array_push

array subp_exec_cmd true = if
  "[ERROR] Failed to execute linker\n" puts 1 exit
end
array_clean

// Clean up temporary files
".tmp_file.s"c rmfile -2 =
".tmp_file.o"c rmfile -2 =
lor if
  "[ERROR] Failed to clean up temporary files\n" puts 1 exit
end

"[INFO] All done!\n" puts

//"Assembly:\n\n" puts
//compile_program

