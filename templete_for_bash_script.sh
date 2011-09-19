#! /bin/bash

# A templete for bash script
# usage: templete_for_bash_script
templete_for_bash_script() {

	# Debug switcher & local TAG
	# example: $DBG && echo $TAG:...
	local DBG=true
	local TAG=${TAG:-${FUNCNAME[0]}}

	# TODO
	$DBG && echo $TAG: Hello World!

	return $?
}

# Script can be used as a program or a function
if echo $0 | grep -v '^bash$' &> /dev/null; then

	# Global VARs
	unset TAG

	# Main
	templete_for_bash_script "$@"
fi
