
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
	

	my ($package, $filename, $line)= caller;
	
	
	my $this_name = shift;
	return unless @_;
	my @vars_input = @_;
	for my $i (0..((scalar @vars_input)/2-1)){
		if (ref $vars_input[2*$i+1] eq 'HASH'){
			for (keys %{$vars_input[2*$i+1]}){
				push @vars, {value => $vars_input[2*$i+1]->{$_},
							name => $_,
							group => $vars_input[2*$i],
							dropped => 0}; 
			}
		}elsif (ref  $vars_input[2*$i+1] eq ''){
			push @vars, {value => $vars_input[2*$i+1],
							name => $vars_input[2*$i],
							group => 'all',
							dropped => 0}; 
			
		}else {
			die;
		}
 
	}
	
	my $eval_str='';
	my @export_vars;
	for my $iter (@vars){
		if ($iter->{name} =~ /[^a-zA-Z1-9_]/){
			die;
		}
		eval 'sub '.$package.'::'.$iter->{name}.'(){ return $iter->{value};}';
		$eval_str.=' sub \'.$package.\'::'.$iter->{name}.'(){return '.$iter->{value}.';} ';
		$iter->{eval_str} = ' sub \'.$package.\'::'.$iter->{name}.'(){return '.$iter->{value}.';} ';
		
	}
		eval 'sub '.$package.'::import{
			
			
		for (@vars){
			$_->{dropped}=0;
		}
		my $this_name = shift;
		my $package = caller;
		if (not @_){
		
		eval \''.$eval_str.'\';
		}else{
			for my $get_str (@_){
				if ( not(substr($get_str,0,1) eq ":")){
					for my $var (@vars){
						if ($var->{name} eq $get_str){
							
							eval \'sub \'.$package.\'::\'.$var->{name}.\'(){return $var->{value};} \';
							$var->{dropped}=1;
						}
					}	
				}elsif($get_str eq ":all"){
					
					for my $var (@vars){
						
						if ($var->{dropped} == 0){
							eval \'sub \'.$package.\'::\'.$var->{name}.\'(){return $var->{value};} \';
							$var->{dropped}=1;
						}
					}	
				}elsif(substr($get_str,0,1) eq ":"){
					
					my @group_var = grep {":"."$_->{group}" eq $get_str}@vars;
					for my $var (@group_var){
						
						if ($var->{dropped} == 0){
							eval \'sub \'.$package.\'::\'.$var->{name}.\'(){return $var->{value};} \';
							$var->{dropped}=1;
						}
					}	
				}
			}
		}
	}';
}


1;
