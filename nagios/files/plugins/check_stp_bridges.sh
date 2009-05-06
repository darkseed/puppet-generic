#!/bin/bash
#
# Nagios plugin check_stp_bridges.sh
#
# Version: 1.0, released on 17/11/2008, tested on Debian GNU/Linux 4.0 (etch)
# and 5.0 (lenny).
#
# This plugin checks all networking bridges using STP. The check figures if the
# first bridge port is in FORWARDING state and no other ports are DISABLED.
#
# Copyright (c) 2008 by Kees Meijs <kees@kumina.nl> for Kumina bv.
#
# This work is licensed under the Creative Commons Attribution-Share Alike 3.0
# Unported license. In short: you are free to share and to make derivatives of
# this work under the conditions that you appropriately attribute it, and that
# you only distribute it under the same, similar or a compatible license. Any
# of the above conditions can be waived if you get permission from the copyright
# holder.

# Bridge tool binary location.
BRCTL=/usr/sbin/brctl

# Default exit codes.
OK=0;
WARNING=1;
CRITICAL=2;
UNKNOWN=3;

# Default exit status.
EXITSTATUS=$UNKNOWN
EXITMSG="No bridges found using STP."

# Test for binary.
if [ ! -x $BRCTL ]; then
	echo "Binary $BRCTL not found or not set executable."
	exit $UNKNOWN
fi

# Figure out bridges using STP.
BRLST=`$BRCTL show | cut -f 1,4 | grep yes$ | cut -f 1`

# Check found bridges.
for BRIDGE in $BRLST; do
	# Figure out port status on each bridge.
	BRSTATUS=`$BRCTL showstp $BRIDGE | grep state | cut -f 8`

	# Port counter.
	PRTNO=0

	# If status was unknown, we can safely set the initial exit message.
	if [ $EXITSTATUS = $UNKNOWN ]; then
		EXITMSG="Ports"
	fi

	# Set exit message.
	EXITMSG="$EXITMSG on $BRIDGE:"

	# Investigate status of each bridge port.
	for PRTSTATUS in $BRSTATUS; do
		# Disabled ports are always bad news!
		if [ "$PRTSTATUS" = "disabled" ]; then
			if [ $EXITSTATUS != $CRITICAL ]; then
				EXITSTATUS=$CRITICAL
			fi
		fi

		# Be sure the first port is the active one.
		if [ "$PRTSTATUS" != "forwarding" -a "$PRTNO" = "0" ]; then
			if [ $EXITSTATUS != $CRITICAL ]; then
				EXITSTATUS=$WARNING
			fi
		fi

		# If status was unknown, we can safely set it to OK now.
		if [ $EXITSTATUS = $UNKNOWN ]; then
			EXITSTATUS=$OK
		fi

		# Set exit message.
		EXITMSG="$EXITMSG p$PRTNO/$PRTSTATUS"

		# Iterate to next port.
		let PRTNO=PRTNO+1
	done
done

# Exit echoing status.
echo "$EXITMSG"
exit $EXITSTATUS
