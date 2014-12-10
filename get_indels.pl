#!/usr/bin/perl
# get indel from nucmer *.aligns file 2013-3-16
# options: 
	#1,-min minimal indel length (eg, 6,7...);
	#2,-max maximal indel length(eg,100);
	#3,-flanking    flanking sequence length (eg 100,200...);
	#4,-iden	identy of flanking sequence (eg 0.98, 1)
	#5,-file   			input aligns file (produced by nucmer show-aligns)
	#6,-out		input output directory

use strict;
use Getopt::Long;

# declare default values for variables
	my $dmin=6;
	my $dmax=100;
 	my $flanking=150;
  	my $seqfile='';
  	my $iden=1;
	my $outdir="";

#get parameter
if(GetOptions('min=i' => \$dmin,
        'max=i' => \$dmax,
				'flanking=i'=>\$flanking,
				'file=s'=>\$seqfile,
				'iden=f'=>\$iden,
				'out=s'=>\$outdir
)){
}else{
	exit;
}

#check parameter
if($dmin>$dmax){
	print "min<max!\n";	
	exit;
}
if($flanking<=0){
	print "Illegal flanking!\n";	
	exit;
}


#preprocess alignment file
&process_align($seqfile);

#---------------MAIN-------find indel----------###########################
open(IN,"<$seqfile.sim");
open(OUT,">$seqfile.indels"); #result table
print OUT "#indel_id\tref_start_abs\tref_end_abs\tque_start_abs\tque_end_abs\tindel_length\twhich_deletion\tidentity\tflanking_length\tindel_seq\tref_align\tque_align\tins_align\tdel_align\tins_region\tdel_region\n";

#Result format

my $indel_id=0;
my $indel_start;
my $indel_end;
my $indel_start_q;
my $indel_end_q;

my $indel_length;
my $which_seq;
my $identity;
my $flanking_length;
my $up_seq;
my $indel_seq;
my $down_seq;

my $alignA;
my $alignB;

my $dataA;
my $dataB;
my $startA;
my $startB;

my $line_index=0;
while(<IN>){
	chomp;
	my @tmp_array=();
	my $startnew=substr($_,0,1);
	if($startnew eq">"){				#new alignment cluster region begin
		#<<<<<<finished reading previous region

		#>>>>>>to find indel in the stored string
		if($line_index!=0){
			&find_indel($dataA,$startA,$dataB,"A",$startB);
			&find_indel($dataB,$startB,$dataA,"B",$startA);
			$dataA="";
			$dataB="";
			$startA=0;
			$startB=0;
		}
		$line_index=1;
	}else{      #in the same cluster
			@tmp_array=split("\t",$_);
			if($tmp_array[0]eq"A"){
					$dataA.=$tmp_array[2];
			}else{
					$dataB.=$tmp_array[2];
			}

			#store region start position
			if($line_index==1){     #start of A
					$startA=$tmp_array[1];
			}elsif($line_index==2){ #start of B
					$startB=$tmp_array[1];
			}

			$line_index++;
	}	
}
			&find_indel($dataA,$startA,$dataB,"A",$startB);
			&find_indel($dataB,$startB,$dataA,"B",$startA);
close(IN);
close(OUT);

system "rm $seqfile.sim";
my $tmpout=$seqfile;
$tmpout=~s/\.aligns//;
system "mv $seqfile.indels $tmpout\.indels";
system "mv $tmpout\.indels $outdir";
#########----------------SUB--------------------##########################

###1, simplify the alignment file
### output format
### A	start	seq
### B start seq
sub process_align{
	#print "formating alignment\n!";
	my $file=$_[0];
	my $outfile=$file.".sim\n";
	open(IN,"<$file");
	open(OUT,">$outfile");
	my $line=0;
	while(<IN>){
		chomp;
		my $h1=substr($_,0,1);
		my $h4=substr($_,0,4);	
		if($h1=~/\d/){
				$line++;
		my $out=$_;
		$out=~s/\s+/\t/;
		$out=~ tr/[A-Z]/[a-z]/;
			if($line%2==1){
					print OUT "A\t$out\n";}
			else{
					print OUT "B\t$out\n";
			}
		}elsif($h4=~"\-\- B"){
				print OUT ">\n";
				$line=0;		
		}
	}
	close(IN);
	close(OUT);
}

####2, find indel
#1,indel_ID(chrXX_num); 2,indel_start; 3,indel_end;4,indel_length; 
#5, which_seq_deletion; 6,flanking_identity; 7, flanking_length; 
#8, up_flanking_sequence; 9, indel_seq; 10, down_flanking_seq 

