#include "std.h"

#ifndef __IO
#define __IO

#define stdin 0
#define stdout 1

extern void print(const char *buf, size_t len);
extern void print_hex(unsigned long val);
extern void print_uint(unsigned int val);
extern int puts(const char *buf);
extern int putc(char c);

extern char *fgets(const char *buf, size_t n, int fd);

#endif