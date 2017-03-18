package DeepClone;
use DDP;
use 5.010;
use strict;
use warnings;

=encoding UTF8

=head1 SYNOPSIS

Клонирование сложных структур данных

=head1 clone($orig)

Функция принимает на вход ссылку на какую либо структуру данных и отдаюет, в качестве результата, ее точную независимую копию.
Это значит, что ни один элемент результирующей структуры, не может ссылаться на элементы исходной, но при этом она должна в точности повторять ее схему.

Входные данные:
* undef
* строка
* число
* ссылка на массив
* ссылка на хеш
Элементами ссылок на массив и хеш, могут быть любые из указанных выше конструкций.
Любые отличные от указанных типы данных -- недопустимы. В этом случае результатом клонирования должен быть undef.

Выходные данные:
* undef
* строка
* число
* ссылка на массив
* ссылка на хеш
Элементами ссылок на массив или хеш, не могут быть ссылки на массивы и хеши исходной структуры данных.

=cut

sub clone {
	my $orig = shift;
	my $deep_orig = shift || [];
	my $deep_new = shift || [];
	my $one = 1;
	my $contain_supported_objects_flag = shift ||\$one;
	if (not defined $orig){
		return undef;
	} elsif (ref $orig eq ''){
		return $orig;
	} elsif (ref $orig eq 'ARRAY'){
		my $var=[];
		
			for my $j(0..$#$deep_orig){
				if (defined $orig && $deep_orig->[$j] eq $orig){
					return $deep_new->[$j];
				}
			}

		for my $i (0..$#$orig){
			$var->[$i]=clone($orig->[$i], [@$deep_orig, $orig], [@$deep_new, $var],$contain_supported_objects_flag);			
		}
		if ($$contain_supported_objects_flag ==1 ){
			return $var;
		} else{
			return undef;
		}
	} elsif (ref $orig eq 'HASH'){
		my $var={};

		for my $j(0..$#$deep_orig){
			if ( defined $orig and $deep_orig->[$j] eq $orig){
				return $deep_new->[$j];
			}
		}

		for my $key (keys %$orig){
			my $key_new;
			$key_new = clone($key,[@$deep_orig], [@$deep_new]);
			
			$var->{$key_new} = clone($orig->{$key}, [@$deep_orig, $orig], [@$deep_new, $var],$contain_supported_objects_flag);
			
		}
		
		if ($$contain_supported_objects_flag ==1 ){
			return $var;	
		}else{
				return undef;
			}

	}else {
		$$contain_supported_objects_flag = -1;
		return undef;
	}
}
















1;
