#! /bin/bash
#
# build amss
#

if [[ -d /opt/ARM ]] && [[ -f $1 ]]; then

    # ARM
    echo 'export ARMTOOLS=RVCT221
export ARMROOT=/opt/ARM
export ARMPATH="$ARMROOT/RVCT/Programs/2.2/349/linux-pentium"
export ARMLIB="$ARMROOT/RVCT/Data/2.2/349/lib"
export ARMINCLUDE="$ARMROOT/RVCT/Data/2.2/349/include/unix"
export ARMINC="$ARMROOT/RVCT/Data/2.2/349/include/unix"
export ARMBIN="$ARMROOT/RVCT/Programs/2.2/349/linux-pentium"
export ARMHOME=$ARMROOT' > $1.sh

    if [[ -f /opt/ARM/RVDS22env.sh ]]; then
	    echo 'source /opt/ARM/RVDS22env.sh' >> $1.sh
    fi
	
    # python
    case $1 in
    *TSNCJOLYM.cmd)
   	    echo 'export PATH="/opt/python-2.4.5/bin:$PATH"' >> $1.sh
   	    ;;
   	esac

    cat $1 | sed -e '/^make/s/$/ $@/' -e '/^perl/s/$0$/'"${1##./}"'/' >> $1.sh
    chmod +x $1.sh

fi

exit $?
