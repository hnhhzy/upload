#! /bin/bash
#
# Configuration for bash shell
# 
# Copyright (c) 2010-2011 by Zhh.
# 
# This is a configuration for bash shell.
# Define some variables and functions.
# 
# Usage:
#        source local.bashrc

################################################################################
# Variable definitions.
################################################################################
# debug head info
#PS4='+[$SHELL][$BASH_SUBSHELL][$PPID-$$][$LINENO]["${BASH_SOURCE[*]}"][${FUNCNAME[*]}][${BASH_LINENO[*]}]\n   +'
PS4='+[$LINENO][${FUNCNAME[@]}][${BASH_LINENO[@]}]\n    + '

################################################################################
# Alias.
################################################################################
# cd
alias cd..='cd ..'
alias cd-='cd -'

# pushd & popd
alias pu='pushd'
alias po='popd'

################################################################################
# Private function definitions.
################################################################################

################################################################################
# Public function definitions.
################################################################################
# N U P of list
# usage: list_nup file_a file_b
list_nup()
{
	local _tag=${FUNCNAME[0]}
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

## Get absolute path of a file or a directory.
# usage: get_abspath [file|dir]
get_abspath()
{
	local _tag="${FUNCNAME[0]}"

	# cd a directory and pwd
	if [[ -d "$1" ]]; then
		echo "$(cd "$1"; pwd)"
	elif [[ -f "$1" ]]; then
		# file just under / has only one '/'
		# $1 contains no '/' 2>/dev/null
		[[ -n "${1%/*}" ]] && echo -n "$(cd ${1%/*} 2>/dev/null; pwd)"
		echo "/${1##*/}"
	fi

	return $?
}

# i am root
iamroot()
{
	mv /opt/bin/fastboot /opt/bin/fastboot.bak
	ln -s ${1:-/bin/su} /opt/bin/fastboot
	sudo fastboot
	mv /opt/bin/fastboot.bak /opt/bin/fastboot
}

################################################################################
# FOR WORKING
################################################################################
################################################################################
# alias
################################################################################
# minicom
[[ -x /home/likewise-open/SAGEMWIRELESS/93202/program/bin/minicom ]] && alias minicom='/home/likewise-open/SAGEMWIRELESS/93202/program/bin/minicom'

# android
[[ -x /home/likewise-open/SAGEMWIRELESS/93202/Android/android-sdk-linux_x86/tools/android ]] && alias android='/home/likewise-open/SAGEMWIRELESS/93202/Android/android-sdk-linux_x86/tools/android'

################################################################################
# variables
################################################################################
# cvs root
export CVSROOT=':pserver:lrdswcvs\gsm93202:wwssaadd@nbrdsw:/cvs/jvref'

################################################################################
# functions
################################################################################
# usage: flash_all [imgs_dir_path] [fastboot_path]
flash_all()
{
	local imgs_path=${1:-/home/likewise-open/SAGEMWIRELESS/93202/gitroot/tequila/out/target/product/msm7627_ffa}
	[[ -d $imgs_path ]] || return 1
	
	local fastboot_path=${2:-/opt/bin/fastboot}
	[[ -f $fastboot_path ]] || return 1
	
	local imgs=($(cd $imgs_path; ls *.img 2>/dev/null))
	[[ -n "${imgs[@]}" ]] || return 1
	
	local list=
	local all=
	local num=
	
	for ((num=0; num<${#imgs[@]}; num++)); do
		echo -e "\t$num: ${imgs[$num]}"
		all=$all$num
	done
	
	read -p "flash which? [default $all] " list
	list=${list:-$all}
	
	for ((num=0; num<${#list}; num++)); do
		[[ -z ${imgs[${list:$num:1}]} ]] && continue
		$fastboot_path flash ${imgs[${list:$num:1}]%.img} $imgs_path/${imgs[${list:$num:1}]}
	done

	return $?
}

# usage: adb_logcat [suffix]
adb_logcat()
{
	#echo $(sudo adb devices) | grep 'device$' || return 1
	sudo adb logcat | tee $HOME/log/$(date +%y%m%d%H%M%S)${1:+_$1}.log
	
	return $?
}

# usage: build_AMSS
build_AMSS()
{
	# ARM
	export ARMTOOLS=RVCT221
	export ARMROOT=/opt/ARM
	export ARMPATH=$ARMROOT/RVCT/Programs/2.2/349/linux-pentium
	export ARMLIB=$ARMROOT/RVCT/Data/2.2/349/lib
	export ARMINCLUDE=$ARMROOT/RVCT/Data/2.2/349/include/unix
	export ARMINC=$ARMROOT/RVCT/Data/2.2/349/include/unix
	export ARMBIN=$ARMROOT/RVCT/Programs/2.2/349/linux-pentium
	export ARMHOME=$ARMROOT

	[[ -f /opt/ARM/RVDS22env.sh ]] && source /opt/ARM/RVDS22env.sh

	# python
	export PATH=/opt/python-2.4.5/bin:$PATH
}

# usage: restore_name list
restore_name()
{
	while read line; do
		dir=.
		while echo $line | grep '/' &> /dev/null; do
			dir=$(find $dir -maxdepth 1 -iname ${line%%/*})
			line=${line#*/}
		done
		echo $dir/$line
	done < $1
}

# show_proc cur all [format format_back]
show_proc()
{
	local format_back=${3:-"\033[$((${#2}*2+8))D"}
	local format=${4:-"%3s%% (%${#2}s/$2)"}

	[[ $1 -gt 0 ]] && printf "$format_back"
	printf "$format" $((100*$1/$2)) $1
	[[ $1 -eq $2 ]] && echo ', done.'
}
