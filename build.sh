#!/bin/sh

CLR_R="\033[31m"
CLR_G="\033[32m"
CLR_RST="\033[0m"

pass() {
	printf "%-74s[${CLR_G}PASS${CLR_RST}]\n" "$1"
}

reset_fail() {
	FAIL=false
}

fail() {
	FAIL=true
	printf "%-74s[${CLR_R}FAIL${CLR_RST}]\n" "$1"
}

check_cmd() {
	if (which "$1" 2> /dev/null > /dev/null)
	then
		pass "$1"
	else
		fail "$1"
	fi
}

reset_fail

check_cmd make
check_cmd test
check_cmd wget
check_cmd uname
check_cmd cp
check_cmd mv
check_cmd rm
check_cmd mkdir
check_cmd tar
check_cmd realpath
check_cmd dirname
check_cmd readlink

if test $FAIL = true
then
	echo "Encountered errors!"
	echo "Please fix them before atteming to build"
fi
reset_fail

self_d=$(realpath $(dirname $(readlink -f ${0})))
if test "$1" = '--init-submodule'
then
	prj_d="$2"
	test "$prj_d" = '' && prj_d="$PWD"
	prj_d=$(realpath ${prj_d})
	test "$prj_d" = "$self_d" && exit 0
	rel_d=$(realpath --relative-to="$self_d" "$prj_d")
	if ! test -f "$prj_d/config.mk"
	then
		echo  "ARDUINO_PFM := arduino:avr"       >  "$prj_d/config.mk"
		echo  "ARDUINO_BRD := nano"              >> "$prj_d/config.mk"
		echo  "ARDUINO_CPU := atmega328"         >> "$prj_d/config.mk"
		echo  "ARDUINO_OUT := build"             >> "$prj_d/config.mk"
		echo  "ARDUINO_SRC := ${rel_d}/src"      >> "$prj_d/config.mk"
		echo  "ARDUINO_HOME := ${self_d}"        >> "$prj_d/config.mk"
		echo  "ARDUINO_SKETCH := main"           >> "$prj_d/config.mk"
		echo  "ARDUINO_CLI_VER := 0.20.2"        >> "$prj_d/config.mk"
		echo  "ARDUINO_FILE_BIN := bin"          >> "$prj_d/config.mk"
		echo  "ARDUINO_FILE_ETC := ${rel_d}/etc" >> "$prj_d/config.mk"
		echo  "ARDUINO_FILE_RES := .res"         >> "$prj_d/config.mk"
	fi
	cd "$self_d"
	rm -f config.mk
	ln -s "$prj_d/config.mk" config.mk
	make scaffold
elif test "$1" = '--compile'
then
	cd "$self_d"
	make compile
elif test "$1" = '--upload'
then
	cd "$self_d"
	make upload
elif test "$1" = '--all'
then
	cd "$self_d"
	make all
elif test "$1" = '--rebuild-toolchain'
then
	cd "$self_d"
	make remake-toolchain
else
	cd "$self_d"
	make compile
fi
