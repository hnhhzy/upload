#! /bin/bash

################################################################################
# sudo
if [[ -x /usr/bin/sudo ]]; then
	if [[ $(uname) == Linux ]] && [[ $UID != 0 ]]; then
		export SUDO=/usr/bin/sudo
	fi
fi

# adb
if [[ -x /opt/bin/adb ]]; then
	export ADB="$SUDO /opt/bin/adb"
	alias adb=$ADB
fi

# cvs root
export CVSROOT=':pserver:lrdswcvs\gsm93202:wwssaadd@nbrdsw:/cvs/jvref'

# cd
alias cd=cd_func
alias cd..='cd ..'
alias cd-='cd -'


################################################################################
# I am root
Iamroot() {

	mv /opt/bin/fastboot /opt/bin/fastboot.bak
	ln -s ${1:-/bin/su} /opt/bin/fastboot
	$SUDO fastboot
	mv /opt/bin/fastboot.bak /opt/bin/fastboot
}

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
		echo "$TAG: $TAG [DIR]"
		return 0
	fi

	# sudo
	local SUDO=
	if [[ -x /usr/bin/sudo ]]; then
		if [[ $(uname) == Linux ]] && [[ $UID != 0 ]]; then
			SUDO=/usr/bin/sudo
		fi
	fi

	# fastboot
	local FASTBOOT=
	if [[ -x /opt/bin/fastboot ]]; then
		FASTBOOT="$SUDO /opt/bin/fastboot"
	else
		echo "$TAG: error: /opt/bin/fastboot is invalid."
		return 1
	fi
	
	# path of imgs
	local imgs_path=
	if [[ -n $1 ]]; then
		imgs_path=$1
	elif [[ -n $TARGET_PRODUCT ]]; then
		imgs_path="out/target/product/$TARGET_PRODUCT"
	else
		imgs_path=$PWD
	fi
	if [[ ! -d $imgs_path ]]; then
		echo "$TAG: error: $imgs_path is not a directory."
		return 1
	fi
	
	local imgs=$(cd "$imgs_path"; ls *.img 2>/dev/null)
	if [[ -z $imgs ]]; then
		echo "$TAG: warning: no image in $imgs_path."
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
			$FASTBOOT flash ${map[${list:$i:1}]%.img} "$imgs_path/${map[${list:$i:1}]}"
		fi
	done

	notify_finish '搞定收工！'

	return $?
}

