# project specific config to load
PROJECT_CONFIG := config.mk

# host arch
BIT := $(shell /bin/sh -c 'if test  "$$(uname -i)" = x86_64; then echo 64bit; else echo 32bit; fi')

# default settings
ARDUINO_PFM := arduino:avr
ARDUINO_BRD := nano
ARDUINO_CPU := atmega328
ARDUINO_CLI_VER := 0.20.2
ARDUINO_CLI_LNK := https://github.com/arduino/arduino-cli/releases/download
ARDUINO_FILE_RES := .res

# include project settings (may override defaut settings)
-include ./$(PROJECT_CONFIG)

# derived variables
ARDUINO_CLI_PKG := $(ARDUINO_FILE_RES)/arduino-cli.tar.gz
ARDUINO_CLI_TAR := arduino-cli_$(ARDUINO_CLI_VER)_Linux_$(BIT).tar.gz
ARDUINO_OPT_CPU := $(shell /bin/sh -c "test -n '$(ARDUINO_CPU)' && echo ':cpu=$(ARDUINO_CPU)'")
ARDUINO_BRD_FQBN := $(ARDUINO_PFM):$(ARDUINO_BRD)$(ARDUINO_OPT_CPU)

.PHONY: compile upload all clean mrproper distclean
.DEFAULT_GOAL := compile

print_config:
	@printf "PLATFORM: %s\n" "$(ARDUINO_PFM)"
	@printf "BOARD   : %s\n" "$(ARDUINO_BRD)"
	@printf "CPU     : %s\n" "$(ARDUINO_CPU)"
	@printf "FQBN    : %s\n" "$(ARDUINO_BRD_FQBN)"

$(ARDUINO_CLI_PKG):
	mkdir --parents $(ARDUINO_FILE_RES)
	-rm -f $(ARDUINO_FILE_RES)/$(ARDUINO_CLI_LNK)/$(ARDUINO_CLI_VER)/$(ARDUINO_CLI_TAR)
	cd $(ARDUINO_FILE_RES) \
	   && wget $(ARDUINO_CLI_LNK)/$(ARDUINO_CLI_VER)/$(ARDUINO_CLI_TAR)
	mv $(ARDUINO_FILE_RES)/$(ARDUINO_CLI_TAR) $(ARDUINO_CLI_PKG)

compile: print_config _compile
_compile:

upload: print_config _upload
_upload:

all: print_config _compile _upload

clean:

mrproper: clean

distclean: mrproper
	rm -rf $(ARDUINO_FILE_RES)
