#!/usr/bin/perl
#usage perl callMFE.pl <*.pfasta> <genome_file> <label> <outdir>
#for example, perl callMFE.pl *.pfasta ref_genome.fa cultivar ./abc/
open(IN,"<$ARGV[0]");
my $Bin=$ARGV[3];
system "rm -rf $Bin\/tp";
system "mkdir $Bin\/tp";

my $genome=$ARGV[1];
my $label=$ARGV[2];
my $last_id="1";
my $line="";
my $count=0;
my $outdir=$ARGV[3];

while(<IN>){
	s/\r//g;
	chomp;
	if(substr($_,0,1) eq ">"){
		my $tmphead=$_;
		$tmphead=~s/\>//g;
		my $this_id=substr($tmphead,0,length($tmphead)-4);
		if((!($this_id eq $last_id))){
			if($last_id eq "1"){			
				open(TMP,">$Bin\/tp\/tmp");
				print TMP "$_\n";
				$last_id=$this_id;
			}else{
				close(TMP);
				$count++;
				my $cmd="MFEprimer --tab -o $Bin\/tp\/tmp".$count." -i $Bin\/tp\/tmp -d ".$genome;
				system "$cmd\n";				
				system "rm $Bin\/tp\/tmp";
				open(TMP,">$Bin\/tp\/tmp");
				print TMP "$_\n";
				$last_id=$this_id;	
			}
		}else{
			print TMP "$_\n";
		}
	}else{
			print TMP "$_\n";
	}
}
close(IN);
close(TMP);
$count++;

system  "MFEprimer --tab -o $Bin\/tp\/tmp".$count." -i $Bin\/tp\/tmp -d ".$genome;
system "rm $Bin\/tp/tmp";
#system 'find ./tp/ -name tmp*|xargs cat>'.$ATGV[0].'.temp';
system "find $Bin"."\/tp\/ -name tmp*|xargs cat>".$ARGV[3].'.temp';
system "rm -rf $Bin\/tp";
system 'sort -r '.$ARGV[3].'.temp |uniq>'.$outdir.'/'.'all_'.$label.'.EPCR';
system 'rm '.$ARGV[3].'.temp';
