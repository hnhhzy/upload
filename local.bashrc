#! /bin/bash

################################################################################
# Variable definitions.
################################################################################
# debug head info
#PS4='+[$SHELL][$BASH_SUBSHELL][$PPID-$$][$LINENO]["${BASH_SOURCE[*]}"][${FUNCNAME[*]}][${BASH_LINENO[*]}]\n   +'
#PS4='+[$LINENO][${FUNCNAME[@]}][${BASH_LINENO[@]}]\n    + '







################################################################################
# FOR WORKING
################################################################################
################################################################################
# alias & variables
################################################################################
# D430G
export D430G='/media/Ubuntu'
alias cdu="cd $D430G"

# minicom
[[ -x /home/likewise-open/SAGEMWIRELESS/93202/program/bin/minicom ]] && alias minicom='/home/likewise-open/SAGEMWIRELESS/93202/program/bin/minicom'

# android
[[ -x $D430G/Android/android-sdk-linux_x86/tools/android ]] && alias android="$D430G/Android/android-sdk-linux_x86/tools/android"

# cvs root
export CVSROOT=':pserver:lrdswcvs\gsm93202:wwssaadd@nbrdsw:/cvs/jvref'

################################################################################
# functions
################################################################################








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



# kill pid by name
kpbn()
{
	local line="$(echo "$(ps -e)" | grep "$1")"
	local yon=
	
	echo "$line"
	read yon
	[[ $yon = y ]] && kill $(echo "$line" | cut -c -5 | sed 's; ;;g')
}


################################################################################
# cd
# b) function cd_func
# This function defines a 'cd' replacement function capable of keeping,
# displaying and accessing history of visited directories, up to 10 entries
# To use it, uncomment it, source this file and try 'cd --'.
# acd_func 1.0.5, 10-nov-2004
# Petar Marinov, http:/geocities.com/h2428, this is public domain
cd_func ()
{
  local x2 the_new_dir adir index
  local -i cnt

  if [[ $1 ==  "--" ]]; then
    dirs -v
    return 0
  fi

  the_new_dir=$1
  [[ -z $1 ]] && the_new_dir=$HOME

  if [[ ${the_new_dir:0:1} == '-' ]]; then
    #
    # Extract dir N from dirs
    index=${the_new_dir:1}
    [[ -z $index ]] && index=1
    adir=$(dirs +$index)
    [[ -z $adir ]] && return 1
    the_new_dir=$adir
  fi

  #
  # '~' has to be substituted by ${HOME}
  [[ ${the_new_dir:0:1} == '~' ]] && the_new_dir="${HOME}${the_new_dir:1}"

  #
  # Now change to the new dir and add to the top of the stack
  pushd "${the_new_dir}" > /dev/null
  [[ $? -ne 0 ]] && return 1
  the_new_dir=$(pwd)

  #
  # Trim down everything beyond 11th entry
  popd -n +11 2>/dev/null 1>/dev/null

  #
  # Remove any other occurence of this dir, skipping the top of the stack
  for ((cnt=1; cnt <= 10; cnt++)); do
    x2=$(dirs +${cnt} 2>/dev/null)
    [[ $? -ne 0 ]] && return 0
    [[ ${x2:0:1} == '~' ]] && x2="${HOME}${x2:1}"
    if [[ "${x2}" == "${the_new_dir}" ]]; then
      popd -n +$cnt 2>/dev/null 1>/dev/null
      cnt=cnt-1
    fi
  done

  return 0
}

alias cd=cd_func
alias cd..='cd ..'
alias cd-='cd -'

# adb
if [[ $(uname) == Linux ]] && [[ $UID != 0 ]]; then
	ADB='sudo adb'
	alias adb='sudo adb'
else
	ADB='adb'
fi

# I am root
Iamroot()
{
	mv /opt/bin/fastboot /opt/bin/fastboot.bak
	ln -s ${1:-/bin/su} /opt/bin/fastboot
	sudo fastboot
	mv /opt/bin/fastboot.bak /opt/bin/fastboot
}

# notify operation finish
notify_finish()
{
	[[ -z $1 ]] && return 1
	
	gnome-osd-client -f "<message id='eros' hide_timeout='50000' osd_halignment='center' osd_vposition='center' osd_font='WenQuanYi Micro Hei 50'>$1</message>"
	#notify-send "$1" -i /usr/share/pixmaps/gnome-debian.png
}

# usage: fastbooot [imgs_dir_path]
fastbooot()
{
	local _tag=${_tag:-${FUNCNAME[0]}}

	local FASTBOOT='/opt/bin/fastboot'
	[[ ! -x $FASTBOOT ]] && { echo "$_tag: error: $FASTBOOT is invalid!!!"; return 1; }
	
	local imgs_path=${1:-.}
	[[ ! -d $imgs_path ]] && { echo "$_tag: error: $imgs_path is not a directory!!!"; return 1; }
	[[ -n $TARGET_PRODUCT ]] && imgs_path="out/target/product/$TARGET_PRODUCT"

	local SUDO=
	[[ $UID != 0 ]] && SUDO='sudo'

	local imgs=($(cd $imgs_path; ls *.img 2>/dev/null))
	[[ -z ${imgs[@]} ]] && { echo "$_tag: error: no image in $imgs_path!!!"; return 1; }
	
	local default_imgs='boot custpack recovery system userdata'
	local def=
	local num=
	local list=
	
	for ((num=0; num<${#imgs[@]}; num++)); do
		printf "%18s: %-2d\n" ${imgs[$num]%.img} $num
		if echo $default_imgs | grep ${imgs[$num]%.img} &> /dev/null; then
			def=$def$num
		fi
	done
	
	read -p "flash which(s)? [default: $def] " list
	list=${list:-$def}
	
	for ((num=0; num<${#list}; num++)); do
		[[ -n ${imgs[${list:$num:1}]} ]] && $SUDO $FASTBOOT flash ${imgs[${list:$num:1}]%.img} $imgs_path/${imgs[${list:$num:1}]}
	done

	notify_finish '搞定收工！'

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
