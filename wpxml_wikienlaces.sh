#!/bin/bash
# para un archivo descargado en formato xml extrae los wikienlaces

sed "s/\[\[/\n[[/g" $1 \
| grep '\[\[' \
| sed "s/\]\].*//;s/|.*//" \
| cut -c3- \
| sort \
| uniq

