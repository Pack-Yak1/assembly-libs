global strlen

section .text
strlen:
  mov rcx, 0

  strlen_loop:
    cmp byte [rdi + rcx], 0
    je strlen_end
    inc rcx
    jne strlen_loop

  strlen_end:
    mov rax, rcx
    ret