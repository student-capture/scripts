#!/bin/bash
# Created 20160504 by eeemil
# MIT License, no warranty, if this blows stuff up: blame yourself
# He he he

#
# WARNING: TODO, ADD MORE HOSTS
#

if [[ ! `whoami` == "root" ]]; then
    echo "Lol, you are not root!"
    echo "You have to be root"
    exit 1
fi
echo -n "Enter username: "
read USERNAME
USERNAME=$(echo "$USERNAME" | tr '[:upper:]' '[:lower:]')


HOSTS="osthyvel diskborste"



for HOSTNAME in ${HOSTS} ; do
    echo "HHH'ing $USERNAME on $HOSTNAME"
    ssh "$HOSTNAME" getent passwd "$USERNAME" >/dev/null 2>&1
    if [[ $? -ne 0 ]]; then
	echo "$USERNAME doesnt exist on $HOSTNAME, skipping..."
	continue
    fi
    ssh ${HOSTNAME} userdel -r \""$USERNAME"\" >/dev/null 2>&1
    echo "$USERNAME has been physically removed on $HOSTNAME, so to speak."
done
