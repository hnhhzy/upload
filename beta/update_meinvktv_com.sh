#! /bin/bash -x

# all_img_sync [prefix]
all_img_sync()
{
	local num=6
	local indexlist=(
		http://www.meinvktv.com/qingchunliangli/
		http://www.meinvktv.com/xingganmeinv/
		http://www.meinvktv.com/rihanmeinv/
		http://www.meinvktv.com/siwameitui/
		http://www.meinvktv.com/lianglichemo/
		http://www.meinvktv.com/mingxingmeinv/
		)
	local dirlist=(
		qingchunliangli
		xingganmeinv
		rihanmeinv
		siwameitui
		lianglichemo
		mingxingmeinv
		)
	local cagelist=(
		清纯靓丽
		性感美女
		日韩美女
		丝袜美腿
		靓丽车模
		明星美女
		)
	local prefix=${1:-.}
	local lastlink=
	local nextlink=
	local iter=
	local htmlfile=

	for ((iter=0; iter<num; ++iter)); {
		#mkdir -v -p "$prefix/${dirlist[$iter]}"
		#echo ${cagelist[$iter]} > $prefix/${dirlist[$iter]}/cage
		pushd "$prefix/${dirlist[$iter]}"
		#[[ ! -e lastlink ]] && echo ${indexlist[$iter]} > lastlink
		wget -c -nv ${indexlist[$iter]}
		nextlink=$(grep '<div class="src">' index.html | head -1 | cut -d\" -f4)
		rm index.html
		lastlink=$(cat lastlink)
		[[ $nextlink != $lastlink ]] && {
			echo $nextlink > $prefix/lastlink
			while [[ $nextlink != $lastlink ]]; do
				wget -c -nv $nextlink
				nextlink=$(sed -n '/<div class="content" id="content">/ p' ${nextlink##*/} | cut -d\' -f2)
			done
			for htmlfile in $(ls | grep '\.html$' | grep -v '_'); {
				mkdir -v -p ${htmlfile%.html}
				sed -n '/<h1>/ p' $htmlfile | sed -e 's;.*<h1>;;' -e 's;<\/h1>.*;;' > ${htmlfile%.html}/title
				sed -n '/<div class="content" id="content">/ p' ${htmlfile%.html}*.html | cut -d\" -f8 > ${htmlfile%.html}/img.list
			}
		}
		popd
	}
	#clean_dump
	
	return $?
}

all_img_sync

exit $?
