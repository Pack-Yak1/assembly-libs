BIN=bin
BUILD=build
INC=include
SRC=src

# Define VERBOSE as an env variable if needed
ifndef VERBOSE
.SILENT:
endif

# The name of the static library generated
LIBNAME=libmystd.a

# The main c file to run
TESTFILE=$(SRC)/test.c

# The main assembly file to run
MAIN=main

# Files which the main assembly file depends on
TEST_DEPS=print puts stdio stdlib

# Files which the main c file depends on. C files will require a start file to
# declare _start which calls main and exits the program after. 
LIBC=$(TEST_DEPS) start

# These arguments will be passed to the test executable when run
TEST_ARGS=abc def ghi

TEST_DEPS_O=$(patsubst %, $(BUILD)/%.o, $(TEST_DEPS))
LIBC_O=$(patsubst %, $(BUILD)/%.o, $(LIBC))

# Compilation settings
FORMAT=elf64
CC=gcc
CFLAGS=-nostartfiles -Wall -Werror -z noexecstack
LDFLAGS=-z noexecstack


WORKDIRS=$(BIN) $(BUILD)
TARGETS=$(patsubst $(SRC)/%.asm, %, $(wildcard $(SRC)/*))
OBJECTS=$(patsubst %, $(BUILD)/%.o, $(TARGETS))
BINARIES=$(patsubst %, $(BIN)/%, $(TARGETS))

# Default behavior is to run the main assembly file
run: install $(BIN)/$(MAIN)
	./$(word 2, $^) $(TEST_ARGS)

# Prepare the workspace directory structure
install:
	mkdir -p $(WORKDIRS)

# Compile and run the test c file
test: install $(TESTFILE) $(LIBC_O)
	$(CC) $(CFLAGS) $(wordlist 2, $(words $^), $^) -o $(BIN)/test -I$(INC)
	./$(BIN)/test $(TEST_ARGS)

# Create the static library
lib: install $(OBJECTS)
	ar rcs $(BUILD)/$(LIBNAME) $^

# Create object files
$(BUILD)/%.o: $(SRC)/%.asm
	nasm -f$(FORMAT) $< -o $@

# Link and produce executables
$(BIN)/%: $(BUILD)/%.o $(TEST_DEPS_O)
	ld $(LDFLAGS) $^ -o $@

# Clean all object files and executables
clean:
	rm -rf $(BIN)/* $(BUILD)/* 

# Object files are useful, keep them
.PRECIOUS: build/%.o