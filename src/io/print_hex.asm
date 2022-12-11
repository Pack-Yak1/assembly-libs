global print_hex
extern print

section .text
; void print_hex(uint64_t val)
print_hex:
  push rbp
  mov rbp, rsp

  ; Output will be 64 bits so 16 nibbles, plus 2 chars for "0x" and 1 char for
  ; newline. Construct the string on the stack. Add the "0x" later.
  sub rsp, 17
  
  ; rdi := val
  mov rcx, 0          ; int i = 0
  mov rax, 0          ; maintain rax := 4 * rcx
  
  mov byte [rsp + 16], 10
  

  ; Invariant: The value of the i-th hex character is (val << (i * 4)) >> 15 * 4
  ; which is (rdi << (4 * rcx)) >> 15 * 4
  print_hex_loop:
    mov rdx, rdi                ; rdx holds the nibble to print
    mov r9, rcx                 ; save rcx
    mov rcx, rax                ; only rcx can be passed as op2 to shl
    shl rdx, cl                 ; always fits in lower order 8 bits
    mov rcx, r9                 ; restore rcx
    shr rdx, 60                 ; keep only the highest order bit after leftshift

    ; Check if nibble is 0-9 or a-f
    cmp rdx, 10
    jl print_hex_numeric
    ; a-f branch
    add dl, 87                  ; a = 10 -> ascii 97, difference is 87
    jmp nibble_decoded

    print_hex_numeric:
      add dl, 48                ; 0 -> ascii 48, difference is 48

    nibble_decoded:
      mov byte [rsp + rcx], dl  ; put nibble on stack
      inc cl                    ; i++
      add al, 4                 ; al += 4
      cmp cl, 16                ; only calculating 16 nibbles. If i >= 16, break
      jl print_hex_loop

  
  sub rsp, 2                    ; make space for "0x"
  mov byte [rsp], '0'
  mov byte [rsp + 1], 'x'

  lea rdi, [rsp]                ; pass the char[] on the stack to print
  mov rsi, 19
  call print

  mov rsp, rbp
  pop rbp
  ret