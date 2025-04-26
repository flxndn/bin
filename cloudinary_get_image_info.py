#!/usr/bin/env python3
# -*- coding: utf-8 -*-
import sys, pprint, os, json, getopt

#-------------------------------------------------------------------------------
def ayuda():
#-------------------------------------------------------------------------------
	ayuda='''* cloudinary_get_image_info.py
	* Uso
		> cloudinary_get_image_info.py -h
		> cloudinary_get_image_info.py [opciones] fichero_json_imagen
	* Descripción
		Saca en formato yaml (compatible con libros.yaml) de las imágenes que 
		se han subido con cloudinary_upload.sh y que han generado los 
		ficheros ''fichero_json_imagen_grande'' y opcionalmente 
		''fichero_json_imagen_pequeña''.
	* Opciones
		- -s| --sectxt :: Saca la imagen en formato imagen de sectxt. :: Es la opción por defecto.
		- -y| --yaml :: Saca la imagen en formato imagen de yaml (para secciones).
		- -d| --debug :: Saca los datos de la imagen que se han leído.
	'''
	print(ayuda)
#-------------------------------------------------------------------------------
def procesa(args):
#-------------------------------------------------------------------------------
	info={}
	if len(args) == 1 :
		info['file']='stdin'
	else:
		info['file']=args[1]

	if len(args) == 1 :
		info['data'] = json.load(sys.stdin)
	else:
		try:
			with open(args[1], "r") as read_file:
				info['data'] = json.load(read_file) 
		except:
			print("El fichero %s no existe." % (args[1]))

	return info
#-------------------------------------------------------------------------------
def print_debug(info):
#-------------------------------------------------------------------------------
	pp=pprint.PrettyPrinter(indent=4)
	pp.pprint(info)
#-------------------------------------------------------------------------------
def print_yaml(info):
#-------------------------------------------------------------------------------
	if 'alt' in  info['data']['img']['context']['custom'] :
		text=info['data']['img']['context']['custom']['alt']
	else:
		text=''

	print("          - título: "+ info['data']['img']['context']['custom']['caption'])
	print("            texto: "+ text)
	print("            mini: " + info['data']['thumb']['secure_url'])
	print("            maxi: " + info['data']['img']['secure_url'])
#-------------------------------------------------------------------------------
def print_sectxt(info):
#-------------------------------------------------------------------------------
	print("{{" + info['thumb']['data']['secure_url'] + "|"+ info['img']['data']['context']['custom']['caption'] + "|" + info['img']['data']['secure_url']+"}}")
#-------------------------------------------------------------------------------
def main(argv):
#-------------------------------------------------------------------------------
	accion="yaml"
	try:
		opts, args = getopt.getopt(argv, "hsyd", ["help", 'sectxt', 'yaml', 'debug'])
	except getopt.GetoptError:
		print("Error")
		ayuda()
		sys.exit(2)
	for opt, arg in opts:
		if opt in ("-h", "--help"):
			ayuda()
			sys.exit()
		if opt in ("-d", "--debug"):
			accion='debug'
		if opt in ("-y", "--yaml"):
			accion='yaml'
		if opt in ("-s", "--sectxt"):
			accion='sectxt'

	info=procesa(argv)

	if accion == 'yaml':
		print_yaml(info)
	if accion == 'sectxt':
		print_sectxt(info)
	if accion == 'debug':
		print_debug(info)
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
if __name__ == "__main__":
	main(sys.argv)
