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

# usage: repo_sync_from_local_repository -u git@172.16.11.162:platform_qcom/manifests.git -m [branch_name].xml
repo_sync_from_local_repository ()
{
	local repository_dir=/media/Ubuntu/repository

	local tmp=${4##*/}
	local tag=${tmp%.xml}

	tmp=${2##*:}
	local repository=${tmp%%/*}

	if which repo &>/dev/null; then
		if [[ ! -d .repo ]]; then
			mkdir -p $tag/.repo && \
			cd $tag
		fi
		for i in manifests manifests.git projects repo; do
			ln -sf $repository_dir/$repository/.repo/$i .repo/$i
		done
		echo $'\n\ny' | repo init "$@" && \
		repo sync && \
		repo start $tag --all
	fi
}

