#!/bin/bash

#-------------------------------------------------------------------------------
lista_embalses_anadir_campos() {
#-------------------------------------------------------------------------------
	table_name="LISTA_EMBALSES";

	group="(LE_CUENCA_RECEP NUMBER (7),
			LE_EXP_HIDRO VARCHAR2(50),
			LE_ALTITUD_CUENCA NUMBER (4),
			LE_QMAX_EXTREMA NUMBER (14, 3),
			LE_QMAX_PROYECTO NUMBER (14, 3),
			LE_V_NAP NUMBER (14, 3),
			LE_V_NAE NUMBER (14, 3),
			LE_SUPERF_NMN NUMBER (14, 2),
			LE_SUPERF_NAE NUMBER (14, 2),
			LE_SUPERF_NAP NUMBER (14, 2),
			LE_LONG_COSTA_NMN NUMBER (14, 2),
			LE_LONG_EMBA_NMN NUMBER (14, 2))"

	echo "ALTER TABLE $table_name ADD "$group";" 
}
#-------------------------------------------------------------------------------
lista_remotas_ROEA() {
#-------------------------------------------------------------------------------
	table_name="LISTA_REMOTAS";

	group="(LR_ROEA_COD NUMBER (4),
			LR_ROEA_ESTADO VARCHAR2 (32),
			LR_ROEA_INICIO NUMBER (4),
			LR_ROEA_FIN NUMBER (4))"

	echo "ALTER TABLE $table_name ADD "$group";" 
}
#-------------------------------------------------------------------------------
lista_remotas_emplazamiento() {
#-------------------------------------------------------------------------------
	table_name="LISTA_REMOTAS";

	group="( LR_EMPLAZAMIENTO VARCHAR2 (50),
			LR_ORIENTACION VARCHAR2 (50) )"

	echo "ALTER TABLE $table_name ADD "$group";" 
}
#-------------------------------------------------------------------------------
lista_remotas_50k() {
#-------------------------------------------------------------------------------
	table_name="LISTA_REMOTAS";

	group="( LR_HOJA50000 VARCHAR2 (50) )"

	echo "ALTER TABLE $table_name ADD "$group";" 
}
#-------------------------------------------------------------------------------
lista_aforos_pasarelas() {
#-------------------------------------------------------------------------------
	table_name="LISTA_AFOROS_WEB";

	group="( 
			LA_PASARELA NUMBER (1),
			LA_ESCALA NUMBER (1) 
			)"

	echo "ALTER TABLE $table_name ADD "$group";" 
}
#-------------------------------------------------------------------------------
lista_senales_tiempos() {
#-------------------------------------------------------------------------------
	table_name="LISTA_SENALES";

	group="( 
			LS_F_INICIO_SERIE DATE,
			LS_F_FIN_SERIE DATE

			)"

	echo "ALTER TABLE $table_name ADD "$group";" 
}
#-------------------------------------------------------------------------------
lista_senales_observaciones() {
#-------------------------------------------------------------------------------
	table_name="LISTA_SENALES";

	group="( 
			LS_OBS_PUBL VARCHAR2 (3000),
			LS_OBS_PRIV VARCHAR2 (3000) 
			)"

	echo "ALTER TABLE $table_name ADD "$group";" 
}
#-------------------------------------------------------------------------------
lista_remotas_observaciones() {
#-------------------------------------------------------------------------------
	table_name="LISTA_REMOTAS";

	group="( 
			LR_OBS_PUBL VARCHAR2 (3000),
			LR_OBS_PRIV VARCHAR2 (3000) 
			)"

	echo "ALTER TABLE $table_name ADD "$group";" 
}
#-------------------------------------------------------------------------------
# main
#-------------------------------------------------------------------------------

#lista_embalses_anadir_campos
#lista_remotas_ROEA
#lista_remotas_emplazamiento
#lista_remotas_50k
#lista_aforos_pasarelas
#lista_senales_tiempos
lista_remotas_observaciones
#lista_senales_observaciones
