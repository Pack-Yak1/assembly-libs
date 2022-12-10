global puts, display_string
extern print

section .text
puts:
  push rbp
  mov rbp, rsp

  ; Display everything up to but not including the null terminator
  call display_string

  ; Display a newline
  mov r9, rdi                 ; save str in r9
  sub rsp, 1                  ; make space for newline on stack
  mov byte [rsp], 10          ; put '\n' in buffer
  mov rdi, rsp                ; pass buffer to be printed
  mov rsi, 1                  ; print only 1 newline char
  call print

  mov rdi, r9                 ; restore str into first arg

  mov rsp, rbp
  pop rbp
  ret

; void display_string(const char *str)
display_string:
  mov rcx, 0                  ; int i = 0
  
  display_string_loop:
    cmp byte [rdi, rcx], 0    ; cmp str[i], 0
    je display_string_print   ; if (str[i] == '\0') { jmp puts_print; }
    inc rcx                   ; i++
    jmp display_string_loop

  display_string_print:
    mov rsi, rcx              ; print up to but not including the null byte
    call print
    ret