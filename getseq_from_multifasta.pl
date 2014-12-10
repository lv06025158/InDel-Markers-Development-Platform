#!/usr/bin/perl
#get sequence from chr files. (must have single line files in the dir)
#usage getseq_from_multifasta.pl <vcf_file> <Type: DEL or INS> <Outfile> <ref dir>	maybe another parameter length of insertion or deletion need

my $type=$ARGV[1];

#infile format
#chr10_irgsp5	3629026	AAAC	A	3629029	-3	DEL	.:0	1/.:4
open(IN,"<$ARGV[0]");

#out file format
#indel_id	ref_start_abs	ref_end_abs	que_start_abs	que_end_abs	indel_length	which_deletion	identity	flanking_length	indel_seq	ref_align	que_align	ins_align	del_align	ins_region	del_region
open(OUT,">$ARGV[2]");


print OUT "#indel_id	ref_start_abs	ref_end_abs	que_start_abs	que_end_abs	indel_length	which_deletion	identity	flanking_length	indel_seq	ref_align	que_align	ins_align	del_align	ins_region	del_region";
while(<IN>){
	if(substr($_,0,1) eq "#"){
		if($_=~/#CHROM/){
			my @aa=split("\t",$_);
			print OUT "\t$aa[9]\t$aa[10]";
			
		}	
	next;}
	chomp;
	#		CHROM	POS	ID	REF	ALT
	if($type eq "DEL"){
			my $id;
			my $start;
			my $end;
			my $seq;
			my $len;
			my $chr;
			my @tmp=split("\t",$_);
			#D	chr10_9311	346928	.	CGTCTAC	C
	
			$chr=$tmp[0];
			$start=$tmp[1]+1;
			$seq=substr($tmp[3],1,length($tmp[3])-1);
			$len=length($seq);
			$end=$start+$len-1;
			$id=$tmp[0]."_".$start."_".$seq."_DEL";
				$up_seq=&getseq($chr,$start-150,$start-1);
				$down_seq=&getseq($chr,$end+1,$end+150);
				$fl_seq=$up_seq.$seq.$down_seq;
				print OUT "$id\t$start\t$end\t$start\t$end\t$len\tRef\t\.\t".length($fl_seq)."\t$seq\t$fl_seq\t$fl_seq\t$fl_seq\t$fl_seq\t$fl_seq\t$fl_seq\t$tmp[9]\t$tmp[10]\n";
	}else{
			my $id;
			my $start;
			my $end;
			my $seq;
			my $len;
			my $chr;
			my @tmp=split("\t",$_);
			#I	chr10_irgsp5	145513	.	C	CA	
			$chr=$tmp[0];
			$start=$tmp[1]+1;
			$len=length($tmp[4])-1;
			$seq="-"x$len;
			$seq2=substr($tmp[4],1,$len);
			$end=$start+1;
			$id=$tmp[0]."_".$start."_".$seq2."_INS";
				$up_seq=&getseq($chr,$start-149,$start);
				$down_seq=&getseq($chr,$end,$end+149);
				$fl_seq=$up_seq.$seq.$down_seq;
				$fl_len=length($fl_seq)-length($seq);
								print OUT "$id\t$start\t$end\t$start\t$end\t$len\tQuery\t\.\t".$fl_len."\t$seq2\t$fl_seq\t$fl_seq\t$fl_seq\t$fl_seq\t$fl_seq\t$fl_seq\t$tmp[9]\t$tmp[10]\n";
	}

}



#using seek
sub getseq(){
	my $file=$_[0];
	my $start=$_[1];
	my $end=$_[2];
	my $len=$end-$start+1;
	my $subseq="";
	open(SEQ,"<$ARGV[3]\/$file");
	seek(SEQ,$start,0);
	read(SEQ,$subseq,$len);
	return $subseq;
}
