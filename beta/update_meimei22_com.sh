#! /bin/bash

# all_img_sync [prefix]
all_img_sync()
{
	local num=4
	local indexlist=(
		http://www.meimei22.com/mm/qingliang/
		http://www.meimei22.com/mm/jingyan/
		http://www.meimei22.com/mm/bagua/
		http://www.meimei22.com/mm/suren/
		)
	local dirlist=(
		qingliang
		jingyan
		bagua
		suren
		)
	local cagelist=(
		清凉美女
		惊艳美女
		美女八卦
		素人美女
		)
	local prefix=${1:-.}
	local lastlink=
	local nextlink=
	local iter=
	local htmlfile=

	for ((iter=3; iter<4; ++iter)); {
		#mkdir -v -p $prefix/${dirlist[$iter]}
		#echo ${cagelist[$iter]} > $prefix/${dirlist[$iter]}/cage
		pushd $prefix/${dirlist[$iter]}
		#[[ ! -e lastlink ]] && touch lastlink
		wget -c -nv ${indexlist[$iter]}
		nextlink="http://www.meimei22.com"$(sed 's;";\n;g' index.html | grep "${dirlist[$iter]}.*html" | sed -n '15p')
		rm index.html
		nextlink='http://www.meimei22.com/mm/suren/081231$74857.html'
		lastlink=$(cat lastlink)
		[[ $nextlink != $lastlink ]] && {
			echo $nextlink > lastlink
			while [[ $nextlink != $lastlink ]]; do
				wget -c -nv $nextlink
				nextlink="http://www.meimei22.com/mm/"${dirlist[$iter]}/$(sed 's;";\n;g' ${nextlink##*/} | sed -n '/ShowPage/,/<script>/ p' | grep html | tail -1)
			done
			for htmlfile in $(ls | grep '\.html$' | grep -v '-'); {
				mkdir -v -p ${htmlfile%.html}
				sed 's;<strong class="fColor title">;\n;' $htmlfile | tail -1 | cut -d\< -f1 > ${htmlfile%.html}/title
				sed 's;]=";\n;g' ${htmlfile%.html}*.html | grep -v '<!DOCTYPE HTML PUBLIC ' | cut -d\" -f1 > ${htmlfile%.html}/img.list
			}
		}
		popd
	}

	return $?
}

all_img_sync

exit $?
