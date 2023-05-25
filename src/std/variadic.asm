global va_start, va_arg
extern puts

section .text

; Memory layout of va_list_t:
;   [ptr + 0 ] := index of argument to return
;   [ptr + 8 ] := pointer to argument to return
;   [ptr + 16] := pointer to argument 6 on the stack
;   [ptr + 24] := number of required arguments

; Approach: Based on the number of required arguments, allocate space for
; rsi..r9 arguments on the stack. Concrete type of va_list is a size_t indicating
; the next argument to return (0-indexed, including required arguments), and
; a pointer to the start of the next argument, as well as a const pointer to
; the start of stack saved arguments (arguments 6 and onwards)
; va_start(va_list_t *ptr)
va_start:
  push rbp
  mov rbp, rsp

  ; Write the start of the stack saved arguments
  mov r10, [rbp + 8]        ; rbp points to previous rbp, above which are caller-saved args
  mov qword [rdi + 16], r10 ; initialize ptr->base
  
  mov r10, [rdi + 24]       ; r10 := ptr->num_req
  cmp r10, 1                ; Check if too few required arguments
  jl panic_insufficient_args

  ; Write index of next argument to return
  mov qword [rdi], r10      ; ptr->next_index = 0-indexed index of next arg to return

  

  ; Allocate space for register arguments
  ; Needs 4 more registers, use r11 and 3 callee saved registers unused for args
  push rbx
  push r12
  push r13

  cmp r10, 6      
  setge r11
  setl r12
  imul r8, r11, 6
  imul r9, r12, r10
  add r8, r9          ; r8 := min(6, num_req)

  dec r8              ; r8--
  imul r9, r8, 8      ; r9 := r8 * 8
  sub rsp, r9         ; make space on stack for r8 qwords



  ; TODO: push the values to the newly allocated space, do NOT use push ops

  jge va_start_stack  ; If there were 6 or more required args, all optionals on stack
  mov qword [rdi + 8], rsp
  ret

  va_start_stack:
    cmp rsi, 6
    ; No compiler support, handling >6 args isn't doable cleanly
    jg panic_too_many_req
    mov rcx, [rdi + 16]
    mov qword [rdi + 8], rcx

  va_start_exit:
    mov rsp, rbp
    pop rbp
    ret

  

; va_arg(va_list_t *ptr, size_t arg_size)
va_arg:
  mov rcx, [rdi]            ; Get the index of the argument to return
  cmp rcx, 6
  jge va_next_stack_handler

  ; Equality because we shouldnt be returning a required arg
  cmp rcx, 1
  jle panic_insufficient_args    

  va_next_register_handler:
    lea rax, [rdi + 8]          ; Store the `next` pointer in rax
    mov r10, rax                ; Copy to r10
    add r10, 8                  ; r10 := new `next` pointer
    mov rax, [rax]              ; Set return value
    
    cmp rcx 5                   ; Check if there are any more register args to return
    sete rdx 
    mov r9, rdx                 
    ; rdx := pointer to stack args if we just returned 5th arg, else 0  
    imul rdx, [rdi + 16]        
    ; r9 := pointer to next register args if we still have register args to 
    ; return, else 0
    imul r9, r10                
    ; Exactly one of rdx and r9 is 0. The correct next ptr is just their sum
    add rdx, r9
    mov qword [rdi + 8], rdx
    ret

  va_next_stack_handler:
    cmp rsi, 8
    ; panic: This library does not support arguments larger than 8 bytes
    jg panic_arg_too_big
    jl va_next_stack_4

    va_next_stack_8:
      lea rax, [rdi + 8]
      mov rcx, rax
      add rcx, 8
      mov qword [rdi + 8], rcx
      mov rax, [rax]
      ret
      
    ; For sizes 4 or less, we need to accumulate the bytes of the output in rdx,
    ; and the next address to read from the stack in rcx. 
    ; Don't write back to update the `next` pointer until we know we're done
    mov rdx, 0              ; Zero out rdx
    lea rcx, [rdi + 8]      ; rdx := next address to read data from
    va_next_stack_4:
      mov dword edx, [rcx]
      
      add rcx, 4            ; next byte to read is 4 higher on the stack
      sub rsi, 4            ; 4 less bytes to read

      cmp rsi, 0
      je va_stack_exit
      cmp rsi, 2
      jlt va_next_stack_1

    va_next_stack_2:
      shl rdx, 2
      mov word dx, [rcx]

      add rcx, 2
      sub rsi, 2

      cmp rsi, 0
      je va_stack_exit

    va_next_stack_1:
      shl rdx, 1
      mov byte dl, [rcx]

      add rcx, 1
      ; No need to maintain rsi and compare to 0 anymore

    va_stack_exit:
      mov qword [rdi + 8], rcx
      mov rax, rdx
      ret

  


panic_insufficient_args:
  mov rdi, req_args_lte_1
  call puts
  mov rax, 1
  call exit

panic_arg_too_big:
  mov rdi, arg_too_big
  call puts
  mov rax, 1
  call exit

panic_too_many_req
  mov rdi, too_many_req
  call puts
  mov rax, 1
  call exit

section .data

req_args_lte_1 db `Variadic functions must have at least 1 required argument\0`
arg_too_big db `Variadic arguments cannot be bigger than 8 bytes\0`
too_many_req db `Variadic functions can only contain 6 or fewer required arguments\0`