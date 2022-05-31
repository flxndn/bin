#!/usr/bin/perl -w
use utf8;

#-------------------------------------------------------------------------------
sub interpola_valores{
#-------------------------------------------------------------------------------
	my ($vi, $vf, $ii, $if, $indice) = @_;
	$v = ($vi*($if-$indice) + $vf*($indice-$ii)) / ($if-$ii);
	return sprintf("%.0f", $v);
}
#-------------------------------------------------------------------------------
sub interpola_coordenadas{
#-------------------------------------------------------------------------------
	my ($ii, $ci) = @{$_[0]};
	my ($if, $cf) = @{$_[1]};
	my $indice = $_[2];
	my ($wi, $hi, $xi, $yi) = split(/[x\+]/, $ci);
	my ($wf, $hf, $xf, $yf) = split(/[x\+]/, $cf);
	my $w= interpola_valores($wi, $wf, $ii, $if, $indice);
	my $h= interpola_valores($hi, $hf, $ii, $if, $indice);
	my $x= interpola_valores($xi, $xf, $ii, $if, $indice);
	my $y= interpola_valores($yi, $yf, $ii, $if, $indice);
	return $w."x$h+$x+$y";
}
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
@lines=<>;
chomp @lines;
my @keys;
my $contador=0;
foreach(@lines) {
	if (/\t/) {
		my($img,$coordenadas) = split(/\t/);
		push @keys, [$contador, $coordenadas];
	}
	$contador++;
}

$contador=0;
$actual=-1;
foreach(@lines) {
	if(/\t/) {
		print "$_\n";
		$actual++;
	} else {
		my $imagen=$_;
		my $coordenadas = interpola_coordenadas($keys[$actual], $keys[$actual+1], $contador);
		print "$imagen\t$coordenadas\n";
	}
	$contador++;
}
