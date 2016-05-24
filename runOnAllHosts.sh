#!/bin/bash
# Created 20160504 by eeemil
# MIT License, no warranty, if this blows stuff up: blame yourself
# He he he
#
# Runs <argument> as command on all hosts on computer lab (including the host you are on)

HOSTS="osthyvel diskborste grytvante stekspade yxa elvisp paltslev pastaslev"
CMD="$@"

for HOSTNAME in ${HOSTS} ; do
    echo "Running $CMD on $HOSTNAME..."
    ssh "$HOSTNAME" "$CMD"
    echo -e "Done with command on $HOSTNAME!\n---------"
done

echo "Done"

