%define WORK_BUF_SIZE 8192

global fgets
extern print, puts, display_string

section .text
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

; Copying to a new buffer to reduce system calls will result in having to do
; double memory accesses for strings when we could just call sys_write with the
; pre-initialized buffer. As such, we use the simple approach of printing the
; template string and interrupting whenever we need to handle an escape char



