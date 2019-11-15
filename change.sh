#!/bin/bash

readonly ARGS="$@"
readonly PROGNAME=$(basename $0)
readonly LOGDIR=~/.change

readonly R_CAMBIADO=0
readonly R_NO_CAMBIADO=1

readonly R_MISMO_VALOR=0
readonly R_DIFERENTE_VALOR=1
readonly R_ERROR_NO_EXISTE=2
readonly R_ERROR_SINTAXIS=3
#-------------------------------------------------------------------------------
help() {
#-------------------------------------------------------------------------------
cat <<HELP
	* $PROGNAME
		Guarda en el valor de la variable indicada y devuelve un valor que 
		depende si la variable ha cambiado.
		* Uso
			> $PROGNAME [-sd|--set|--difference] nombre valor
			> $PROGNAME [-cl|--cat|--log] nombre valor
		* Opciones
			* -h | --help
				Muestra esta ayuda
			* -s | --set
				Guarda el valor si es diferente del valor anterior.
			* -l | --log
				Saca el listado completo de esa variable.
			* -c | --cat
				Saca la fecha y el último valor separados por un tabulador.
			* -d | --difference
				No altera los valores guardados sólo devuelve el valor de compararlo.
		* Funcionamiento
			
		* Valores devueltos
			- $R_MISMO_VALOR:: El valor es el mismo que había anteriormente.
			- $R_DIFERENTE_VALOR:: El valor es diferente.
			- $R_ERROR_NO_EXISTE:: El valor no estaba guardado.
		* Directorios
			Por defecto guarda las variables en el directorio $LOGDIR.
HELP
}
#-------------------------------------------------------------------------------
parsearg(){
#------------------------------------------------------------------------------- 
	local arg=

	for arg; do
		local delim=""
		case "$arg" in
			--help)			args="${args}-h ";;
			--set)			args="${args}-s ";;
			--cat)			args="${args}-c ";;
			--log)			args="${args}-l ";;
			--difference)	args="${args}-d ";;
			*) [[ "${arg:0:1}" == "-" ]]  || delim="\""
				args="${args}${delim}${arg}${delim} ";;
		esac
	done

	eval set --  $args
	while getopts "hscdl" OPTION; do
		case $OPTION in
			h) help; exit;;
			s) readonly COMMAND="set"; shift;;
			c) readonly COMMAND="cat";shift;;
			d) readonly COMMAND="difference";shift;;
			l) readonly COMMAND="log";shift;;
		esac
	done 

	readonly VARIABLE_NAME=$1; shift;
	readonly VARIABLE_VALUE="$*"
}
#-------------------------------------------------------------------------------
difference() {
#-------------------------------------------------------------------------------
	if [ ! -e $log_file ];then 
		return $R_ERROR_NO_EXISTE;
	else
		last_value="$(tail -n1 $log_file|cut -f2)"
		if [ "x$VARIABLE_VALUE" == "x$last_value" ]; then
			return $R_MISMO_VALOR;
		else
			return $R_DIFERENTE_VALOR;
		fi 
	fi
}
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
main() {
#-------------------------------------------------------------------------------
	if [ ! -d $LOGDIR ];then mkdir -p $LOGDIR;fi
	
	log_file="$LOGDIR/$VARIABLE_NAME"
	case $COMMAND in
		set) 
			difference;
			local isdifferent=$?
			if [ $isdifferent != $R_MISMO_VALOR ] ; then
				echo "$(date --rfc-3339=ns)	$VARIABLE_VALUE" >> $log_file
				return $R_CAMBIADO
			else
				return $R_NO_CAMBIADO
			fi
			;;
		cat) 
			if [ ! -r $log_file ]; then
				return $R_ERROR_NO_EXISTE
			else 
				tail -n 1 $log_file;
			fi
			;;
		difference) 
			difference;
			;;
		log) 
			if [ ! -r $log_file ]; then
				return $R_ERROR_NO_EXISTE
			else 
				cat $log_file;
			fi
			;;
		*) (
			echo "Error. orden no especificada"
			help
		   ) >&2
		   return $R_ERROR_SINTAXIS
			;;
	esac
} 
#------------------------------------------------------------------------------- 
#------------------------------------------------------------------------------- 
parsearg $ARGS
main 
