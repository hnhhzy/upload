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

REPOSITORY_DIR='/media/Ubuntu/repository'

# usage: repo_init_from_local_repository ...
#        repo init ...
repo_init_from_local_repository ()
{
	local tmp=${2##*:}
	local repository=${tmp%%/*}

	if mkdir .repo; then
		for i in manifests manifests.git projects repo; do
			ln -sf $REPOSITORY_DIR/$repository/.repo/$i .repo/$i
		done
		echo $'\n\ny' | repo init "$@"
	fi
}

