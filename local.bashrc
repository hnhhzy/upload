#! /bin/bash

######################################################################
# set PS1
PS1='\n\[\033[0;32m\]\u@\h\[\033[0m\] \[\033[0;33m\]\w\[\033[0m\]\n\$ '

# PATH
PATH="/opt/bin:/opt/android-sdk-linux/tools:$PATH"

# adb
if which adb &>/dev/null; then
	alias adb='sudo adb'
	export ANDROID_ADB='sudo adb'
fi

# cvs root
#export CVSROOT=':pserver:lrdswcvs\gsm93202:wwssaadd@nbrdsw:/cvs/jvref'

# usage: repo_init_sync_start "$@"
repo_init_sync_start ()
{
	local xml=${4##*/}
	local tag=${xml%.xml}

	which repo &>/dev/null && \
	mkdir $tag && \
	cd $tag && \
	echo $'\n\ny' | repo init "$@" && \
	repo sync && \
	repo start $tag --all
}

