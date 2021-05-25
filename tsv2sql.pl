#!/usr/bin/perl -w

my $formato_fecha='YYYY-MM-DD HH24:MI:SS';

if ($#ARGV >-1 && $ARGV[0] eq "-h") {
print <<HELP;
* $0
	Convierte los ficheros de datos separados por tabuladores (tsv) en sql 
	para actualizar sql.

	La primera línea del fichero tsv tiene que contener los nombres de los 
	campos.

	La primera columna tiene que contener el índice de la tabla.

	* Uso
		> $0 [-kK] [-f formato_fecha] -t nombre_de_la_tabla [-d lista_de_campos_de_fecha] [-x lista_de_campos_de_texto] [fichero.csv]

	* Opciones
		* -h :: Muestra esta ayuda.
		* -t nombre_de_la_tabla :: Nombre de la tabla donde se insertarán los registros.
		* -d lista_de_campos_de_fecha :: lista de campos de tipo fecha hora, separados por comas :: Sólo es útil para la base de datos Oracle, para las bases de  datos MySQL hay que indicarlas como texto.
		* -c lista_de_campos_con_coma :: En estos campos la coma será reemplazado por un punto.
		* -x lista_de_campos_de_texto :: lista de campos de tipo texto, separados por comas
		* -i lista_de_campos_índice :: Lista de los campos que se utilizan para buscar, separados por comas.
		* -k :: Realiza [[http://dev.mysql.com/doc/refman/5.1/en/insert-on-duplicate.html insert y si existe duplicado de clave un update]].:: Sólo funciona en MySQL
		* -K :: Realiza [[https://stackoverflow.com/questions/10589350/oracle-db-equivalent-of-on-duplicate-key-update insert y si existe duplicado de clave un update]]. :: Sólo funciona en Oracle
		* -f formato_fecha:: Formato que se utiliza pra la fecha, por defecto es $formato_fecha. :: Sólo es necesario en Oracle
HELP
	exit;
}

my $tabla="";
my $indices="";
my $fechas="";
my $comas="";
my $textos="";
my $onDuplicateKey=0;

# Bucle para que las opciones puean ir en cualquier orden
my $parseando=1;
while($parseando) {
	$parseando=0;
	if ($#ARGV >0) {
		if ($ARGV[0] eq "-t") {
			$tabla=$ARGV[1];
			shift; shift;
			$parseando=1;
		}elsif ($ARGV[0] eq "-i") {
			$indices=$ARGV[1];
			shift; shift;
			$parseando=1;
		} elsif ($ARGV[0] eq "-d") {
			$fechas=$ARGV[1];
			shift; shift;
			$parseando=1;
		} elsif ($ARGV[0] eq "-c") {
			$comas=$ARGV[1];
			shift; shift;
			$parseando=1;
		} elsif ($ARGV[0] eq "-x") {
			$textos=$ARGV[1];
			shift; shift;
			$parseando=1;
		} elsif ($ARGV[0] eq "-k") {
			$onDuplicateKey=1;
			shift;
			$parseando=1;
		} elsif ($ARGV[0] eq "-K") {
			$onDuplicateKey=2;
			shift;
			$parseando=1;
		} elsif ($ARGV[0] eq "-f") {
			$formato_fecha=$ARGV[1];
			shift;shift;
			$parseando=1;
		} 
	}
}
if ($tabla eq "") {
	die "ERROR: No se ha especificado la tabla a actualizar.";
}
#-------------------------------------------------------------------------------
# main
#-------------------------------------------------------------------------------
my $campos=<>;
chomp $campos;
$campos=~s/\r//;

my @campos=split("\t", $campos);
#my $idfield=shift(@campos);
if (!$indices) {
	$indices=$campos[0];
}

while(<>) {
	chomp;s/\r//;
	@valores=split("\t",$_, -1);
	#my $id=shift(@valores);
	my @updates;
	my @busquedas;
	my @valores_preparados;
	foreach(@campos){
		$valor=shift(@valores);
		if ($valor eq "" ){
			$valor='NULL';
		} elsif($fechas=~/,*$_,*/) {
			$valor="TO_DATE('$valor', '$formato_fecha')"; 
		} elsif($comas=~/,*$_,*/) {
			$valor=~s/,/./;
		} elsif($textos=~/,*$_,*/) {
			$valor="'$valor'";
		}
		push(@valores_preparados, $valor);

		if($indices=~/,*$_,*/) {
			push(@busquedas, "$_=$valor");
		} else {
			push(@updates, "$_=$valor");
		}
	}
	if(@updates) {
		my $updates=join(", ", @updates);
		my $campos=join(", ", @campos);
		my $valores_preparados=join(", ", @valores_preparados);
		my $busquedas=join(" AND ", @busquedas);

		if ($onDuplicateKey==0) {
			$sql="UPDATE $tabla SET $updates WHERE $busquedas;";
		} elsif ($onDuplicateKey==2) {
			# truqui para updatear los duplicados en oracle
			my (@creacion_tabla, @comparador);
			foreach(@busquedas) {
				my ($campo, $valor) = split "=";
				push @creacion_tabla, "$valor AS $campo";
				push @comparador, "u.$campo = a.$campo";
			}
			$creacion_tabla = join(", ", @creacion_tabla);
			$comparador = join(" AND ", @comparador);
			$sql="MERGE INTO $tabla u USING (SELECT $creacion_tabla  FROM dual) a ON ($comparador) WHEN MATCHED THEN UPDATE SET $updates WHEN NOT MATCHED THEN INSERT ($campos) VALUES ($valores_preparados);";
		} else {
			# onDuplicateKey==1
			# truqui para updatear los duplicados en mysql
			$sql="INSERT INTO $tabla ($campos) VALUES ($valores_preparados) ON DUPLICATE KEY UPDATE $updates;";
		}
		print "$sql\n";
	};
}
