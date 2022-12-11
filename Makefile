BIN=bin
BUILD=build
INC=include
SRC=src
LIB=lib

# Define VERBOSE as an env variable if needed
ifndef VERBOSE
.SILENT:
endif

# Library names
LIBS=std io string
LIB_OBJS=$(patsubst $(SRC)/%.asm, $(BUILD)/%.o, $(wildcard $(patsubst %, $(SRC)/%/*, $(LIBS))))
LIBNAMES=$(patsubst %, $(LIB)/lib%.a, $(LIBS))

# Libraries which the test files depend on
TEST_DEPS=$(LIBS)
TEST_DEP_OBJS=$(patsubst $(SRC)/%.asm, $(BUILD)/%.o, $(wildcard $(patsubst %, $(SRC)/%/*, $(TEST_DEPS))))
TEST_DEP_LIBNAMES=$(patsubst %, $(LIB)/lib%.a, $(TEST_DEPS))

# The main c file to run
TESTFILE=$(SRC)/test.c
# These arguments will be passed to the test executable when run
TEST_ARGS=abc def ghi

# The main assembly file to run
MAIN=main

# Compilation settings
FORMAT=elf64
CC=gcc
CFLAGS=-nostartfiles -Wall -Werror -z noexecstack -g -nostdlib -ffreestanding
LDFLAGS=-z noexecstack

WORKDIRS=$(BIN) $(BUILD) $(LIB) $(patsubst %, $(BUILD)/%, $(LIBS))
TARGETS=$(join $(wildcard $(SRC)/*/*), $(wildcard $(SRC)/*))

# Default behavior is to run the test assembly file
run: install $(BIN)/main
	./$(BIN)/main

# Compile the test C file and run it
test: install $(TESTFILE) $(TEST_DEP_LIBNAMES)
	$(CC) $(CFLAGS) $(wordlist 2, $(words $^), $^) -o $(BIN)/test -I$(INC)
	./$(BIN)/test $(TEST_ARGS)

# Prepare the workspace directory structure
install:
	mkdir -p $(WORKDIRS)

# General rule for making libraries
$(LIB)/lib%.a: install $(LIB_OBJS)
	ar rcs $@ $(patsubst $(LIB)/lib%.a, $(BUILD)/%/*, $@)

# Create all static libraries
libs: install $(LIBNAMES)
	ar rcs $(BUILD)/$(LIBNAME) $^

# Create object files
$(BUILD)/%.o: $(SRC)/%.asm
	nasm -f$(FORMAT) $< -o $@

# Link and produce executables
$(BIN)/%: $(BUILD)/%.o $(TEST_DEP_LIBNAMES)
	ld $(LDFLAGS) $^ -o $@

# Clean all object files and executables
clean:
	rm -rf $(BIN)/* $(BUILD)/* $(LIB)/*

# Object files are useful, keep them
.PRECIOUS: build/%.o