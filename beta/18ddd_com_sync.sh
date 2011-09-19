#! /bin/bash -x

# all_filter date
all_filter()
{
	sed -n -e '/<img src="\/templets\/default\/neisan.gif">/p' *.html | grep $1 | sed 's;.*<img src="/templets/default/neisan.gif"> <a href="\(.*\)" target="_blank">.*;http://www.14ddd.com\1;' > $1.list

	return $?
}

# all_img_sync [prefix]
all_img_sync()
{
	local num=6
	local indexlist=(
		http://www.14ddd.com/htm/Piclist1/index.html
		http://www.14ddd.com/htm/Piclist2/index.html
		http://www.14ddd.com/htm/Piclist3/index.html
		http://www.14ddd.com/htm/Piclist5/index.html
		http://www.14ddd.com/htm/Piclist6/index.html
		http://www.14ddd.com/htm/Piclist7/index.html
		)
	local dirlist=(
		yzst
		tkzp
		omst
		qcmn
		mxlz
		mtsw
		)
	local cagelist=(
		亚洲色图
		偷窥自拍
		欧美色图
		清纯美女
		明星裸照
		美腿丝袜
		)
	local prefix=${1:-.}
	local date=$(date --date='yesterday' +%Y.%m.%d)
	local lastpage=
	local iter=
	
	for ((iter=0; iter<num; ++iter)); {
		#mkdir -p "$prefix/${dirlist[$iter]}/18ddd_com"
		#echo ${cagelist[$iter]} > $prefix/${dirlist[$iter]}/cage
		pushd "$prefix/${dirlist[$iter]}/18ddd_com"
		wget -c -nv ${indexlist[$iter]}
		lastpage=$(sed -n '/page2/ s;.*<a href="index_\(.*\).html">2</a>.*;\1; p' index.html)
		wget -c -nv ${indexlist[$iter]/.html/_$lastpage.html}
		all_filter $date
		rm *.html
		popd
	}

	return $?
}

# all_txt_sync [prefix]
all_txt_sync()
{
	local num=8
	local indexlist=(
		http://www.14ddd.com/htm/Novellist1/index.html
		http://www.14ddd.com/htm/Novellist2/index.html
		http://www.14ddd.com/htm/Novellist3/index.html
		http://www.14ddd.com/htm/Novellist4/index.html
		http://www.14ddd.com/htm/Novellist5/index.html
		http://www.14ddd.com/htm/Novellist6/index.html
		http://www.14ddd.com/htm/Novellist7/index.html
		http://www.14ddd.com/htm/Novellist8/index.html
		)
	local dirlist=(
		jqwx
		llwx
		ysrq
		mqxy
		yyqj
		gdwx
		hsxh
		jtsl
		)
	local cagelist=(
		激情文学
		乱伦文学
		淫色人妻
		迷情校园
		意淫强奸
		武侠古典
		黄色笑话
		交通色狼
		)
	local prefix=${1:-.}
	local date=$(date --date='yesterday' +%Y.%m.%d)
	local lastpage=
	local iter=
	
	for ((iter=0; iter<num; ++iter)); {
		#mkdir -p "$prefix/${dirlist[$iter]}/18ddd_com"
		#echo ${cagelist[$iter]} > $prefix/${dirlist[$iter]}/cage
		pushd "$prefix/${dirlist[$iter]}/18ddd_com"
		wget -c -nv ${indexlist[$iter]}
		lastpage=$(sed -n '/page2/ s;.*<a href="index_\(.*\).html">2</a>.*;\1; p' index.html)
		wget -c -nv ${indexlist[$iter]/.html/_$lastpage.html}
		all_filter $date
		rm *.html
		popd
	}

	return $?
}

all_img_sync img
all_txt_sync txt

exit $?
