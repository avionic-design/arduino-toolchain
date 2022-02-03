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

if test $FAIL = true
then
	echo "Encountered errors!"
	echo "Please fix them before atteming to build"
fi
reset_fail

make compile
