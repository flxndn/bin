#!/bin/bash

. ~/.ntfy.rc

for i in "$@"; do 
	curl -d "$i" ntfy.sh/$canal
done
