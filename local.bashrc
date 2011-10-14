#! /bin/bash

################################################################################
# set PS1
PS1='\[\033[0;33m\]\w\[\033[0m\]\$ '

# go to /media/Ubuntu
cd /media/Ubuntu

# Find if a given shell program is available.
#
# $1: suffix of variable name
# $2: program name
#
# Result: set CMD_$1 to the full path of the corresponding command
#         or to the empty/undefined string if not available
#
find_progpath ()
{
	local p=$(which $2)
	[[ -n $p ]] && eval export CMD_$1=\"$p\"
}

# sudo
if [[ $(uname) == Linux ]] && [[ $UID != 0 ]]; then
	find_progpath 'SUDO' 'sudo'
fi

# adb
if [[ -x /opt/bin/adb ]]; then
	export CMD_ADB="$CMD_SUDO /opt/bin/adb"
	alias adb=$CMD_ADB
fi

# cvs root
export CVSROOT=':pserver:lrdswcvs\gsm93202:wwssaadd@nbrdsw:/cvs/jvref'

# cd
alias cd=cd_func

################################################################################
# I am root
Iamroot()
{
	mv /opt/bin/fastboot /opt/bin/fastboot.bak
	ln -s ${1:-/bin/su} /opt/bin/fastboot
	$CMD_SUDO fastboot
	mv /opt/bin/fastboot.bak /opt/bin/fastboot
}

# b) function cd_func
# This function defines a 'cd' replacement function capable of keeping,
# To use it, uncomment it, source this file and try 'cd --'.
cd_func ()
{
	local arg index

	if [[ $1 == --* ]]; then
		dirs -v
		return 0
	fi

	arg=${1:-$HOME}

	#
	# '~' has to be substituted by ${HOME}
	[[ $arg == ~* ]] && arg=${HOME}${arg:1}
	
	if [[ $arg == -* ]]; then
		#
		# Extract dir N from dirs
		index=${arg:1}
		[[ -z $index ]] && index=1
		arg=$(dirs +$index)
		[[ -z $arg ]] && return 1
	fi

	#
	# Now change to the new dir and add to the top of the stack
	pushd "$arg" 1>/dev/null

	return $?
}

# usage: build_AMSS
build_AMSS() {

	# ARM
	export ARMTOOLS=RVCT221
	export ARMROOT=/opt/ARM
	export ARMPATH="$ARMROOT/RVCT/Programs/2.2/349/linux-pentium"
	export ARMLIB="$ARMROOT/RVCT/Data/2.2/349/lib"
	export ARMINCLUDE="$ARMROOT/RVCT/Data/2.2/349/include/unix"
	export ARMINC="$ARMROOT/RVCT/Data/2.2/349/include/unix"
	export ARMBIN="$ARMROOT/RVCT/Programs/2.2/349/linux-pentium"
	export ARMHOME=$ARMROOT

	if [[ -f /opt/ARM/RVDS22env.sh ]]; then
		source /opt/ARM/RVDS22env.sh
	fi

	# python
	export PATH="/opt/python-2.4.5/bin:$PATH"
}

# notify operation finish
notify_finish() {

	[[ -z $1 ]] && return 1
	
	gnome-osd-client -f "<message id='eros' hide_timeout='50000' osd_halignment='center' osd_vposition='center' osd_font='WenQuanYi Micro Hei 50'>$1</message>"
	#notify-send "$1" -i /usr/share/pixmaps/gnome-debian.png
}

# usage: fastbooot [DIR]
fastbooot() {

	local TAG=${FUNCNAME[0]}

	# usage
	if [[ $1 == --* ]]; then
		echo "usage: $TAG [DIR]"
		return 0
	fi

	# fastboot
	local FASTBOOT
	if [[ -x /opt/bin/fastboot ]]; then
		FASTBOOT='/opt/bin/fastboot'
		[[ $UID != 0 ]] && 	FASTBOOT="sudo $FASTBOOT"
	else
		echo "$TAG: error: no /opt/bin/fastboot."
		return 1
	fi
	
	# path of imgs
	local imgs_dir
	if [[ -n $1 ]]; then
		imgs_dir=$1
	elif [[ -n $TARGET_PRODUCT ]]; then
		imgs_dir="out/target/product/$TARGET_PRODUCT"
	else
		imgs_dir=$PWD
	fi
	if [[ ! -d $imgs_dir ]]; then
		echo "$TAG: error: $imgs_dir is not a directory."
		return 1
	fi
	
	local imgs=$(cd "$imgs_dir"; ls *.img 2>/dev/null)
	if [[ -z $imgs ]]; then
		echo "$TAG: warning: no image in $imgs_dir."
		return 1
	fi
	
	local -A map=([b]=boot.img
	              [c]=custpack.img
	              [r]=recovery.img
	              [s]=system.img
	              [u]=userdata.img)
	local index='bcrsu'
	local all=
	local def='usb'
	local ret=
	local list=
	local i=

	for ((i=0; i<${#index}; i++)); do
		if echo $imgs | grep ${map[${index:$i:1}]} &> /dev/null; then
			printf "%16s: %s\n" "${map[${index:$i:1}]%.img}" "${index:$i:1}"
			all=$all${index:$i:1}
		fi
	done
	
	for ((i=0; i<${#def}; i++)); do
		if echo $all | grep ${def:i:1} &> /dev/null; then
			ret=$ret${def:i:1}
		fi
	done
	
	read -p "flash which(s)? [default: $ret] " list
	list=${list:-$ret}
	
	for ((i=0; i<${#list}; i++)); do
		if [[ -n ${map[${list:$i:1}]} ]]; then
			$FASTBOOT flash ${map[${list:$i:1}]%.img} "$imgs_dir/${map[${list:$i:1}]}"
		fi
	done

	notify_finish '搞定收工！'

	return $?
}

