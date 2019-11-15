#!/usr/bin/perl -w -CS
use Getopt::Mixed;

#-------------------------------------------------------------------------------
sub help {
#-------------------------------------------------------------------------------
print <<HELP;
* $0
	Traduce texto actual al equivalente antiguo con glifos y abreviaturas.

	* Uso
		> $0 -h|--help
		> $0 -i|--info
		> $0 [-p|--process] [seleccion_de_ligaduras] [archivo]

	* Opciones
		* -h|--help
			Muestra esta ayuda.
		* -i|--info 
			Saca un listado de palabras que pueden ser traducidas
		* -p|process [archivo]
			Procesa la entrada estándar [ o el archivo especificado].

			Es la opción por defecto.
		* Selección de ligaduras
			* -n|--include ligaduras_seleccionadas
			* -x|--exclude ligaduras_seleccionadas
				ligaduras_seleccionadas son los nombres de las ligaduras o de las eras, separados por comas.

				Las eras para seleccionar van precedidas de la palabra era, dos puntos y el número de era.

				Si no se seleccionan ligaduras el sitema utiliza todas las disponibles.
	* Nomenclatura
		* Era
			Un periodo histórico hasta el que se siguió utilizando la ligadura corespondiente
			- 1:: Manuscritos medievales y libros incunables
			- 2:: Libros del periodo post incunable (siglo XVI)
			- 3:: Hasta finales del s. XVIII y principios del XIX
HELP
	exit;
} 
#-------------------------------------------------------------------------------
#name	title	era	definition_es	definition_en	substitutions
my @ligatures=(
				["s_",3,"s larga","Long s",[["s",'"\N{U+017F}"'],["\N{U+017F}\\b",'"s"']] ],
				["ffl",3,"Ligadura ffl","Ligature ffl",[["ffl",'"\N{U+FB04}"']] ],
				["ffi",3,"Ligadura ffi","Ligature ffi",[["ffi",'"\N{U+FB03}"']] ],
				["ft",3,"Ligadura ft","Ligature ft",[["ft",'"\N{U+FB05}"']] ],
				["fl",3,"Ligadura fl","Ligature fl",[["fl",'"\N{U+FB02}"']] ],
				["ff",3,"Ligadura ff","Ligature ff",[["ff",'"\N{U+FB00}"']] ],
				["fi",3,"Ligadura fi","Ligature fi",[["fi",'"\N{U+FB01}"']] ],
				["ss",3,"Ligadura ss","Ligature ss",[["ss",'"\N{U+1E9E}"']] ],
				["st",3,"Ligadura st","Ligature st",[["st",'"\N{U+FB06}"']] ],
				["s_t",3,"Ligadura \N{U+017F}t","Ligature \N{U+017F}t",[["\N{U+017F}t",'"\N{U+FB05}"']] ],
				["V/",2,"Versiculo","Versicle",[["V/",'"\N{U+2123}"']] ],
				["R/",2,"Responsorio","Response",[["R/",'"\N{U+211F}"']] ],
				["CCCCC",2,"Antisigma de Claudio","Roman reverse one hundred",[["CCCCC",'"\N{U+2183}"']] ],
				["us",1,"Letra us","Letter us",[["us\\b",'"\N{U+a770}"']] ],
				["rum",1,"Rum rotunda","Rum rotunda",[["rum\\b",'"\N{U+a75d}"'],["RUM\\b",'"\N{U+a75c}"']] ],
				["et",1,"Tirón et","Tironian et",[["\\bet\\b",'"\N{U+204a}"']] ],
				["d_",1,"d insular","Insular d",[["\\bd",'"\N{U+a77a}"'],["\\bD",'"\N{U+a779}"']] ],
				["pro",1,"P con floritura (ab. de pro)","P with flourish (abb. de pro)",[["\\bPro\\b",'"\N{U+a752}"'],["\\bpro\\b",'"\N{U+a753}"']] ],
				["per",1,"P barrada (ab. per)","P with stroke (abb. per)",[["\\bP([EAOeao])([Rr])\\b",'"\N{U+a750}"'],["\\bp([eao])r\\b",'"\N{U+a751}"']] ],
				["prae_",1,"P de ardilla (ab. prae)","P with squirrel tail (abb. prae)",[["\\bPrae",'"\N{U+a754}"'],["\\bprae",'"\N{U+a755}"']] ],
				["AE",3,"Ligadura AE","Ligature AE",[["AE",'"\N{U+00C6}"']] ],
				["ae",3,"Ligadura ae","Ligature ae",[["ae",'"\N{U+00E6}"']] ],
				["OE",3,"Ligadura OE","Ligature OE",[["OE",'"\N{U+0152}"']] ],
				["oe",3,"Ligadura oe","Ligature oe",[["oe",'"\N{U+0153}"']] ],
				["nn",1,"macron","macron",[ ["([nN])[nN]",'"\N{U+0304}$1"'], 
											["([aeiouAEIOU])[nN]([^aeiouAEIOU])",'"$1\N{U+0304}$2"'],
											["([aeiouAEIOU])[nN]\\b",'"\N{U+0304}$1"'] 
											]  ],
				["j",1,"j en i","j to i",[ ["j","i"], ["J","I"] ]  ],
				["u",1,"u en v","u to v",[ ["u",'"v"'], ["U",'"V"'] ]  ],
				["P_",1,"Pie de mosca","Paragraph sign",[["^(.)",'"\N{U+00b6}$1"']] ],
				);

my $include='';
my $exclude='';
#-------------------------------------------------------------------------------
sub selected {
#-------------------------------------------------------------------------------
	$name=${$_[0]}[0];
	$era=${$_[0]}[1];
	return 1 if ($include eq '' and $exclude eq '');
	return 1 if ($include=~/\b$name\b/);
	return 1 if ($include=~/\bera:$era\b/ and $exclude!~/\b$name\b/);
	return 0 if ($exclude=~/\b$name\b/);
	return 0;
}
#-------------------------------------------------------------------------------
sub info {
#-------------------------------------------------------------------------------
	print "include=$include\n";
	print "exclude=$exclude\n";

	foreach $ligature (@ligatures) {
		print "Era $$ligature[1], $$ligature[3]: $$ligature[0]\n" if (selected $ligature);
	}
	exit;
}
#-------------------------------------------------------------------------------
sub process {
#-------------------------------------------------------------------------------
	while(<>) {
		foreach $ligature (@ligatures) {
			#print "$$ligature[0]	$$ligature[3]\n";
			foreach $change (@{$$ligature[4]}) {
				#print "change: $$change[0] -> $$change[1]\n";
				$_=~s/$$change[0]/$$change[1]/eeg if (selected $ligature);
			}
		}
		print;
	}
}
#-------------------------------------------------------------------------------

Getopt::Mixed::init('h i p n=s x=s include>n exclude>x process>p help>h info>i');

my $action='process';

while(my($option, $value, $pretty)=Getopt::Mixed::nextOption()) {
	OPTION: {
		$option eq 'h' and do {
			$action='help';
			last OPTION;
		};
		$option eq 'i' and do {
			$action='info';
			last OPTION;
		};
		$option eq 'n' and do {
			$include=$value;
			last OPTION;
		};
		$option eq 'x' and do {
			$exclude=$value;
			last OPTION;
		};
	}
}
Getopt::Mixed::cleanup();

if ($action eq 'help'){help; exit;}
if ($action eq 'info'){info; exit;}
if ($action eq 'process'){process; exit;}
