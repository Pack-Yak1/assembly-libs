#ifndef __VARIADIC
#define __VARIADIC

// Currently only supports variadic arguments which are 8 bytes or less on
// x86-64 machines

typedef struct va_list_t;

// Differs from stdarg interface. Takes a ptr to a va_list and the number of
// required parameters.
#define va_init(va_list, num_req) va_start(va_list, num_req)
#define va_next(va_list, arg_typ) va_arg(va_list, sizeof(arg_typ))

#endif