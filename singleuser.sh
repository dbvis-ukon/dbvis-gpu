#!/bin/bash

set -e

# set default ip to 0.0.0.0
if [[ "$NOTEBOOK_ARGS $@" != *"--ip="* ]]; then
  NOTEBOOK_ARGS="--ip=0.0.0.0 $NOTEBOOK_ARGS"
fi

# Handle special flags if we're root
if [ $(id -u) == 0 ] ; then

    if ! id "$NB_USER" >/dev/null 2>&1; then

    	echo "Set username to: $NB_USER"
    	usermod -d /home/$NB_USER -l $NB_USER dbvis

    	cp /README.md /home/$NB_USER/README.md

    	if [[ "$PWD/" == "/home/nvidia_user/"* ]]; then
            newcwd="/home/$NB_USER/${PWD:13}"
            echo "Setting CWD to $newcwd"
            cd "$newcwd"
    	fi

    	# Change UID of NB_USER to NB_UID if it does not match
    	if [ "$NB_UID" != $(id -u $NB_USER) ] ; then
            echo "Set $NB_USER UID to: $NB_UID"
            usermod -u $NB_UID $NB_USER
    	fi

    	# Change GID of NB_USER to NB_GID if NB_GID is passed as a parameter
    	if [ "$NB_GID" ] ; then
            echo "Set $NB_USER GID to: $NB_GID"
            groupmod -g $NB_GID -o $(id -g -n $NB_USER)
    	fi

    fi

    # Exec the command as NB_USER
    echo "Execute the command as $NB_USER: jupyterhub-singleuser $*"
    exec sudo -E -H -u $NB_USER PATH=$PATH jupyterhub-singleuser $NOTEBOOK_ARGS $*

else

   # Exec the command as NB_USER
   echo "Execute the command as $NB_USER: jupyterhub-singleuser $*"
   export PATH=$PATH
   exec jupyterhub-singleuser $NOTEBOOK_ARGS $*

fi
