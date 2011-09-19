#! /bin/bash

# Global VARs
unset TAG

# A templete for bash script
# usage: templete_for_bash_script
templete_for_bash_script() {

	# Debug switcher & local TAG
	# example: $DBG && echo $TAG:...
	local DBG=true
	local TAG=${TAG-${FUNCNAME[0]}}

	# TODO
	$DEB && echo $TAG: Hello World!

	return $?
}

# Main
templete_for_bash_script "$@"
