#! /bin/bash

######################################################################
# set PS1
PS1='\[\033[0;33m\]\w\[\033[0m\]\$ '

# adb
if [[ -x /opt/bin/adb ]]; then
	export ADB='sudo /opt/bin/adb'
	alias adb=$ADB
fi

# cvs root
export CVSROOT=':pserver:lrdswcvs\gsm93202:wwssaadd@nbrdsw:/cvs/jvref'

# Android tools
export PATH="/media/Ubuntu/opt/Android/android-sdk-linux_x86/tools:$PATH"

# cu
alias cu='cd /media/Ubuntu'

# I am root
iamroot()
{
	if [[ -e /opt/bin/fastboot.bak ]]; then
		echo 'root permission locked !'
		return 1
	else
		mv /opt/bin/fastboot /opt/bin/fastboot.bak
		ln -s ${1:-/bin/su} /opt/bin/fastboot
		shift
		sudo fastboot "$@"
		mv /opt/bin/fastboot.bak /opt/bin/fastboot
	fi
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
	read -p "Choose python version [d]efault: $(python -V 2>&1 | cut -d' ' -f2); [o]ld: 2.4.5: " ver
	if [[ $ver == o ]]; then
    	export PATH="/opt/python-2.4.5/bin:$PATH"
    fi
	python -V
}

# usage: alert MSG
alert ()
{
	gnome-osd-client -f "<message id='eros' hide_timeout='50000' osd_halignment='center' osd_vposition='center' osd_font='WenQuanYi Micro Hei 50'>$1</message>"
	#notify-send "$1" -i /usr/share/pixmaps/gnome-debian.png
}

# usage: repo_init_sync_start "$@"
repo_init_sync_start ()
{
	local xml=${4##*/}

	mkdir ${xml%.xml} && \
	cd ${xml%.xml} && \
	echo $'\n\ny' | repo init "$@" && \
	repo sync && \
	repo start ${xml%.xml} --all
}
