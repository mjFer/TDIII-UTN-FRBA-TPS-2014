CC=gcc
LD=gcc
RM=rm
MKDIR=mkdir

SRC_PATH=./src/
INCLUDE_PATH=-I$(SRC_PATH)/utils/
BIN_PATH=./bin/

BIN=child1 child2 ejercicio
BINS=$(addprefix $(BIN_PATH)/, $(BIN))
OBJECTS=$(foreach b, $(BIN), $(SRC_PATH)/$(b)/main.o)

UTIL_C ?= $(wildcard $(SRC_PATH)/utils/*.c)
UTIL=$(patsubst %.cpp, %.o, $(UTIL_C))

CFLAGS=-Wall $(INCLUDE_PATH) -Wextra -g
LDFLAGS=-lpthread 

.PHONY: all

.PRECIOUS: %.o

all: $(BIN_PATH) $(BINS)

$(BIN_PATH):
	$(MKDIR) $(BIN_PATH)

$(BINS): $(UTIL) $(OBJECTS)
	$(CC) $(SRC_PATH)/$(@F)/main.o $(UTIL) $(CFLAGS) -o $@ $(LDFLAGS)

clean:
	- $(RM) -f $(SRC_PATH)/*/*.o
	- $(RM) -f -r $(BIN_PATH)

%.o: %.cpp
	$(CC) -c $(CFLAGS) -o "$@" "$<"
