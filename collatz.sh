#!/bin/bash

n=$1

echo $n
while [ $n != 1 ]; do
	if [ $(($n%2)) = 1 ]; then
		n=$((3*n+1))
	else
		n=$((n/2))
	fi
	echo $n
done
