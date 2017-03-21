package Anagram;

use strict;
use warnings;
use 5.020;
use utf8;
use Encode;

=encoding UTF8

=head1 SYNOPSIS

Поиск анаграмм

=head1 anagram($arrayref)

Функцию поиска всех множеств анаграмм по словарю.

Входные данные для функции: ссылка на массив - каждый элемент которого - слово на русском языке в кодировке utf8

Выходные данные: Ссылка на хеш множеств анаграмм.

Ключ - первое встретившееся в словаре слово из множества
Значение - ссылка на массив, каждый элемент которого слово из множества, в том порядке в котором оно встретилось в словаре в первый раз.

Множества из одного элемента не должны попасть в результат.

Все слова должны быть приведены к нижнему регистру.
В результирующем множестве каждое слово должно встречаться только один раз.
Например

anagram(['пятак', 'ЛиСток', 'пятка', 'стул', 'ПяТаК', 'слиток', 'тяпка', 'столик', 'слиток'])

должен вернуть ссылку на хеш


{
    'пятак'  => ['пятак', 'пятка', 'тяпка'],
    'листок' => ['листок', 'слиток', 'столик'],
}

=cut

sub anagram {
	my $words_list = shift;
	my %result = ();
	for (@$words_list){
		Encode::_utf8_on($_);
	}
	@$words_list 	=  map  {lc $_} @$words_list;
	for (@$words_list){
		if (defined $_){
			my $key = $_;
			$_=undef;
	
			for (@$words_list){
				
				if (is_equal($_, $key) and not contain_equals($_,$result{$key})){
					
					$result{$key} = $result{$key}||[$key];
					$result{$key} = [@{$result{$key}}, $_];
	
					$_ = undef;
	
				}
				if (contain_equals($_,$result{$key})){
					$_ = undef;
				}
	
			}
	
		}
	}	

	my %result2;
	for (values %result){
		@$_ =  sort { fc($a) cmp fc($b) }@$_;
		@$_ = map {encode ('utf8', $_)}@$_;
	}
	for (keys %result){
		$result2{encode ('utf8', $_)} = $result{$_};
	}
	return \%result2;
}
sub is_equal{
	my $one = shift;
	my $two = shift;
	if ( not defined $one or not defined $two){
		return 0;
	}

	if (length $one == length $two){
		for (split ('', $two)){
			last unless($one =~ s/$_//i)
	}
	if (length $one == 0){
		return 1;
	}else {
		return 0;
	}

		
	}else {
		return 0;
	}

}

sub contain_equals{
	my $scalar = shift;
	my $list = shift;
	if (defined $list and defined $scalar and  scalar (grep{fc($scalar) eq fc($_)}@{$list}) >0){
		return 1;
	}else {return 0};
}

1;
