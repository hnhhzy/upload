#!/bin/bash

count=0

cp "$1" /tmp/$$.tmp
echo >> /tmp/$$.tmp

while read line; do
	if [[ $line != \<link* ]] && [[ $line != \<input* ]]; then
		if [[ $line == \<\/* ]]; then
			printf "%$((--count))s%s\n" ' ' "$line"
		elif [[ $line == \<* ]]; then
			printf "%$((count++))s%s\n" ' ' "$line"
		else
			echo "$line"
		fi
	else
		printf "%${count}s%s\n" ' ' "$line"
	fi
done < "/tmp/$$.tmp"

rm "/tmp/$$.tmp"
