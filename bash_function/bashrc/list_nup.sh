#! /bin/bash

list_nup()
{
	local _tag=${_tag:-${FUNCNAME[0]}} 

    local _list_a="$1"
	local _list_b="$2"

	if [[ -f "$_list_a" ]] && [[ -f "$_list_b" ]]; then
		mkdir -p ./_list_nup
		cat "$_list_a" "$_list_b" | sort -u > ./_list_nup/u
		cat "$_list_a" ./_list_nup/u | sort | uniq -u > ./_list_nup/ap
		cat "$_list_b" ./_list_nup/u | sort | uniq -u > ./_list_nup/bp
		cat "$_list_a" "$_list_b" | sort | uniq -d > ./_list_nup/n
	fi

	return $?
}

list_nup "$@"
