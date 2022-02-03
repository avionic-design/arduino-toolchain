# project specific config to load
PROJECT_CONFIG := config.mk

# host arch
BIT := $(shell /bin/sh -c 'if test  "$$(uname -i)" = x86_64; then echo 64bit; else echo 32bit; fi')

# default settings
ARDUINO_PFM := arduino:avr
ARDUINO_BRD := nano
ARDUINO_CPU := atmega328
ARDUINO_OUT := build
ARDUINO_SRC := src
ARDUINO_HOME := $(PWD)
ARDUINO_SKETCH := main
ARDUINO_CLI_VER := 0.20.2
ARDUINO_CLI_LNK := https://github.com/arduino/arduino-cli/releases/download
ARDUINO_FILE_BIN := bin
ARDUINO_FILE_ETC := etc
ARDUINO_FILE_RES := .res

# include project settings (may override defaut settings)
-include ./$(PROJECT_CONFIG)

# derived variables
ARDUINO_CLI_PKG := $(ARDUINO_FILE_RES)/arduino-cli.tar.gz
ARDUINO_CLI_BIN := $(ARDUINO_FILE_BIN)/arduino-cli
ARDUINO_CLI_CMD := HOME=$(ARDUINO_HOME) ./$(ARDUINO_FILE_BIN)/arduino-cli
ARDUINO_CLI_YML := $(ARDUINO_FILE_ETC)/arduino-cli.yml
ARDUINO_CLI_TAR := arduino-cli_$(ARDUINO_CLI_VER)_Linux_$(BIT).tar.gz
ARDUINO_OPT_CPU := $(shell /bin/sh -c "test -n '$(ARDUINO_CPU)' && echo ':cpu=$(ARDUINO_CPU)'")
ARDUINO_INO_FILE := $(ARDUINO_SKETCH).ino
ARDUINO_INO_PATH := $(ARDUINO_SRC)/$(ARDUINO_INO_FILE)
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

$(ARDUINO_CLI_BIN): $(ARDUINO_CLI_PKG)
	mkdir --parents $(ARDUINO_FILE_BIN)
	-rm -f $(ARDUINO_CLI_BIN)
	cd bin && tar xvf ../$(ARDUINO_CLI_PKG) arduino-cli
	# update timestamp since arduino-cli is older then the tar
	touch $(ARDUINO_CLI_BIN)

$(ARDUINO_CLI_YML):
	mkdir --parents $(shell dirname $(ARDUINO_CLI_YML))
	echo "---"                >  $(ARDUINO_CLI_YML)
	echo "board_manager:"     >> $(ARDUINO_CLI_YML)
	echo "  additional_urls:" >> $(ARDUINO_CLI_YML)

$(ARDUINO_INO_PATH):
	mkdir --parents $(ARDUINO_SRC)
	echo -e ''                                   >  $(ARDUINO_INO_PATH)
	echo -e 'void setup(void)'                   >> $(ARDUINO_INO_PATH)
	echo -e '{'                                  >> $(ARDUINO_INO_PATH)
	echo -e "\tpinMode(LED_BUILTIN, OUTPUT);"    >> $(ARDUINO_INO_PATH)
	echo -e '}'                                  >> $(ARDUINO_INO_PATH)
	echo -e ''                                   >> $(ARDUINO_INO_PATH)
	echo -e 'void loop(void)'                    >> $(ARDUINO_INO_PATH)
	echo -e '{'                                  >> $(ARDUINO_INO_PATH)
	echo -e "\tdigitalWrite(LED_BUILTIN, HIGH);" >> $(ARDUINO_INO_PATH)
	echo -e "\tdelay(1000);"                     >> $(ARDUINO_INO_PATH)
	echo -e "\tdigitalWrite(LED_BUILTIN, LOW);"  >> $(ARDUINO_INO_PATH)
	echo -e "\tdelay(1000);"                     >> $(ARDUINO_INO_PATH)
	echo -e '}'                                  >> $(ARDUINO_INO_PATH)

.arduino-index: $(ARDUINO_CLI_BIN) $(ARDUINO_CLI_YML)
	$(ARDUINO_CLI_CMD) core update-index --config-file $(ARDUINO_CLI_YML)
	touch .arduino-index

.arduino-platform: .arduino-index
	$(ARDUINO_CLI_CMD) core install $(ARDUINO_PFM) --config-file $(ARDUINO_CLI_YML)
	touch .arduino-platform

.toolchain: .arduino-platform
	@if test -f $(ARDUINO_FILE_ETC)/toolchain.post;                 \
	then                                                            \
		./$(ARDUINO_FILE_ETC)/toolchain.post "$(ARDUINO_HOME)"; \
	fi
	touch .toolchain

compile: print_config _compile
_compile: .toolchain $(ARDUINO_INO_PATH)
	rm -rf $(ARDUINO_OUT)
	mkdir --parents $(ARDUINO_OUT)/$(ARDUINO_SKETCH)
	cp -rT $(ARDUINO_SRC) $(ARDUINO_OUT)/$(ARDUINO_SKETCH)
	$(ARDUINO_CLI_CMD) compile --fqbn $(ARDUINO_BRD_FQBN)       \
	                           --output-dir $(ARDUINO_OUT)      \
	                           $(ARDUINO_OUT)/$(ARDUINO_SKETCH)

upload: print_config _upload
_upload:

all: print_config _compile _upload

clean:
	rm -rf $(ARDUINO_OUT)

mrproper: clean
	rm -f .toolchain
	rm -f .arduino-index
	rm -f .arduino-platform
	$(ARDUINO_CLI_CMD) cache clean

distclean: mrproper
	rm -rf $(ARDUINO_FILE_BIN)
	rm -rf $(ARDUINO_FILE_RES)
	rm -rf $(ARDUINO_HOME)/.arduino15
