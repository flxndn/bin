#!/bin/bash

echo "* netstatus" 

for c in "ip address" "ip route" "cat /etc/resolv.conf";do 

	echo "	* $c";
	$c | sed "s/^/		> /";
done
