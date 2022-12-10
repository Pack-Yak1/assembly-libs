#include "stdlib.h"

int main(int argc, char **argv) {
  // Test print
  print("Enter something:\n", 18);
  char buf[11];

  // Test fgets and puts together
  const char *got = fgets(buf, 11, 0);
  puts("The first 10 (or fewer) characters of what you entered were: ");
  puts(got);

  puts(
      "Trying to print 1311768467294899695 as a hex number (Expected: "
      "0x1234567890abcdef)");

  // Test print_hex
  print_hex(1311768467294899695l);

  // Test that _start loaded argc and argv correctly
  print("The number of arguments this program received was: ", 51);
  print_hex(argc);
  puts("Listing string arguments received:");
  for (int i = 0; i < argc; i++) {
    puts(argv[i]);
  }

  // Test strlen
  char *msg = "If this message shows completely, strlen works\n";
  size_t msg_len = strlen(msg);
  print(msg, msg_len);

  puts("Testing print_uint:");
  print("Strlen on a length 47 string (excluding null byte) returned: ", 62);
  print_uint(msg_len);
}