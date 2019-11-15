#!/bin/bash

for i in $(find . -name \*.swp); do
	f=$(echo $i | sed "s/\.swp//;s/\/\./\//");
	echo "$i, $f"
	mv $i /tmp
	vi $f;
	vimdiff ~/tmp/kk.php $f;
done
