#!/bin/bash 
readonly ret=$'\n' 

IFS=$'\n'

#-------------------------------------------------------------------------------
help() {
#-------------------------------------------------------------------------------
	nombre=$(basename $0)
	cat <<HELP
* $nombre

	* Uso
		> $nombre [-c] [-v] TAG_ID_TXT quinceminutal
		> $nombre -h

	* Descripción
		Busca el valor y la calidad de la señal TAG_ID_TXT en el quinceminutal especificado en varias tablas.

		Resultado una tabla tabulada con la tabla de donde han salido los datos.

	* Opciones
		* -c:: Saca el encabezado de los datos como primera línea.
		* -v:: Verbose
		* -h:: Saca esta ayuda
		* TAG_ID_TXT :: El código SAIH de texto de una señal
		* quinceminutal:: El quinceminutal con formato "YYYY-mm-dd HH:MM" :: Como el formato lleva un separador entre la fecha y la hora el quinceminutal debe ir enbtre comillas o con el espacio escapado. :: Los minutos tienen que ser un quinceminutal exacto: 00, 15, 30 ó 45.

	* Motivación
		Buscar en qué bases de datos se encuentra un valor para buscar porqué no está pasando a otras.

	* TODO
		Busque en otras tablas:
			buffer de OPC
			mysql de piezómetros
			oracle intranet
			oracle internet

		Que se puedan especificar las bases donde busque

	* Autor
		Félix Anadón Trigo
HELP
}
#-------------------------------------------------------------------------------
sqlche() {
#-------------------------------------------------------------------------------
	sql="$1"
	echo $sql | isql -v -b -d$'\t' CHE chesys chesys
}
#-------------------------------------------------------------------------------
valor_che_buffer_historicos() {
#-------------------------------------------------------------------------------
	tag=$1
	secs=$2
	qm=$(date -d "@$secs" +"%Y-%m-%d %H:%M:%S")
	secs_siguiente=$((secs+15*60))
	qm_siguiente=$(date -d "@$secs_siguiente" +"%Y-%m-%d %H:%M:%S")

	echo "# CHE/buffer_historicos"

	sql="select FECHAHORA, VALOR, CALIDAD from BUFFER_HISTORICOS where TAG='$tag' and FECHAHORA>=to_date('$qm', 'YYYY-MM-DD HH24:MI:SS') and FECHAHORA<to_date('$qm_siguiente', 'YYYY-MM-DD HH24:MI:SS')"
	[ $verbose ] && echo "# sql=$sql"
	sqlche "$sql"
}
#-------------------------------------------------------------------------------
sqlidor() {
#-------------------------------------------------------------------------------
	sql="$1"
	echo $sql | mysql --login-path=Idor Idor -N
}
#-------------------------------------------------------------------------------
valor_Idor_Datos_XXX() {
#-------------------------------------------------------------------------------
	idtag=$1
	qm=$2
	ano=$(date -d "$qm" +%Y)
	fechaIdor=$(date -d "$qm" +"%Y-%m-%d %H:%M:%S")

	echo "# Idor/Datos$ano"

	sql="select Fecha,Valor,NumCalidad from Datos$ano where IdTag=$idtag and Fecha='$fechaIdor'"
	[ $verbose ] && echo "# sql=$sql"
	sqlidor "$sql"
}
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
# main
#-------------------------------------------------------------------------------
if [ "x$1" = "x-h" ]; then help; exit 0; fi 
encabezado=''
encontrado=1
verbose=''
while [ $encontrado ]; do
	encontrado=''
	if [ "x$1" = "x-c" ]; then encabezado=1; shift; encontrado=1;fi
	if [ "x$1" = "x-v" ]; then verbose=1; shift; encontrado=1;fi
done

idtagtxt=$1
qm=$2

# Valores auxiliares
ls_tag=$(sqlidor "select ls_tag from ListaSenalesCHE where ls_tag_txt='$idtagtxt'")
[ $verbose ] && echo "# ls_tag=$ls_tag"

secs=$( date -d "$qm" +"%s")
[ $verbose ] && echo "# segundos=$secs"

# Encabezado
[ $encabezado ] && echo -e "tabla\ttag_id_txt\tfecha\tvalor\tcalidad"

valor_Idor_Datos_XXX "$ls_tag" "$qm"
valor_che_buffer_historicos "$idtagtxt" "$secs"

