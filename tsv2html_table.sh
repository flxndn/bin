#!/bin/bash

# from http://unix.stackexchange.com/questions/105501/convert-csv-to-html-table

echo "<table>" ;
	print_header=true
	while read INPUT ; do
		if $print_header;then
			#echo "<tr><th>$INPUT" | sed -e 's/:[^,]*\(,\|$\)/<\/th><th>/g'
			echo "<tr><th>${INPUT//	/</th><th>}</th></tr>" ;
			print_header=false
		else
			echo "<tr><td>${INPUT//	/</td><td>}</td></tr>" ;
		fi
	done < $1
echo "</table>"
