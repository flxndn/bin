#!/bin/bash

readonly ARGS="$@"
readonly PROGNAME=$(basename $0)
readonly DEFAULT_MINUTES=$((60*60))
readonly DEFAULT_DIR_CACHE=~/.curlcache/tmp
#readonly CONFFILE=~/.rd.rt

#-------------------------------------------------------------------------------
help() {
#-------------------------------------------------------------------------------
cat <<HELP
* $PROGNAME
	Local cache curl request.
	* Usage
		> $PROGNAME [--cache-timeout minutes] CURLOPTIONS
		> $PROGNAME -h|--help
	* Options
		- --cache-time minutes :: Number of minutes for valid cache. :: Default is $DEFAULT_MINUTES.
		- -h | --help :: Show this help.
	* Description
		Stores the result of the curl request and if it is repeated in less than minutes it is localment served.

	* Directories
		Store cache files in $DEFAULT_DIR_CACHE.
HELP
}
#-------------------------------------------------------------------------------
# main
#------------------------------------------------------------------------------- 
cache_timeout=$DEFAULT_MINUTES

if [ "x$1" = "x-h" ] || [ "x$1" = "x--help" ]; then
	help
	exit
fi

if [ "x$1" = "x--cache-timeout" ]; then
	cache_timeout=$2
	shift;shift;
fi

if [ ! -d $DEFAULT_DIR_CACHE ]; then
	mkdir -p $DEFAULT_DIR_CACHE;
fi 

file_cache=$(echo "$*" | md5sum | cut -f1 -d' ')

set -x
if [ $(find $DEFAULT_DIR_CACHE -name $file_cache -mmin -$cache_timeout |wc -l) = 0 ] ; then
	# echo "no existe"
	curl -s $* > $DEFAULT_DIR_CACHE/$file_cache
	cat $DEFAULT_DIR_CACHE/$file_cache;
else
	# echo existe
	cat $DEFAULT_DIR_CACHE/$file_cache;
fi
