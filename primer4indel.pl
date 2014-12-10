#!/usr/bin/perl
# Design indel primers in batch.
# Input *.indels file;
# Output, *.primers
# version 0.1 noepcr 
# usage perl primer4indel.pl -in=*.indels -which=Query -prefix=/home/sample_dir/xx -range="100-150 80-200" -size=25 -gc=50 -tm=58 -num=3

no warnings 'all';

use Bio::PrimerDesigner;
use Getopt::Long;

my $par_indel="";
my $par_which="";  # must be "Query" or "Ref"
my $par_outdir=""; # end with "\"

my $par_primer_range; #'100-150 80-200'
my $par_primer_size;
my $par_primer_gc;
my $par_primer_tm;
my $par_primer_num;
my $par_name;

if(GetOptions(
	'in=s' =>\$par_indel,
	'which=s'=>\$par_which,
	'prefix=s'=>\$par_outdir,
	'range=s'=>\$par_primer_range,
	'size=i'=>\$par_primer_size,
	'gc=i'=>\$par_primer_gc,
	'tm=f'=>\$par_primer_tm,
	'num=i'=>\$par_primer_num
)){
}else{
	exit;
}


### Settings
	# indel excluded distance
	my $dis_indel=10;
	my $use_which=$par_which;
	my $count=$par_primer_num;


#input files

my $indel_file=$par_indel;
$indel_file=~s/\.indels//g;
open(IN,"$par_indel");



#output files
open(OUT, ">$par_outdir.primers");
open(NO,">$par_outdir.noprimer");
open(FAS,">$par_outdir.pfasta");
open(TAB,">$par_outdir.ptab");

# settings

my @out;
my @out_head;  ### setting which will appear in output
			$out[0]=1;		$out_head[0]="PrimerL";				#1,	 left -- left primer sequence
			$out[1]=1;		$out_head[1]="PrimerR";				#2,	 right -- right primer sequence
			$out[2]=0;		$out_head[2]="InternalOligo";	#3,  hyb_oligo -- internal oligo sequence
			$out[3]=1;		$out_head[3]="PL_Start";			#4,	 startleft -- left primer 5' sequence coordinate
			$out[4]=1;		$out_head[4]="PR_Start";			#5,	 startright -- right primer 5' sequence coordinate
			$out[5]=1;		$out_head[5]="PL_TM";					#6,	 tmleft -- left primer tm
			$out[6]=1;		$out_head[6]="PR_TM";					#7,	 tmright -- right primer tm
			$out[7]=0;		$out_head[7]="PairPenalty";		#8,	 qual -- primer pair penalty (Q value)
			$out[8]=0;		$out_head[8]="PLPenalty";			#9,	 lqual -- left primer penalty
			$out[9]=0;		$out_head[9]="PRPenalty";			#10, rqual -- right primer penalty
			$out[10]=1;		$out_head[10]="PL_GC";				#11,	leftgc -- left primer % gc
			$out[11]=1;		$out_head[11]="PR_GC";				#12, rightgc -- right primer % gc
			$out[12]=1;		$out_head[12]="PL_any_comp";	#13, lselfany -- left primer self-complementarity (any)
			$out[13]=1;		$out_head[13]="PL_end_comp";	#14, lselfend -- left primer self-complementarity (end)
			$out[14]=1;		$out_head[14]="PR_any_comp";	#15, rselfany -- right primer self-complementarity (any)
			$out[15]=1;		$out_head[15]="PR_end_comp";	#16, rselfend -- right primer self-complementarity (end)
			$out[16]=1;		$out_head[16]="Pair_any_comp";#17, pairanycomp -- primer pair complementarity (any)
			$out[17]=1;		$out_head[17]="Pair_end_comp";#18, pairendcomp -- primer pair complementarity (end)
			$out[18]=1;		$out_head[18]="PL_Stab";			#19, lendstab -- left primer end stability
			$out[19]=1;		$out_head[19]="PR_Stab";			#20, rendstab -- right primer end stability

			#epcr not implemented
			#$out[20]=0;		$out_head[20]="Prod_Ampl";		#21, amplicon -- amplified PCR product
			#$out[21]=0;		$out_head[21]="Prod_Count";		#22, products -- number of PCR products
			#$out[22]=0;		$out_head[22]="Prod_Size";		#23, size -- product size
			#$out[23]=0;		$out_head[23]="Prod_start";		#24, start -- product start coordinate
			#$out[24]=0;		$out_head[24]="Prod_end";			#25, stop -- product stop coordinate
			#$out[25]=0;		$out_head[25]="syn_stop";			#26, end -- synonymous with stop
			#$out[26]=0;		$out_head[26]="strand";				#27, strand -- strand of product relative to the ref. sequence (isPCR, ipcress)
			#$out[27]=0;		$out_head[27]="PCR_prod";			#28, amplicon -- returns the PCR product (isPCR only)
