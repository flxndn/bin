#!/bin/bash

for i in "$@"; do
	echo "$i"; 
done  > ~/.ficheros_a_log.txt
