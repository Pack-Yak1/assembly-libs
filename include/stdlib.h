#define stdin 0
#define stdout 1
#define size_t unsigned long

extern void print(const char *buf, size_t len);
extern void print_hex(unsigned long val);
extern int puts(const char *buf);

extern char *fgets(const char *buf, size_t n, int fd);

extern void exit(int status);