my $outheader="SEQ_ID";

for(my $i=0;$i<scalar(@out_head);$i++){
	if($out[$i]!=0){
	 $outheader.="\t$out_head[$i]";
	}
}
print OUT $outheader."\n";




#while( my $seq = $seqs->next_seq() ) {
while(<IN>) {
	my $pd = Bio::PrimerDesigner->new;
	chomp;
	s/\r//g;
  s/\n//g;
	if(substr($_,0,1) eq "#"){
		next;
	}
	 	 my @tmp_array=split("\t",$_);  
		#id
    my $seqid =$tmp_array[0];
		my $dna;
		my $del_which=$tmp_array[6];
		#seq
		if($del_which eq $use_which ){
			$dna=$tmp_array[15]; # deletion
		}else{
			$dna=$tmp_array[14]; #insertion
    }
		my $indel_length=$tmp_array[5];
		my @exclude=&get_exclude($dna,$indel_length,$del_which);	
		$dna=~s/\-//g;
	my %params = ( 
					PRIMER_NUM_RETURN   => $count,
					PRIMER_SEQUENCE_ID  => $seqid,
					SEQUENCE	       => $dna,
					PRIMER_PRODUCT_SIZE_RANGE => $par_primer_range,  #(空格分开 "x-y m-n" 100-150 200-250, later)
					#PRIMER_TASK => 'pick_pcr_primers',
					EXCLUDED_REGION =>"$exclude[0],$exclude[1]", 			#excluded region, set later 		
					PRIMER_PRODUCT_OPT_SIZE =>0, #default
					PRIMER_FIRST_BASE_INDEX => 1, 
					PRIMER_GC_CLAMP => 1,
					PRIMER_MAX_END_STABILITY => 100, #default
					PRIMER_MIN_SIZE => 20,
					PRIMER_OPT_SIZE => $par_primer_size,
					PRIMER_MAX_SIZE => 28,
					PRIMER_MIN_TM => 53,
					PRIMER_OPT_TM => $par_primer_tm,
					PRIMER_MAX_TM => 62,
					PRIMER_MAX_DIFF_TM => 4,
					PRIMER_MIN_GC => 35,
					PRIMER_MAX_GC => 70,
					PRIMER_OPT_GC_PERCENT => $par_primer_gc,
					PRIMER_SELF_ANY => 6,       #default
					PRIMER_SELF_END => 3, 			#default
					PRIMER_NUM_NS_ACCEPTED =>0,    #default
					PRIMER_MAX_POLY_X => 5			 #default	
					#PRIMER_THERMODYNAMIC_PARAMETERS_PATH => '/usr/local/programs/primer3-2.3.5/src/primer3_config/'

				);
					###No setting options in primer3 
					# Cross Dimer Maximum delta G (5.0 -kcal/mol)
					# Cross Dimer Maximum delta G (6.0 -kcal/mol)
					# 3'end Maximum delta G (9.0 -kal/mol)
					# self dimer maximum delta G 3'end  (5.0 -kal/mol)
					# self dimer maximum delta G  internal (6.0 -kal/mol)
					# Run/repeat (dinucleotide) maximum length (3 bp)
					## Annealing Oligo Concentration (50)
					#  Temperature for free energy calcuation 25(oC)


##
		   my $primers = $pd->design( %params ) or die $pd->error;
			 my @tmpresult;
						@{$tmpresult[0]}=$primers->left(1..$count);#1,	 left -- left primer sequence
						@{$tmpresult[1]}=$primers->right(1..$count);				#2,	 right -- right primer sequence
						@{$tmpresult[2]}=$primers->hyb_oligo(1..$count);		#3,  hyb_oligo -- internal oligo sequence
						@{$tmpresult[3]}=$primers->startleft(1..$count);		#4,	 startleft -- left primer 5' sequence coordinate
						@{$tmpresult[4]}=$primers->startright(1..$count);	#5,	 startright -- right primer 5' sequence coordinate
						@{$tmpresult[5]}=$primers->tmleft(1..$count);			#6,	 tmleft -- left primer tm
						@{$tmpresult[6]}=$primers->tmright(1..$count);			#7,	 tmright -- right primer tm
						@{$tmpresult[7]}=$primers->qual(1..$count);				#8,	 qual -- primer pair penalty (Q value)
						@{$tmpresult[8]}=$primers->lqual(1..$count);				#9,	 lqual -- left primer penalty
						@{$tmpresult[9]}=$primers->rqual(1..$count);				#10, rqual -- right primer penalty
						@{$tmpresult[10]}=$primers->leftgc(1..$count);			#11,	leftgc -- left primer % gc
						@{$tmpresult[11]}=$primers->rightgc(1..$count);			#12, rightgc -- right primer % gc
						@{$tmpresult[12]}=$primers->lselfany(1..$count);		#13, lselfany -- left primer self-complementarity (any)
						@{$tmpresult[13]}=$primers->lselfend(1..$count);		#14, lselfend -- left primer self-complementarity (end)
						@{$tmpresult[14]}=$primers->rselfany(1..$count);		#15, rselfany -- right primer self-complementarity (any)
						@{$tmpresult[15]}=$primers->rselfend(1..$count);		#16, rselfend -- right primer self-complementarity (end)
						@{$tmpresult[16]}=$primers->pairanycomp(1..$count);	#17, pairanycomp -- primer pair complementarity (any)
						@{$tmpresult[17]}=$primers->pairendcomp(1..$count);	#18, pairendcomp -- primer pair complementarity (end)
						@{$tmpresult[18]}=$primers->lendstab(1..$count);		#19, lendstab -- left primer end stability
						@{$tmpresult[19]}=$primers->rendstab(1..$count);		#20, rendstab -- right primer end stability

						# epcr, not implemented
						#@{$out_head[20]}=$primers->amplicon(1..$count);		#21, amplicon -- amplified PCR product
						#@{$out_head[21]}=$primers->products(1..$count);		#22, products -- number of PCR products
						#@{$out_head[22]}=$primers->size(1..$count);				#23, size -- product size
						#@{$out_head[23]}=$primers->start(1..$count);				#24, start -- product start coordinate
						#@{$out_head[24]}=$primers->stop(1..$count);				#25, stop -- product stop coordinate
						#@{$out_head[25]}=$primers->end(1..$count);					#26, end -- synonymous with stop
						#@{$out_head[26]}=$primers->strand(1..$count);			#27, strand -- strand of product relative to the ref. sequence (isPCR, ipcress)
						#@{$out_head[27]}=$primers->amplicon(1..$count);		#28, amplicon -- returns the PCR product (isPCR only)

		   if ( !$primers->left ) {
		      		warn "No primers found for $seqid\n";
							print NO "$seqid\n";
		      }
		      else{
							#Output Result
							my $tmpline="";
							#my @oright=$primers->right(1..5);
							my $real_count;
							for(my $i=0;$i<$count;$i++){
									unless(${$tmpresult[1]}[$i] eq ""){
											$real_count++;
									}
							}

							
							for(my $i=0;$i<$real_count;$i++){
									for(my $j=0;$j<scalar(@tmpresult);$j++){
										if($out[$j]==1){     #which to write
												if($j==0){
														$tmpline.="$seqid"."-$i";
												}
										 		$tmpline=$tmpline."\t".${$tmpresult[$j]}[$i];

												if($j==0){
print TAB "$seqid-$i-L\t${$tmpresult[0]}[$i]\n";
														print FAS ">$seqid-$i-L\n${$tmpresult[0]}[$i]\n";
												}
												if($j==1){
print TAB "$seqid-$i-R\t${$tmpresult[1]}[$i]\n";
														print FAS ">$seqid-$i-R\n${$tmpresult[1]}[$i]\n";
												}
										}
									}
										$tmpline=$tmpline."\n";
							}
						print OUT $tmpline;
		      }		
##
}#end of while seq


#####################------------------SUB---------------------##############################3
sub get_exclude{
	my $tmpdna=$_[0];
	my $tmplength=$_[1];
	my $tmpwhich=$_[2];
	my $pos;
	my $length;
	my @result;

	if($tmpwhich eq "Query"){
			$tmpdna=~/\-/g;
			$pos=pos($tmpdna);
			$pos=($pos-1)-$dis_indel+1;
			$length=2*$dis_indel;
			$result[0]=$pos;
			$result[1]=$length;	
			#print "$result[0],$result[1],$tmpwhich\n";
			
	}else{
			$tmpdna=~/[ATCG]/g;
			$pos=pos($tmpdna);
			$pos=$pos-$dis_indel;
			$length=$tmplength+2*$dis_indel;
			$result[0]=$pos;
			$result[1]=$length;	
			#print "$result[0],$result[1],$tmpwhich\n";	
	}

	return @result;
}
