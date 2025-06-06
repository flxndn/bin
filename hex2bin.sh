#!/bin/bash

if [ ! -n $1 ]; then
	echo "Must specify a value"
	exit 1
fi

for var in "$@"; do
	code=`echo $var | tr 'a-z' 'A-Z'`
	converted=`echo "ibase=16; $code" | bc`
	echo -n "$converted "
done

echo
