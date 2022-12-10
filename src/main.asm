global _start
extern print_hex, fgets, puts, print, exit, prepare_uint

section .text
_start:
  sub rsp, 10
  mov r11, rsp
  mov rdi, 12345
  mov rsi, rsp
  call prepare_uint

  mov rdi, rsi
  call puts

  mov rdi, hello
  mov rsi, hello_len
  call print

  mov rdi, 0x1234567890abcdef
  call print_hex

  ; Print prompt for uint input
  mov rdi, prompt
  mov rsi, prompt_len
  call print

  ; fgets into user_buffer
  mov rdi, user_buffer
  mov rsi, 11
  mov rdx, 0
  call fgets

  ; Print the contents of the user_buffer
  mov rdi, user_buffer
  call puts

  mov rdi, 0
  call exit


section .data

hello db "Hello World!", 10
hello_len equ $ - hello

user_buffer times 11 db 0

prompt db "Enter a non-negative int (max 10 digits)", 10
prompt_len equ $ - prompt
