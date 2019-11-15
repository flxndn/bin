#!/bin/sh

ficheros="/etc/hosts /home/felix/.rd.rt"
grep $* $ficheros