sub find_indel(){
	my $seqRef=$_[0];
	my $seqStart=$_[1];
	my $seqQuery=$_[2];
	my $which=$_[3];
	my $seqStartB=$_[4];
	
	#### min<=indel length<=max
	while($seqRef=~/\.{$dmin,$dmax}/g){
			### ID			
			$indel_id++;
			
			###	Length	
			$indel_length=length($&);

			###position
			my $indel_end_rel=pos($seqRef);#start with 1
			my $indel_start_rel=$indel_end_rel-$indel_length+1;
			my $pre_gap=&pre_gap($indel_start_rel,$seqRef);
			my $pre_gapB=&pre_gap($indel_start_rel,$seqQuery);

			if($which eq "A"){ #ref deletion
				$indel_start=$indel_start_rel+$seqStart-1-$pre_gap-1;
				$indel_end=$indel_start+1;

				$indel_start_q=$indel_start_rel+$seqStartB-1-$pre_gapB;
				$indel_end_q=$indel_end_rel+$seqStartB-1-$pre_gapB;	
		
			}else{	#query deletion
				$indel_start_q=$indel_start_rel+$seqStart-1-$pre_gap-1;
				$indel_end_q=$indel_start_q+1;

				$indel_start=$indel_start_rel+$seqStartB-1-$pre_gapB;
				$indel_end=$indel_end_rel+$seqStartB-1-$pre_gapB;
			}

			####indel seq
			$indel_seq=substr($seqQuery,($indel_start_rel-1),$indel_length);
			$indel_seq=~ tr/[a-z]/[A-Z]/;
	
			if($indel_seq=~ /N+/){
				next;
			}

			###type
			if($which eq "A"){
				$which_seq="Ref";
			}else{
				$which_seq="Query";			
			}
			### identity
				my $up_ref;
				my $down_ref;
				my $up_query;
				my $down_query;

				### up
				my $tmpstart;
				my $tmplength;
				if(($indel_start_rel-1-$flanking)<0){
						$tmpstart=0;
						$tmplength=$indel_start_rel;
				}else{
						$tmpstart=$indel_start_rel-1-$flanking;
						$tmplength=$flanking;
				}

					$up_ref=substr($seqRef,$tmpstart,$tmplength);
					$up_query=substr($seqQuery,$tmpstart,$tmplength);
			
					$down_ref=substr($seqRef,$indel_start_rel+$indel_length-1,$flanking);
					$down_query=substr($seqQuery,$indel_start_rel+$indel_length-1,$flanking);

				$up_seq=$up_ref;
				$down_seq=$down_ref;
			
			my $tmpgap="";
			if($which eq "A"){
				$tmpgap="-"x $indel_length;
				$alignA=$up_ref.$tmpgap.$down_ref;
				$alignB=$up_query.$indel_seq.$down_query;
			}else{
				$tmpgap="-" x $indel_length;
				$alignA=$up_ref.$indel_seq.$down_ref;
				$alignB=$up_query.$tmpgap.$down_query;
			}
	
				$up_seq=~s/\.//g;
				$down_seq=~s/\.//g;
					
				###calculate
					my $ref_flank=$up_ref.$down_ref;
					my $query_flank=$up_query.$down_query;
					my $mismatches=0;
						for(my $i=0;$i<length($ref_flank);$i++){
							unless(substr($ref_flank,$i,1) eq substr($query_flank,$i,1)){
									$mismatches++;							
							}
					}
				$identity=1-$mismatches/(length($ref_flank));
			
				$identity=sprintf "%0.4f",$identity;

				#flank_length
					my $real_ref_flank=$ref_flank;
							$real_ref_flank=~s/\.//g;
					$flanking_length=length($real_ref_flank);
	
	my $prefix=$seqfile;
	if($prefix=~/.+\/([^\/]+\.align)/){
		$prefix=$1;
	}
	$prefix=~s/\.align//;

	my $insertion_align;
	my $deletion_align;
	
	if($which eq "A"){ #Reference deletion
			$insertion_align=$alignB;
			$deletion_align=$alignA;
	}else{
			$insertion_align=$alignA;
			$deletion_align=$alignB;
	}
				
my $ins_region=$insertion_align;
my $del_region=$deletion_align;
	$ins_region=~s/\.//g;
	$del_region=~s/\.//g;
if($identity>=$iden){
	print OUT $prefix."_".$indel_id."\t".$indel_start."\t".$indel_end."\t".$indel_start_q."\t".$indel_end_q."\t".$indel_length."\t".$which_seq."\t".$identity."\t".$flanking_length."\t".$indel_seq."\t".$alignA."\t".$alignB."\t".$insertion_align."\t".$deletion_align."\t".$ins_region."\t".$del_region."\n"; 
}

	}#end while matc
}#end sub

###3, sum of gap position in the upstream region
sub pre_gap{
		my $pos=$_[0];
		my $seq=$_[1];
		my $total=0;
		$seq=substr($seq,0,$pos-1);
		while($seq=~/\.+/g){
			$total=$total+length($&);
		}
		return $total;
}
