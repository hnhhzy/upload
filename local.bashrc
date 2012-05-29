#! /bin/bash

######################################################################
# set PS1
PS1='\n\[\033[0;32m\]\u@\h\[\033[0m\] \[\033[0;33m\]\w\[\033[0m\]\n\$ '

# /opt/bin
export PATH="/opt/bin:$PATH"

# adb
if [[ -x /opt/bin/adb ]]; then
	. /opt/android-sdk-linux/platform-tools/adb.bash
	alias adb='sudo adb'
fi

# cvs root
#export CVSROOT=':pserver:lrdswcvs\gsm93202:wwssaadd@nbrdsw:/cvs/jvref'

# cd /media/Ubuntu
alias cu='cd /media/Ubuntu'

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

