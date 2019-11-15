#!/bin/bash

poste=865
url="http://www.urbanosdezaragoza.es/frm_esquemaparadatime.php?poste=$poste&direccion=Violante%20de%20Hungr%C3%ADa%20(Palacio%20de%20Deportes)"
links -source "$url" \
| sed "s/<tr/\n<tr/g"\
| grep digital \
| sed "s/<[^>]*>/ /g" \
| grep "\(minutos\)\|\(parada\)" \
| sed "s/^ *//;s/  */ /g"
