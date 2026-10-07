TOP_NAME ?= tb_shifter
ROOT_DIR ?= $(shell pwd)

VERILATOR_QUIET += --quiet --quiet-build
VERILATOR_TRACE += --trace-fst --trace-params --trace-structs \
				   --timescale 1ns/1ps
VERILATOR_BASIC += -Wall --binary --build \
				   --timing -sv 

VERILATOR_FLAGS += $(VERILATOR_QUIET) $(VERILATOR_TRACE) $(VERILATOR_BASIC)

RTL_SRCS_DIR = $(ROOT_DIR)/rtl
RTL_SRCS = $(shell find $(RTL_SRCS_DIR) -name "*.v" -o -name "*.sv")

BUILD_DIR = $(ROOT_DIR)/build
EXECUTABLE = $(BUILD_DIR)/V$(TOP_NAME)

NPROC ?= $(shell nproc)

.DEFAULT_GOAL := all

$(EXECUTABLE): $(RTL_SRCS)
	@mkdir -p $(BUILD_DIR)
	@verilator $(VERILATOR_FLAGS) $(RTL_SRCS) --top-module $(TOP_NAME) \
		-Mdir $(BUILD_DIR) -j $(NPROC) -CFLAGS "-O2"

.PHONY: all clean
all: $(EXECUTABLE)
	@echo "Running Test $(TOP_NAME)"
	$(EXECUTABLE)

lint: 
	@verilator --lint-only -Wall $(VERILATOR_TRACE) $(RTL_SRCS) --top-module $(TOP_NAME)

clean:
	rm -rf $(BUILD_DIR)

