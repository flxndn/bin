#!/bin/bash

if [ "x$1" == 'x-h' ] || [ "x$1" == 'x--help' ]
then 
	nombre=$(basename $0)
	echo "* $nombre
	* Descripción
		Convierte las tablas en formato simple  de la wikipedia que le vengan por 
		la entrada estandar a formato html.

	* Uso
		> wikitable2html.sh -h
		> wikitable2html.sh

	* Ejemplos
		Convierte la entrada del estilo
		
		> {| style=\"border:1px solid #f80\"
		> !Ventas
		> !enero
		> !febrero
		> |- style=\"background: #08f\"
		> !2010
		> |3
		> |4
		> |-
		> !2011
		> |5
		> |6
		> |}

		en algo así:

		> <table style=\"border:1px solid #f80\"><tr>
		> <th>Ventas</th>
		> <th>enero</th>
		> <th>febrero</th>
		> </tr><tr style=\"background: #08f\">
		> <th>2010</th>
		> <td>3</td>
		> <td>4</td>
		> </tr><tr>
		> <th>2011</th>
		> <td>5</td>
		> <td>6</td>
		> </tr></table>

		o 
		> {|
		> |           !! colspan=4 | Status full ok / Status no ok
		> |-
		> ! Status ok || 0/0 || 0/1 || 1/1 || 1/0
		> |-
		> |         0 ||  0  ||  1  ||  0   ||  3
		> |-
		> |         1 ||  2  ||  0  ||  0   ||  0
		> |}

		en 
		> <table><tr>
		> <td>           </td>
		> <th  colspan=4 > Status full ok / Status no ok</th>
		> </tr><tr>
		> <th> Status ok </th>
		> <td> 0/0 </td>
		> <td> 0/1 </td>
		> <td> 1/1 </td>
		> <td> 1/0</td>
		> </tr><tr>
		> <td>         0 </td>
		> <td>  0  </td>
		> <td>  1  </td>
		> <td>  0   </td>
		> <td>  3</td>
		> </tr><tr>
		> <td>         1 </td>
		> <td>  2  </td>
		> <td>  0  </td>
		> <td>  0   </td>
		> <td>  0</td>
		> </tr></table>
"

exit 0
fi

cat \
| sed "s/||/\n|/g" \
| sed "s/!!/\n!/g" \
| sed "s/{|\(.*\)/<table\1><tr>/"  \
| sed "s/|}/<\/tr><\/table>/"  \
| sed "s/|-\(.*\)/<\/tr><tr\1>/"  \
| sed "s/!\([^-].*\)|\(.*\)/<th \1>\2<\/th>/"  \
| sed "s/|\(.*\)|\(.*\)/<td \1>\2<\/td>/"  \
| sed "s/!\([^-].*\)/<th>\1<\/th>/"  \
| sed "s/|\(.*\)/<td>\1<\/td>/"  
