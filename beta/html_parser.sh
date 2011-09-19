#! /bin/bash

## parser one line
# usage: parser_line [line]
parser_line()
{
	local line="$1"
	local section=
	local index=0

	[[ -z $line ]] && { echo; return 0; }

	while [[ -n $line ]]; do
		if echo "$line" | egrep -v '<.+>' &> /dev/null; then
			section="$line"
			line=
		elif [[ -n ${line%%<*} ]]; then
			section="${line%%<*}"
			line="<${line#*<}"
		else
			section="${line%%>*}>"
			line="${line#*>}"
		fi
		echo "$section"
		((++index))
	done

	return $?
}

##
pre_keywords()
{
	local _tag=${_tag:-${FUNCNAME[0]}}

	local keyword=
	local keywords_list='html head meta script title body div a p form ul li style span img table tr td dl fieldset'

	for keyword in $keywords_list; { keywords[$keyword]=$keyword; }

	return $?
}

## 
declare -A keywords

## main
html_parser()
{
	local _tag=${_program:-${FUNCNAME[0]}}

	[[ $1 == --* ]] && { 
		echo "$_tag: version $_version"
		echo "$_tag: $_tag [ARGs]"
		return 0
	}

	## To do, call sub functions.
	local line=
	
	pre_keywords
	
	while read line; do
		parser_line "$line"
	done < $1 | tee ret.txt
	
	return $?
}

html_parser "$@"
