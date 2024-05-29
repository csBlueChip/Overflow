###############################################################################
#
# MIT License
#
# Copyright (c) 2024 csBlueChip
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#
###############################################################################

#------------------------------------------------------------------------------
# Parentheses and Braces        : $(makefile-varible) .. ${bash-variable}
# Set make-var from BASh output : $(eval VAR=$(shell echo value))
# Do not echo command           : @command

SHELL=/bin/bash

#------------------------------------------------------------------------------
# List of source files
SRC=overflow.c

# Name of output file
EXE=overflow
EXTRAS=$(wildcard  *.i  *.o  *.s  a.out)

# helper directory - your scripts here
HELPER=helper/

#------------------------------------------------------------------------------
# Tools may be different on other platforms
#
ECHO=echo
CAT=cat
RM=rm
CP=cp
RMF=$(RM) -f
SUDO=sudo
UPDATE=$(SUDO) apt-get update
INSTALL=$(SUDO) apt-get install

#------------------------------------------------------------------------------
# Some basic tools
# `luit` is used to force an encoding standard while running the program
# `cgdb` is a wrapper for `gdb` which is very nice
#        ...change it to `gdb` if you prefer.
#
PACKAGES=build-essential xxd cgdb

#------------------------------------------------------------------------------
LOGR:=$(shell mktemp log_XXXXXX)
LOGI=$(LOGR).in
LOGO=$(LOGR).out
LOGT=$(LOGR).tmp

EXTRAS+=[0-9]*--*  log_??????*

#------------------------------------------------------------------------------
# Compiler details
#
CC=gcc

# -g                   : include debug info
# -fno-stack-protector : disable stack protection
CFLAGS=-g -o0 -fno-stack-protector -Wno-format-security  -Wno-format 
#-z execstack

ifeq (${AUTOFRANK}, Y)
	CFLAGS+=-DAUTOFRANK
endif

#------------------------------------------------------------------------------
# "default" MUST BE THE FIRST TARGET
#
# "default" is a user-friendly feature offered by the makefile
# ...it is NOT the name of a file!
# ...therefore, it is "PHONY"
#
.PHONY: default
default: help

#------------------------------------------------------------------------------
.PHONY: help
help:
	@$(ECHO) "# all, exe, $(EXE) - build the program"
	@$(ECHO) "# run         - run the program"
	@$(ECHO) "# clean       - erase crashlogs & build files"
	@$(ECHO) "# symbols     - dump the symbol table"
	@$(ECHO) "# memmap      - dump the memory map"
	@$(ECHO) "# disasm      - show disassembly"
	@$(ECHO) "# coreinfo    - extract data from coredump ID=<pid>"
	@$(ECHO) "# help        - this help"
	@$(ECHO) ""
	@$(ECHO) "# setup       - install required packages {$(PACKAGES)}"
	@$(ECHO) ""
	@$(ECHO) "# make exe AUTOFRANK=Y will inject the autofrank code (if you have it)"
	
#	@$(ECHO) ""
#	# https://stackoverflow.com/a/38415982/2476535
#	@$(ECHO) "NB. Enable \`make\` target completion with:"
#	@$(ECHO) "    complete -W "\`grep -oE '^[a-zA-Z0-9_.-]+:([^=]|$)' Makefile | sed 's/[^a-zA-Z0-9_.-]*$//'\`" make"
#	@$(ECHO) "    ...maybe add it to: ~/.bashrc"

#------------------------------------------------------------------------------
.PHONY: setup
setup:
	$(UPDATE)
	@$(ECHO) "-----------------------------"
	$(INSTALL) $(PACKAGES)

#------------------------------------------------------------------------------
.PHONY: clean
clean:
	$(RMF) $(EXE) $(EXTRAS) $(HELPER)/$(EXE)

#------------------------------------------------------------------------------
# Friendly redirector
#
.PHONY: all
all: $(EXE)

#----------------------------------------------------------
.PHONY: exe
exe:
	@echo "makeflags: $(MAKEFLAGS)"
	@$(RMF) $(EXE)
	@make --no-print-directory $(EXE) 

#----------------------------------------------------------
# The EXE will update if any of the SRC files have a 
# timestamp more recent that EXE
#
$(EXE): $(SRC)
	$(RMF) $(EXE) $(HELPER)/$(EXE)
	$(CC) $(SRC)  $(CFLAGS) -o $(EXE)
	@[[ -f $(EXE) && -d $(HELPER) ]] && $(CP) $(EXE) $(HELPER)/ || true

