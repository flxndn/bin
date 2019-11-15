#!/bin/bash
# Va capturando lo seleccionado y lo saca por salida estándar

ant=''
while :; do
	ahora=$(xsel -o)
	if [ "x$ahora" != "x$ant" ]; then
		echo $ahora
		echo > xsel -i
		ant=$ahora
	fi
done
