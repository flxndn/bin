#!/bin/bash

readonly ARGS="$@"
readonly NAME=$(basename $0)
cache_directory=~/.cache_directory;
minutes=0

#-------------------------------------------------------------------------------
help() {
#-------------------------------------------------------------------------------
	cat <<HELP
* $Name 
	* Usage
		> $NAME -h
		> $NAME [-d cache_directory] [ -t minutes ] -e command

	* Description
		If in cache_directory exists a file whith the name equals the md5sum of the command + args + standard input newer than minutes then returns the content of the file. Otherwise execute the command and store it.

		* Options
			* -h | --help
				Show this help.
			* -d | --directory
				Set default cache directory.
			* -t minutes
				Number of minutes the chache is valid. 

				0 minutes: Always use cached file.
			* -i
				The command has standard input.
            * -e command
                Execute command o restore output from cache.
HELP
}
#-------------------------------------------------------------------------------
parsearg(){
#------------------------------------------------------------------------------- 
	local arg=

	for arg; do
		local delim=""
		case "$arg" in
			--help)				args="${args}-h ";;
			*) [[ "${arg:0:1}" == "-" ]]  || delim="\""
				args="${args}${delim}${arg}${delim} ";;
		esac
	done

	eval set --  $args
	while getopts "hd:t:ie" OPTION; do
		case $OPTION in
			h) help; exit;;
			d) readonly cache_directory=$OPTARG;shift;shift;;
			t) readonly minutes=$OPTARG;shift;shift;;
			i) readonly STANDARD_INPUT=true; shift;;
			e) shift; break;;
		esac
	done 
    
    shift;
	readonly PARAMS=$*
   
}
#-------------------------------------------------------------------------------
main() {
#-------------------------------------------------------------------------------
	tmp=$(mktemp);
	hash=$( ( 
		echo "$ARGS"; 
		if [ ! -z ${STANDARD_INPUT+x} ]; then cat | tee $tmp; fi
		) \
		| tee ~/tmp/kk.txt | md5sum | cut -f1 -d' ')

	cache_file=$cache_directory/$hash;

	if [ ! -e $cache_file ] || ( [ "$minutes" != "0" ] && ( find $cache_file -mmin +$minutes | egrep '.*' >/dev/null ) ); then
		cat $tmp | $PARAMS | tee $cache_file
	else
		cat $cache_file;
	fi
	rm $tmp
} 
#------------------------------------------------------------------------------- 
#------------------------------------------------------------------------------- 
parsearg $ARGS
main 

