#!/bin/bash

#-------------------------------------------------------------------------------
sincroniza() {
#-------------------------------------------------------------------------------
	#rsync --dry-run -avz -e ssh $1/ $2
	rsync -avz -e ssh $1/ $2
}
#-------------------------------------------------------------------------------

homelocal="/home/felix"
homeremoto=$homelocal
read -r -d '' carpetas << END
a;$homelocal/sice/proyectos/videovigilancia;felix@ute_felix_portatil:$homeremoto/sice/proyectos/videovigilancia
a;$homelocal/sice/proyectos/sumipar;felix@ute_felix_portatil:$homeremoto/sice/proyectos/sumipar
END

for carpeta in $carpetas; do 
	IFS=';' read -a sinc <<< "$carpeta" 

	if [ ${sinc[0]} = "a" ]; then
		# sincronización directa e inversa
		sincroniza ${sinc[1]} ${sinc[2]}
		sincroniza ${sinc[2]} ${sinc[1]}
	fi 
done
