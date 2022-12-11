# My implementations of standard and useful C functions

Exploring what's under the hood in C and learning x86-64 assembly by implementing
standard C libraries.

## Running code

Code will be tested in both assembly and C. To run the assembly test, simply run
`make`. For the C tests, run `make test`. C files are compiled with gcc and the
`-nostartfiles` and `-nostdlib` flags to allow my implementations to be used in
place of the standard libraries included by gcc. To run your own file with this
library, a convenient, quick-start way would be to overwrite `test.c`, or add
your own main C file to `src` and replacing the `TESTFILE` variable in `Makefile`

## Project organization

1. `src` contains various directories, each of which consists of assembly files.
   Every assembly file is named after the primary functionality it exposes globally.
   When compiled, every directory will be compiled to a separate static library.
   The `src` directory also includes 2 test files, `main.asm` and `test.c`, which
   can be compiled and run.
2. `include` directory contains header files for the compiled libraries. Every
   static library produced has its own header file.
3. Upon compilation, the `lib`, `bin`, and `build` directories will be created,
   and they store static libraries produced, test file binaries, and object files,
   respectively.

## Assumptions and Conventions

I will be using Intel syntax and using NASM. I couldn't find a definitive source
of truth for calling conventions. Based on what I've gathered, I will operate on
the following assumptions

1. Arguments are passed in the order `rdi`, `rsi`, `rdx`, `rcx`, `r8`, `r9`, then
   on the stack.
2. Return register is `rax`.
3. Callee saved registers are `rbx`, `rsp`, `rbp`, `r12` through `r15`.
4. All other registers can be clobbered in the bodies of functions assuming values
   are not needed later.
5. If a function does not touch memory besides through `call` and `ret`, the
   usual prologue-epilogue of push/pop `rbp` and swapping `rsp` and `rbp` will be
   omitted to reduce memory accesses.
