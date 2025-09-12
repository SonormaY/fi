CC      := gcc
CFLAGS  := -Wall -Werror -O2
TARGET  := fi

SRCS_DIR    := src
HEADERS_DIR := $(SRCS_DIR)/headers
BUILD_DIR   := build

SRCS   := $(shell find $(SRCS_DIR) -name '*.c')
OBJS   := $(patsubst $(SRCS_DIR)/%.c,$(BUILD_DIR)/%.o,$(SRCS))

$(BUILD_DIR)/$(TARGET): $(OBJS)
	$(CC) $(CFLAGS) $^ -o $@

$(BUILD_DIR)/%.o: $(SRCS_DIR)/%.c | $(BUILD_DIR)
	$(CC) $(CFLAGS) -c $< -o $@

$(BUILD_DIR):
	mkdir -p $@

run: $(BUILD_DIR)/$(TARGET)
	$<

valgrind: $(BUILD_DIR)/$(TARGET)
	valgrind --leak-check=full --show-leak-kinds=all \
	         --track-origins=yes --verbose $<

cppcheck:
	cppcheck --enable=all --inconclusive \
	         --suppress=missingIncludeSystem $(SRCS_DIR) $(HEADERS_DIR)

debug: CFLAGS = -Wall -Werror -g
debug: clean $(BUILD_DIR)/$(TARGET)

.PHONY: clean run valgrind cppcheck debug
clean:
	rm -rf $(BUILD_DIR)
