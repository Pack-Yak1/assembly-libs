global print

section .text
; void print(char *str, size_t len)
print:
  mov rdx, rsi  ; Move length into 3rd argument slot
  mov rsi, rdi  ; Move string into 2nd argument slot
  mov rdi, 1    ; Specify stdout
  mov rax, 1    ; Write syscall code
  syscall
  ret