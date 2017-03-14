CC=gcc
LD=gcc
RM=rm
MKDIR=mkdir

SRC_PATH=./src/
INCLUDE_PATH=-I$(SRC_PATH)/utils/
BIN_PATH=./bin/
ASM_PATH=$(SRC_PATH)/utils/ASM/

BIN=cliente servidor audio_listener
BINS=$(addprefix $(BIN_PATH)/, $(BIN))
OBJECTS=$(foreach b, $(BIN), $(SRC_PATH)/$(b)/main.o) $(ASM_O)

UTIL_C ?= $(wildcard $(SRC_PATH)/utils/*.c)
UTIL=$(patsubst %.cpp, %.o, $(UTIL_C))

ASM_O= $(ASM_PATH)SIMD_AudioFilter.o

CFLAGS=-Wall $(INCLUDE_PATH) -Wextra -g
LDFLAGS=-lpthread 

.PHONY: all

.PRECIOUS: %.o

all: $(BIN_PATH) $(BINS)

$(BIN_PATH):
	$(MKDIR) $(BIN_PATH)

$(BINS): $(UTIL) $(OBJECTS)
	$(CC) $(SRC_PATH)/$(@F)/main.o $(UTIL) $(ASM_O) $(CFLAGS)   -o $@ $(LDFLAGS)

$(ASM_PATH)SIMD_AudioFilter.o: 
	@echo "> Compilando AudioFilter.o.... "
	nasm -f elf64 $(ASM_PATH)/SIMD_AudioFilter.asm -l SIMD_AudioFilter.lst -o $@
	@echo "> Compilando lib64.o....OK "
	@echo	
	
	
clean:
	- $(RM) -f $(SRC_PATH)/*/*.o
	- $(RM) -f $(ASM_PATH)/*.o
	- $(RM) -f -r $(BIN_PATH)

%.o: %.cpp
	$(CC) -c $(CFLAGS) -o "$@" "$<"
