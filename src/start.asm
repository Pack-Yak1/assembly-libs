global _start
extern main, exit

_start:
  pop rdi             ; rdi := int argc
  mov rsi, rsp        ; rsi := pointer to first string argument

  call main
  mov rdi, 0
  call exit
