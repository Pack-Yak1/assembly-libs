%define WORK_BUF_SIZE 1024

global fgets, puts, print, print_hex

section .text

; void print(char *str, size_t len)
print:
  mov rdx, rsi  ; Move length into 3rd argument slot
  mov rsi, rdi  ; Move string into 2nd argument slot
  mov rdi, 1    ; Specify stdout
  mov rax, 1    ; Write syscall code
  syscall
  ret

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


; int puts(const char *str)
puts:
  push rbp
  mov rbp, rsp

  mov rcx, 0                  ; int i = 0
  
  puts_loop:
    cmp byte [rdi, rcx], 0    ; cmp str[i], 0
    je puts_print             ; if (str[i] == '\0') { jmp puts_print; }
    inc rcx                   ; i++
    jmp puts_loop

  puts_print:
    mov rsi, rcx              ; print up to but not including the null byte
    call print

    mov r9, rdi               ; save str in r9
    sub rsp, 1                ; make space for newline on stack
    mov byte [rsp], 10        ; put '\n' in buffer
    mov rdi, rsp              ; pass buffer to be printed
    mov rsi, 1                ; print only 1 newline char
    call print

  mov rdi, r9                 ; restore str into first arg

  mov rsp, rbp
  pop rbp
  ret


; char *fgets(char *buf, int n, int fd)
; String stored in `buf` will be null terminated, either at the n-th character
; (0-indexed) or in place of the first newline character, whichever is first
fgets:
  push rbp
  mov rbp, rsp

  ; Store user input in buf
  mov r9, rsi                     ; Store n in unsaved tmp variable
  mov rsi, rdi                    ; Move buf to second argument
  mov rdi, rdx                    ; Move fp to first argument
  mov rdx, r9                     ; Move n to third argument
  mov rax, 0                      ; Read syscall
  syscall

  ; rsi := buf
  ; r9 := n
  ; r10 := i

  ; fgets only outputs up to n - 1 chars after reading n chars
  dec r9                          ; n--
  mov r10, 0                      ; int i = 0
  ; While (i < n && buf[i] != '\n')
  fgets_loop_condition:
    cmp r10, r9                   ; cmp i, n
    setl al                       ; al := i < n
    mov byte cl, [rsi + r10]      ; cl := buf[i]
    cmp cl, 10                    ; cmp buf[i], '\n'
    setne dl                      ; dl := buf[i] != '\n'
    and al, dl                    ; al := (i < n) && (buf[i] != '\n')
    cmp al, 0                     ; (i < n) && (buf[i] != '\n') != false
    jne fgets_while               ; if (i < n) && (buf[i] != '\n') {jmp fgets_while}
  fgets_put_null:
    mov byte [rsi + r10], 0       ; buf[i] = '\0'
    ; If the last character wasnt a newline, we need to cleanup stdin
    push rsi                      ; preserve ptr to buf across fn call
    cmp dl, 0                     ; cmp (buf[i] != '\n'), false == cmp (buf[i] == '\n'), true
    je fgets_exit                 ; if (buf[i] == '\n') { jmp fgets_exit; }
    call flush_stdin              ; else { call flush_stdin; }

  fgets_exit:
    pop rax                       ; pop ptr to buf into return value
    mov rsp, rbp
    pop rbp
    ret

  fgets_while:
    inc r10                       ; i++
    jmp fgets_loop_condition


; Helper function for clearing stdin so that excess input isn't executed as a
; shell command after program exits
flush_stdin:
  push rbp
  mov rbp, rsp

    ; read WORK_BUF_SIZE bytes from stdin into stack
    sub rsp, WORK_BUF_SIZE        ; allocate a buffer
    mov rsi, rsp                  ; place buffer as 2nd arg to write syscall
    mov rdx, WORK_BUF_SIZE        ; size of buffer is 3rd arg
    mov rdi, 0                    ; stdin is 1st arg
    mov rax, 0                    ; write syscall
    syscall

    mov r9, WORK_BUF_SIZE         ; n = 1024
    mov r10, 0                    ; i = 0
  flush_stdin_while:
    cmp r10, r9                   ; cmp i, n
    setl al                       ; al := i < n
    mov byte cl, [rsi + r10]      ; cl := buf[i]
    cmp cl, 10                    ; cmp buf[i], '\n'
    setne dl                      ; dl := buf[i] != '\n'
    and al, dl                    ; al := (i < n) && (buf[i] != '\n')
    cmp al, 0                     ; (i < n) && (buf[i] != '\n') == false
    je flush_stdin_break          ; if (i < n) && (buf[i] != '\n') {jmp flush_stdin_break}
    inc r10                       ; i++

    jmp flush_stdin_while        
  flush_stdin_break:
    ; Might still not have encountered a newline. Verify '\n' seen or recall fn
    cmp dl, 0                     ; cmp (buf[i] != '\n'), false  == cmp (buf[i] == '\n'), true
    je flush_stdin_done           ; if (buf[i] == '\n') { jmp flush_stdin_done; }
    call flush_stdin              ; else { recurse }
  flush_stdin_done:
    mov rsp, rbp
    pop rbp
    ret
