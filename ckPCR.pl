#!/usr/bin/perl
#usage perl ckPCR.pl <*.EPCR> <indel> <Query or Ref> <outdir>
use strict;
open(IN,"<$ARGV[0]");
open(ID,"<$ARGV[1]");
open(OUT,">$ARGV[3]TMP");

my $check="$ARGV[2]";
my %list;
my %indel;

while(<ID>){
	if(substr($_,0,1) eq "#"){
		next;	
	}else{
		my @array=split("\t",$_);
			if($check eq "Query"){
					$indel{$array[0]}="$array[3]\t$array[4]";
			}else{
					$indel{$array[0]}="$array[1]\t$array[2]";
			}	
	}
}




my $line_count=0;
while(<IN>){
	if($line_count==0){
		print OUT "#InDel_ID\t".substr($_,6,length($_));
		$line_count=1;
	}

	chomp;
	my @array=split("\t",$_);
	my $target=substr($array[1],0,length($array[1])-2);
	my $PL_head=substr($array[1],0,length($array[1])-2);
	my $PR_head=substr($array[2],0,length($array[1])-2);

	if($PR_head eq $PL_head){	
		if(exists($list{$target})){
				$list{$target}="";
		}else{
				my $tmpline=substr($target,0,length($target)-2);
				for(my $i=1;$i<scalar(@array);$i++){
					$tmpline.="\t$array[$i]";
				}
					$list{$target}=$tmpline;
		}
	}else{
		next;	
	}
}

my $key;
my $value;
while(($key,$value)=each(%list)){
	if($value eq ""){
		next;	
	}else{
		my @arrayProd=split("\t",$value);
		my @arrayIndel=split("\t",$indel{substr($key,0,length($key)-2)});
		my $indel_start=$arrayIndel[0];
		my $indel_end=$arrayIndel[1];
		my $prod_start=$arrayProd[11];
		my $prod_end=$arrayProd[12];

		if(($prod_start<$indel_start)and($prod_end>$indel_end)){
			print "INDEL:$indel_start ,$indel_end;  PROD:$prod_start,$prod_end \n";	
			print OUT "$value\n";
		}		
	}
}
close(OUT);
close(IN);

system "sort $ARGV[3]TMP -o $ARGV[3]TMP";
system "mv $ARGV[3]TMP $ARGV[0]";
