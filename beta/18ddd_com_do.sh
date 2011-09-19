#! /bin/bash -x

# list_filter rule file|list [prefix]
list_filter()
{
	local files=$2
	local prefix=${3:-.}
	
	[[ $2 = *.list ]] && files=$(cat $2)
	
	mkdir -p $prefix

	case $1 in
	img)
		sed -n '/<h1>/ s;<h1>\(.*\)</h1>.*;\1; p' $files > $prefix/title
		sed -n '/<a href="http:\/\/www.63aaa.com" target=_blank>/ s;.*<img src=";; p' $files | cut -d\" -f1 > $prefix/img.list
		;;
	txt)
		sed -n '/<div id="MyContent">/,/<\/td><\/tr><\/table>/ p' $files | \
			sed	-e 's;<[^>]*>;;g' \
				-e 's/&hellip;/…/g' \
				-e 's/&rdquo;/”/g' \
				-e 's/&ldquo;/“/g' \
				-e 's/&times;/X/g' \
				-e 's/&quot;/"/g' \
				-e 's/&mdash;/—/g' \
				-e 's/&nbsp;/ /g' \
				> $prefix/${files%.htm*}.txt
		;;
	html)
		local link_prefix='http://www.14ccc.com/'
		sed 's;<a href=";\n;g' $files | grep '^/htm' | cut -d\" -f1 | sed "s;^;$link_prefix;" > $prefix/html.list
		;;
	esac
}

list_filter "$@"
