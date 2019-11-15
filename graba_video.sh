#!/bin/bash
#readonly ARGS="$@"

#-------------------------------------------------------------------------------
main() {
#-------------------------------------------------------------------------------
	local time=0:1:0
	local dev=/dev/video0
	local format=rgb24
	local rate=10
	local dir=~/video

	if [ ! -d "$dir" ]; then 
		mkdir -p $dir;
	fi
	local output=$dir/$(date -Iseconds).avi

	streamer -t $time -c $dev -f $format -r $rate -o $output
}
#-------------------------------------------------------------------------------
#------------------------------------------------------------------------------- 
main
