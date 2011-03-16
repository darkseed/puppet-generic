#!/bin/sh

set -e

if [ "$#" -ne 4 ]
then
	echo "usage: $0 hostname port address1 address2" >&2
	exit 1
fi

HOSTNAME="$1"
PORT="$2"
HOST1="$3"
HOST2="$4"

if nc -zw 15 "$HOST1" "$PORT"
then
	ADDR="$HOST1"
else
	ADDR="$HOST2"
fi

fgrep -v "$HOSTNAME" /etc/hosts > /etc/hosts.new
echo "$ADDR $HOSTNAME" >> /etc/hosts.new
mv /etc/hosts.new /etc/hosts
