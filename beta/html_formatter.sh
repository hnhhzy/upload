#! /bin/bash

# usage: format htmlfile
format() {

	local line=
	local count=1

	while read line; do
		if echo "$line" | egrep '^<[^!].+>$' &>/dev/null; then
			if echo "$line" | grep '^</' &>/dev/null; then
				printf "%$((--count))s%s\n" ' ' "$line" 
				continue
			elif echo "$line" | grep -v '/>$' &>/dev/null; then
				printf "%$((count++))s%s\n" ' ' "$line" 
				continue
			else
				printf "%${count}s%s\n" ' ' "$line" 
			fi
		else
			printf "%s%s\n" ' ' "$line" 
		fi
	done < "$1" | tee "${2:-ret.html}"

	return $?
}

# usage: parser htmlfile [outfile]
parser() {

	local line=

	while read line; do
		while [[ -n $line ]]; do
			if echo "$line" | egrep -v '<.+>' &> /dev/null; then
				echo -n "$line"
				line=
			elif [[ -n ${line%%<*} ]]; then
				echo -n "${line%%<*}"
				line="<${line#*<}"
				[[ -n $line ]] && echo
			else
				echo -n "${line%%>*}>"
				line="${line#*>}"
				[[ -n $line ]] && echo
			fi
		done
		echo
	done < "$1" | tee parsered.html

	return $?
}

##
#declare -A keywords
#
#pre_keywords() {
#
#	local keyword=
#	local keywords_list='html head meta script title body div a p form ul li style span img table tr td dl fieldset'
#
#	for keyword in $keywords_list; { keywords[$keyword]=$keyword; }
#
#	return $?
#}

# usage: html_formatter htmlfile
html_formatter() {

	# Debug switcher & local TAG
	# example: $DBG && echo $TAG:...
	local DBG=true
	local TAG=${TAG:-${FUNCNAME[0]}}
	
	[[ $1 == --* ]] && { 
		echo "$TAG: version $_version"
		echo "$TAG: $TAG htmlfile"
		return 0
	}

	[[ ! -f $1 ]] && return 1

	parser "$1"
	#format parsered.html "$2"
	#rm parsered.html
	
	return $?
}

# Script can be used as a program or a function
if echo $0 | grep -v '^bash$' &> /dev/null; then

	# Global VARs
	unset TAG

	# Main
	html_formatter "$@"
fi
