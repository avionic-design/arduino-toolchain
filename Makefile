# default settings
ARDUINO_PFM := arduino:avr
ARDUINO_BRD := nano
ARDUINO_CPU := atmega328

# derived variables
ARDUINO_OPT_CPU := $(shell /bin/sh -c "test -n '$(ARDUINO_CPU)' && echo ':cpu=$(ARDUINO_CPU)'")
ARDUINO_BRD_FQBN := $(ARDUINO_PFM):$(ARDUINO_BRD)$(ARDUINO_OPT_CPU)

.PHONY: compile upload all clean mrproper distclean
.DEFAULT_GOAL := compile

print_config:
	@printf "PLATFORM: %s\n" "$(ARDUINO_PFM)"
	@printf "BOARD   : %s\n" "$(ARDUINO_BRD)"
	@printf "CPU     : %s\n" "$(ARDUINO_CPU)"
	@printf "FQBN    : %s\n" "$(ARDUINO_BRD_FQBN)"

compile: print_config _compile
_compile:

upload: print_config _upload
_upload:

all: print_config _compile _upload

clean:

mrproper: clean

distclean: mrproper

