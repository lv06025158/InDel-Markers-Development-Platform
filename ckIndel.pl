#!/usr/bin/perl
#Ref:9311
#Query:irgsp
#Usage perl ckIndel.pl <*Indel> <ref.EPCR> <query.EPCR> <outdir> <ptab file>


open(ID,"<$ARGV[0]");#indel file
open(IN_9311,"<$ARGV[1]");#9311 epcr
open(IN_IRGSP,"<$ARGV[2]");#irgsp epcr
open(OUT,">$ARGV[3]diff0");

my %marker_9311;    #store primerL->product size  #test_994-2-L
my %marker_irgsp;		#store primerL->product size
my %all_9311;				#store primerL->all info
my %all_irgsp;			#store primerL->all info

my %indel;					#store InDel->Size, Which
my %marker;					#store InDels whose product size diff is OK
my $max_diff=0;

#store indel length
while(<ID>){
	chomp;
	if(substr($_,0,1) eq "#"){
		next;	
	}else{
		my @array=split("\t",$_);
		$indel{$array[0]}=$array[5]."\t$array[6]"; #length, which deletion	
	}
}
close(ID);


#store pcr product size
# irgsp
while(<IN_IRGSP>){
	chomp;
	if(substr($_,0,1) eq "#"){
		next;	
	}else{
		my @array=split("\t",$_);	
		$marker_irgsp{$array[1]}="$array[5]";	
		$all_irgsp{$array[1]}=$_;
	}	
}

# 9311
while(<IN_9311>){
	chomp;
	if(substr($_,0,1) eq "#"){
		next;	
	}else{
		my @array=split("\t",$_);	
		$marker_9311{$array[1]}="$array[5]";
		$all_9311{$array[1]}=$_;	
	}	
}

print OUT "InDel_ID\tdiff\tInDel_ID\tFpID\tRpID\tHitID\tPPC\tSize\tAmpGC\tFpTm\tRpTm\tFpDg\tRpDg\tBindingStart\tBindingStop\tAmpSeq\t|\tInDel_ID\tFpID\tRpID\tHitID\tPPC\tSize\tAmpGC\tFpTm\tRpTm\tFpDg\tRpDg\tBindingStart\tBindingStop\tAmpSeq\n";
#Overlap
my $key;
my $value;		
while(($key,$value)=each(%marker_irgsp)){
	if(!exists($marker_9311{$key})){
		next;	
	}else{
			my $this_indel=substr($key,0,length($key)-4);
			my @tmp=split("\t",$indel{$this_indel});
			my $this_indel_length=$tmp[0];
			my $this_deletion=$tmp[1];
			my $diff=$marker_9311{$key}-$marker_irgsp{$key};
			
			if($this_deletion eq "Ref"){
					$this_indel_length=-$this_indel_length;
			}else{
			}

			print OUT "$this_indel\t".abs($this_indel_length-$diff)."\t".$all_irgsp{$key}."\t\|\t".$all_9311{$key}."\n";
			
	}
}

close(OUT);
system "cut  -f '1-2,4-8,14-17,21-23,29-31' $ARGV[3]diff0 > $ARGV[3]diff";
system "rm $ARGV[3]diff0";
open(DIFF,"<$ARGV[3]diff");
open(DIFF_SEQ,">$ARGV[3]diff_seq");

open(PT,"<$ARGV[4]");
my %h_primer;
while(<PT>){
	chomp;
	my @tmp=split("\t",$_);
	$h_primer{$tmp[0]}=$tmp[1];
}
close(PT);

my $line=0;
while(<DIFF>){
	chomp;
	if($line==0){
	print DIFF_SEQ "InDel_ID\tdiff\tFpID\tFpSeq\tRpID\tRpSeq\tHitID\tPPC\tSize\tBindingStart\tBindingStop\tAmpSeq\t|\tHitID\tPPC\tSize\tBindingStart\tBindingStop\tAmpSeq\t\n";
	}else{
		my @tmp=split("\t",$_);
		for(my $i=0;$i<scalar(@tmp);$i++){
			if($i==2){
				print DIFF_SEQ "$tmp[$i]\t$h_primer{$tmp[$i]}\t";
			}elsif($i==3){
				print DIFF_SEQ "$tmp[$i]\t$h_primer{$tmp[$i]}\t";
			}else{
				print DIFF_SEQ "$tmp[$i]\t";
			}
		}
		print DIFF_SEQ "\n";
	}
	$line++;
}
system "rm $ARGV[3]diff";


