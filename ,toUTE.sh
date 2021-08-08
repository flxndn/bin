#!/bin/bash

readonly DIR=~/tmp/toUTE
readonly HOST=192.168.164.33
readonly DIR_OUT=/home/felix/tmp/fromHome

opcion='-i'
if [ "x$1" = "x-d" ]; then
	opcion='-f'
fi

scp $DIR/*.* $HOST:$DIR_OUT \
&& rm $opcion $DIR/*.*
