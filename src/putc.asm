global putc

section .text
putc:
  mov rsi, 1
  call print
  ret