#------------------------------------------------------------------------------
# We need to be sure `luit` is complete before we parse it's output
# ...So we ensure "run" will execute AFTER "luitrun" is complete
#
.PHONY: run
run: script logging

#----------------------------------------------------------
.PHONY: script
script: $(EXE)
	(	ulimit -c unlimited ;\
		script --return --log-in $(LOGI) --log-out $(LOGO) --flush --command "./$(EXE) 2>&1" \
	) || true

#----------------------------------------------------------
.PHONY: logging
logging:
	$(eval PID=$(shell grep 'ID:' $(LOGO) | cut -d' ' -f5 ))

	$(eval LOGP="$(PID)--log.txt")

	@ >$(LOGP) $(ECHO) "LOGR: $(LOGR)"
	@>>$(LOGP) $(ECHO) ""
	@>>$(LOGP) $(ECHO) "------------"
	@>>$(LOGP) $(ECHO) " Screen Log"
	@>>$(LOGP) $(ECHO) "------------"
	@>>$(LOGP) cat $(LOGO)

	@>>$(LOGP) $(ECHO) ""
	@>>$(LOGP) $(ECHO) "-----------"
	@>>$(LOGP) $(ECHO) " Input Log"
	@>>$(LOGP) $(ECHO) "-----------"

	@>>$(LOGP) $(ECHO) ""
	@`sed '1d;$$d' $(LOGI) | head -c -1 | hexdump -C | head -n -1 >>$(LOGP)`

	@>>$(LOGP) $(ECHO) ""
	@>>$(LOGP) stty -a

	@>>$(LOGP) $(ECHO) ""
	@$(eval L=$(shell stty -g | sed -E 's/([^:]*:){19}([^:]*).*/\2/'))

	@`sed '1d;$$d' $(LOGI)         \
		| head -c -1               \
		| xxd -p                   \
		| tr -d '\n'               \
		| sed 's/\(..\)/\1 /g'     \
		| sed 's/$(L) \(..\)/\1/g' \
		| xxd -p -r                \
		| hexdump -C               \
		| head -n -1               \
	>>$(LOGP)`

	@$(RMF) $(LOGR) $(LOGO) $(LOGI) $(LOGT)

	@[ -f core ] && ( \
		mv  core  $(PID)--core ;\
		printf "\n\nTry: \`make coreinfo ID=%s\`\n" $(PID) \
	) || true

#------------------------------------------------------------------------------
# Explore `objdump`
#
.PHONY: symbols
symbols: $(EXE)
	objdump -t $(EXE)

#----------------------------------------------------------
# Explore `/proc/<pid>/*`
#
.PHONY: memmap
memmap: $(EXE)
	$(eval PID=$(shell pgrep $(EXE)))
	@[ -z "$(PID)" ] && $(ECHO) "! $(EXE) not running" || true
	@[ -n "$(PID)" ] || false
	$(CAT) /proc/$(PID)/maps

#----------------------------------------------------------
# This could certainly be improved
#
.PHONY: disasm
disasm: $(EXE)
	objdump $(EXE) -S --disassemble

#------------------------------------------------------------------------------
# Use: make coreinfo ID=<PID>
# Note the use of "\$$" to get a "$" to the gdb command line
# The prefixing `echo` causes gdb to terminate after the commands
# The suffixing `grep .` removes the colour from the gdb output
#
.PHONY: coreinfo
coreinfo: $(ID)--core
	$(eval CTMP=$(shell mktemp core_XXXXXX))
	@$(CP)  "$(ID)--core"  "$(CTMP)"
	$(ECHO) | 2>&1 gdb -q \
		overflow "$(CTMP)" \
		-ex "echo -----[ info reg ]-----\n" \
		-ex "info reg" \
		-ex "echo -----[ info stack ]-----\n" \
		-ex "info stack" \
		-ex "echo -----[ x/16x \$$rsp-0x40 ]-----\n" \
		-ex "x/16x \$$rsp-0x40" \
		-ex "echo -----[ x/16x \$$rsp ]-----\n" \
		-ex "x/16x \$$rsp" \
	| grep .
	@$(ECHO) ""
	@$(RMF) $(CTMP)
