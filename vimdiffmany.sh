#!/bin/bash

ficheros=( "$@" )

for i in $(seq 0 $((${#ficheros[@]}-2)));do
	s=$((i+1));
	vimdiff ${ficheros[i]} ${ficheros[s]} || exit
done
