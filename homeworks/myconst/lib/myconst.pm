
package myconst;

use warnings;
use Scalar::Util 'looks_like_number';
use DDP;
use 5.020;

=encoding utf8

=head1 NAME

myconst - pragma to create exportable and groupped constants

=head1 VERSION

Version 1.00

=cut

our $VERSION = '1.00';
my @vars;
#say 'в myconst';
sub import{
	#p @_;

	my ($package, $filename, $line)= caller;
	p @_;
	say $package;
	my $this_name = shift;
	return unless @_;
	my @vars_input = @_;
	for my $i (0..((scalar @vars_input)/2-1)){
		if (ref $vars_input[2*$i+1] eq 'HASH'){
			for (keys %{$vars_input[2*$i+1]}){
				push @vars, {value => $vars_input[2*$i+1]->{$_},
							name => $_,
							group => $vars_input[2*$i]}; 
			}
		}elsif (ref  $vars_input[2*$i+1] eq ''){
			push @vars, {value => $vars_input[2*$i+1],
							name => $vars_input[2*$i],
							group => 'all'}; 
			
		}else {
			die;
		}

	}
	#p @vars;
	my $eval_str='';
	my @export_vars;
	for my $iter (@vars){
		if ($iter->{name} =~ /[^a-zA-Z1-9_]/){
			die;
		}
		eval 'sub '.$package.'::'.$iter->{name}.'(){ return $iter->{value};}';
		$eval_str.=' sub \'.$package.\'::'.$iter->{name}.'(){return '.$iter->{value}.';} ';
	}
	eval 'sub '.$package.'::import{
		say "В импорт Start";
		p @_;
		my $package = caller;
		p $package;
		eval \''.$eval_str.'\';
	}';
}


1;
