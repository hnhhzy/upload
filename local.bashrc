#! /bin/bash

######################################################################
# set PS1
PS1='\[\033[0;33m\]\w\[\033[0m\]\$ '

# hash
if ! hash sudo 2>/dev/null; then
	read -p "WARNING: command 'sudo' invalid"
fi

# adb
if [[ -x /opt/bin/adb ]]; then
	export ADB='sudo /opt/bin/adb'
	alias adb=$ADB
fi

# cvs root
export CVSROOT=':pserver:lrdswcvs\gsm93202:wwssaadd@nbrdsw:/cvs/jvref'

# cd
alias cd=cd_func

# I am root
iamroot()
{
	if [[ -e /opt/bin/fastboot.bak ]]; then
		echo 'root permission locked !'
		return 1
	else
		mv /opt/bin/fastboot /opt/bin/fastboot.bak
		ln -s ${1:-/bin/su} /opt/bin/fastboot
		sudo fastboot
		mv /opt/bin/fastboot.bak /opt/bin/fastboot
	fi
}

# b) function cd_func
# This function defines a 'cd' replacement function capable of keeping,
# To use it, uncomment it, source this file and try 'cd --'.
cd_func ()
{
	local arg index

	if [[ $1 == -- ]]; then
		dirs -v
		return 0
	fi

	arg=${1:-/media/Ubuntu}

	if [[ $arg == -* ]]; then
		#
		# Extract dir N from dirs
		index=${arg:1}
		[[ -z $index ]] && index=1
		arg=$(dirs +$index)
		[[ -z $arg ]] && return 1
	fi
	#
	# '~' has to be substituted by ${HOME}
	[[ $arg == ~* ]] && arg=${HOME}${arg:1}

	#
	# Now change to the new dir and add to the top of the stack
	pushd "$arg" 1>/dev/null

	return $?
}

# usage: build_AMSS
build_AMSS ()
{
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

	local ver
	# python
	read -p "Choose version for python [d]efault: $(python -V 2>&1 | cut -d' ' -f2); [o]ld: 2.4.5: " ver
	[[ $ver == o ]] && export PATH="/opt/python-2.4.5/bin:$PATH"
	python -V
}

# usage: alert MSG
alert ()
{
	[[ -z $1 ]] && return 1
	
	gnome-osd-client -f "<message id='eros' hide_timeout='50000' osd_halignment='center' osd_vposition='center' osd_font='WenQuanYi Micro Hei 50'>$1</message>"
	#notify-send "$1" -i /usr/share/pixmaps/gnome-debian.png
}

# usage: repo_init_sync_start "$@"
repo_init_sync_start ()
{
	local xml=${4##*/}

	mkdir $xml && \
	cd $xml && \
	echo $'\n\ny' | repo init "$@" && \
	repo sync && \
	repo start $xml --all
}
