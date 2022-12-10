global putc
extern print

section .text
putc:
  mov rsi, 1
  push rdi
  mov rdi, rsp
  call print
  pop rdi
  ret
