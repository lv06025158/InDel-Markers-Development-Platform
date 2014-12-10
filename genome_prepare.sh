#!/bin/bash


DIRNAME=$0
if [ "${DIRNAME:0:1}" = "/" ]; then
    process_multi_fasta=`dirname $DIRNAME`"/process_multi_fasta.pl"
else
    process_multi_fasta="`pwd`""/$DIRNAME""/process_multi_fasta.pl"
fi

ref_genome_ori=$1 #/home/yang/Desktop/Nip_vs_9311/genome/Nipponbare/chr01_Nip.fa
ref_genome_out_dir=$2 #/home/yang/Desktop/LONI_NGS/test_1/Ref

ref_genome_dir=$ref_genome_out_dir/REFERENCE_GENOME
ref_genome_for_mapping=$ref_genome_out_dir/REFERENCE_INDEX
ref_genome_for_indels_flank=$ref_genome_out_dir/REFERENCE_FLANK_DB
ref_genome_for_epcr=$ref_genome_out_dir/REFERENCE_DB


mkdir -p $ref_genome_out_dir $ref_genome_dir $ref_genome_for_mapping $ref_genome_for_indels_flank $ref_genome_for_epcr

ref_genome_name=`ls $ref_genome_dir`

#
if [ -z "$ref_genome_name" ]; then
	cp $ref_genome_ori $ref_genome_dir
	ref_genome_name=`ls $ref_genome_dir`
	echo '=='$ref_genome_name'**'
fi

if [ ! -f $ref_genome_for_mapping/$ref_genome_name ]; then
	cp $ref_genome_ori $ref_genome_for_mapping
	echo $ref_genome_for_mapping/$ref_genome_name 'copied'
fi

if [ ! -f $ref_genome_for_epcr/$ref_genome_name ]; then
	cp $ref_genome_ori $ref_genome_for_epcr
	echo $ref_genome_for_epcr/$ref_genome_name 'copied'

fi


# For BWA and Samtools
if [ ! -f $ref_genome_for_mapping/$ref_genome_name.bwt ]; then
	bwa index $ref_genome_for_mapping/$ref_genome_name
fi

if [ ! -f $ref_genome_for_mapping/$ref_genome_name.fai ]; then
	samtools faidx $ref_genome_for_mapping/$ref_genome_name
fi

# For MFEprimer
if [ ! -f $ref_genome_for_epcr/$ref_genome_name.sqlite3.db ]; then
        IndexDb $ref_genome_for_epcr/$ref_genome_name
fi

# For indels
if [ -z "`ls $ref_genome_for_indels_flank`" ]; then
    $process_multi_fasta $ref_genome_ori $ref_genome_for_indels_flank
fi




