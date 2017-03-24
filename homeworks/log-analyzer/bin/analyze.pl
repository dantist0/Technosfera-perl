#!/usr/bin/perl

use strict;
use warnings;
use 5.020;
use DDP;
my $filepath = $ARGV[0];
die "USAGE:\n$0 <log-file.bz2>\n"  unless $filepath;
die "File '$filepath' not found\n" unless -f $filepath;

my $parsed_data = parse_file($filepath);
report($parsed_data);
exit;

sub parse_file {
    my $file = shift;
    
    my %ip_strings;
    my %total = (times => 0, avg => 0, data =>0);
    my $result;
    open my $fd, "-|", "bunzip2 < $file" or die "Can't open '$file': $!";
    my $first_time;
    my $last_time;
    my @data_arr = ();
    while (my $log_line = <$fd>) {
        $log_line =~ /(^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}) \[03\/Mar\/2017:([0-9]{2}:[0-9]{2}:[0-9]{2}) \+0300\] ".*" ([0-9]*) ([0-9]*) .*"(?:((?:[0-9]+\.)?[0-9]+)|-)"$/;
        $first_time = $first_time || $2;
        $last_time = $2;
        push (@data_arr, "data_$3") if not grep{$_ eq "data_$3"}@data_arr;

        $total{times}++;
        $total{data}+=$4/1024*(defined $5? $5: 1) if ($3 == 200);
        $total{"data_$3"} += $4/1024;
        if (defined $ip_strings{$1}) {
           $ip_strings{$1}{times}++;
           $ip_strings{$1}{last_time} = $2;
           $ip_strings{$1}{"data_$3"} += $4/1024;
           $ip_strings{$1}{data}+=$4/1024*(defined $5? $5: 1) if ($3 == 200);
        }else {
            $ip_strings{$1}{IP} = $1;
            $ip_strings{$1}{times} = 1;
            $ip_strings{$1}{first_time} = $2;
            $ip_strings{$1}{last_time} = $2;
            $ip_strings{$1}{"data_$3"} = $4/1024;
            $ip_strings{$1}{data}=$4/1024*(defined $5? $5: 1) if ($3 == 200);
        }

        
    }
    close $fd;
    my @ip_strings_top10;
    for (values %ip_strings){
        if ($#ip_strings_top10>=9){
            if ($_->{times} >= $ip_strings_top10[9]->{times}){
                push @ip_strings_top10, $_;
                @ip_strings_top10 = sort {$b->{times} <=> $a->{times}}@ip_strings_top10;
                @ip_strings_top10 = @ip_strings_top10[0..9];
            }
        }else{
            push @ip_strings_top10, $_;
            
        }
    }

    $total{avg} = $total{times}/delta_time($last_time, $first_time)*60;
    for (@ip_strings_top10){
        if (not $_->{first_time} eq $_->{last_time}){
            $_->{avg} = $_->{times}/delta_time($_->{first_time},$_->{last_time})*60
        }else {
            if ($_->{times}>3){
                 $_->{avg} = '>90';
            }else{
                $_->{avg} = 'NaN';
            }
        }
    }
    @data_arr = sort {$a cmp $b}@data_arr;



    $result = "IP count avg data";
    for (@data_arr){
        $result .= " $_";
    }
    $result .= "\n";
    $result .= "total $total{times} $total{avg} $total{data}";
    for (@data_arr){
        $result .= " $total{$_}";
    }
    $result .= "\n";
    for my $ip (@ip_strings_top10){
        $result.= "$ip->{IP} $ip->{times} $ip->{avg} $ip->{data}";
        for (@data_arr){
           if (defined $ip->{$_}){
                $result .= " $ip->{$_}";
           }else{
            $result.=" 0";
           }
        }
        $result .= "\n";
    }

    $result =~ s/(^\S+ [0-9]+ [0-9]+\.[0-9]{2}([0-9]*))/substr($1,0,length($1) - length($2))/emg;
    my $main_template = '^\S+ [0-9]+ \S+';
    my $second_template= ' [0-9]+(\.[0-9]*)';
    for (0..scalar(@data_arr)){
        $result =~ s/($main_template$second_template)/substr($1,0,length($1) - length($2))/emg;
        $main_template.= ' \S+';
    }
    $main_template= '';
    $second_template= '(\S+)';
     my $spaces = sub{
            my $length = shift;
            my $spaces = '';
            for (1..$length){
                $spaces.=' ';
            }
            return $spaces;
        };
    for (0..scalar(@data_arr)+3){
        my $max_lenght=0;
        for ( $result =~ /^$main_template$second_template/mg){
            if (length $_ >$max_lenght){
                $max_lenght = length $_;
            }
        }
        $result =~ s/(^$main_template$second_template)/$1.$spaces->($max_lenght-length $2)/egm;
        $main_template.= '\S+ +';
    }

    say $result;

    return $result;
}

sub report {
    my $result = shift;

    # you can put your code here

}

sub delta_time{
    my $time1=shift;
    my $time2=shift;

    $time1 =~ /([0-9]{2}):([0-9]{2}):([0-9]{2})/;
    $time1 = $3+$2*60+$1*60*60;
    $time2 =~ /([0-9]{2}):([0-9]{2}):([0-9]{2})/;
    $time2 = $3+$2*60+$1*60*60;
    if ($time1>=$time2){
    return $time1-$time2;
    }else {
        return $time2-$time1;
    }   
}
