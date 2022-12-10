global prepare_uint, print_uint
extern puts

section .text

; void print_uint(unsigned int val)
print_uint:
  push rbp
  mov rbp, rsp

  sub rsp, 10
  mov rsi, rsp
  call prepare_uint
  mov rdi, rax
  call puts

  mov rsp, rbp
  pop rbp


; char *prepare_uint(unsigned int val, char *buf)
prepare_uint:
  ; rax := The 32 bit unsigned int to print. 
  ; rsi := The address of the buffer containing the char representations of 
  ;        the int to print
  ; rcx := The offset to write to in the buffer
  ; rdx := The char to write to the buffer
  ; r8  := The value of the char to write to the buffer
  ; r9  := tmp register
  mov rcx, 0        ; int i = 0
  mov rax, rdi      ; rax := val
  mov r9, 10        ; int divisor = 10
  prepare_uint_loop:
    cmp eax, 0
    je prepare_uint_reverse         ; while (val != 0)
    mov rdx, 0
    div r9d                         ; val /= 10. remainder goes to edx
    add edx, '0'                    ; edx := remainder + '0'
    mov byte [rsi + rcx], dl        ; write char to buffer
    inc rcx                         ; i++
    jmp prepare_uint_loop

  ; Output is in reverse order. Reverse with 2 pointer approach
  ; rax := left char pointer
  ; rdi := right char pointer
  ; r8, r9 := tmp char registers
  prepare_uint_reverse:
    mov rax, rsi
    lea rdi, [rsi + rcx - 1]
    prepare_uint_reverse_loop:
      cmp rax, rdi
      jge prepare_uint_exit
      mov byte r8b, [rax]
      mov byte r9b, [rdi]
      mov byte [rax], r9b
      mov byte [rdi], r8b
      inc rax
      dec rdi
      jmp prepare_uint_reverse_loop

  ; Null terminate the string
  prepare_uint_exit:
    mov byte [rsi + rcx], 0
    mov rax, rsi
    ret