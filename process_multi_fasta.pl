#!/usr/bin/perl
#usage perl ***.pl <Ref> <OUT dir>

open(IN,"<$ARGV[0]");

system "mkdir -p $ARGV[1]"; 

my %seq;
my $last;
while(<IN>){
	chomp;
	s/\r//g;
	s/\n//g;
	if(substr($_,0,1) eq ">"){
		$file=substr($_,1,length($_)-1);
		print "$file\n";
		open(F,">$ARGV[1]\/$file");
	}else{
		tr/[A-Z]/[a-z]/;
		print F "$_";
	}
}

