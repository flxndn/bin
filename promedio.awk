#!/usr/bin/awk -f
{ total += $1; count++ } 
END { print total/count }
