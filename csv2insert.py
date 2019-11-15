#!/usr/bin/python
# -*- coding: utf-8 -*-

import re, getopt, sys


def usage():
	print """* csv2insert.py
	Convierte una tabla separada por tabuladores en una sentencia insert.
	
	* Uso
		csv2insert.py -h
		csv2insert.py [-b|B] -t tabla [-c campos] fichero
		Los campos es una lista entre comillas de los nombres de los campos separados por comas.
	* Opciones
		-b
			Insert en modo 'bulk'. Una sóla sentencia INSERT con todos los campos.

			Es la opción por defecto. 

		-B 
			'No bulk'. Realiza una sentencia INSERT para cada registro.
	* Autor
		Félix Anadón Trigo
	* Fecha
		2010-02-09 09:37
		"""

def toTabla(tabla,campos,registros,bulk):
	"""Genera una sentencia insert para la tabla, campos y registros proporcionados por los parametros.

	Si campos está vacío o es None , no lo utiliza.
	
	Devuelve una cadena."""

	aux=""
	insert= "INSERT INTO %s " % tabla
	if campos is not None and len(campos) > 0:
		insert += "(%s) " % ", ".join(campos)
	insert += "VALUES "

	registrosOut=[]
	for registro in registros:
		registrosOut.append( "(%s)" % ", ".join(registro) )

	aux += insert
	if bulk:
		sep= ",\n"
	else:
		sep= ";\n"+insert+" "

	aux += sep.join( registrosOut )
	aux += ";"
	return aux

def leeTabla( fichero ):
	"""Lee un fichero y devuelve una matriz con los resultados."""

	f = open( fichero, "r" )

	tabla=[]
	for linea in f.readlines():
		linea = re.sub("[\r\n]","",linea)
		registros = []
		for registro in re.split("\t",linea):
			if re.search("([^0-9\.\-])",registro) and registro != 'NULL':
				registro="'%s'" % registro
			registros.append( registro )
		tabla.append( registros )
	return(tabla)

def main():
	"""Funcion principal. Devuelve los dias entre dos fechas.
	Opcion l. Solo los dias laborables."""

	try:
		opts, args = getopt.getopt(sys.argv[1:], \
									"ht:c:bB",\
									["help", "tabla=","campos="])
	except getopt.GetoptError, err:
		# print help information and exit:
		print str(err) # will print something like "option -a not recognized"
		usage()
		sys.exit(2)

	bulk=1;
	tabla=""
	campos=[]
	for o, a in opts:
		if o in ("-h", "--help"):
			usage()
			sys.exit()
		else:
			if o in ("-t","--tabla"):
				tabla = a
			elif o in ("-c","--campos"):
				campos = re.split(" *, *",a)
			elif o in ("-b"):
				bulk = 1;
			elif o in ("-B"):
				bulk = 0;
			else:
				assert False, "unhandled option"

	registros = leeTabla(args[0])

	print toTabla( tabla, campos, registros, bulk)

if __name__ == "__main__":
	main()
