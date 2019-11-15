#!/bin/bash

while [ ! -z "$2" ];do
	echo "# $1"
	echo "# $2"
	diff $1 $2 | grep '^>';
	hr
	shift
done
