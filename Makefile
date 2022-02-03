.PHONY: compile upload all clean mrproper distclean
.DEFAULT_GOAL := compile

compile:
_compile: compile

upload:
_upload: upload

all: print_config _compile _upload

clean:

mrproper: clean

distclean: mrproper

