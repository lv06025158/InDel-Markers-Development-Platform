#!/bin/bash

DIRNAME=$0
if [ "${DIRNAME:0:1}" = "/" ]; then
    primerdesigner=`dirname $DIRNAME`"/primer4indel.pl"
    callMFE=`dirname $DIRNAME`"/callMFE.pl"
    ckpcr=`dirname $DIRNAME`"/ckPCR.pl"
else
    primerdesigner="`pwd`""/$DIRNAME""/primer4indel.pl"
    callMFE="`pwd`""/$DIRNAME""/callMFE.pl"
    ckpcr="`pwd`""/$DIRNAME""/ckPCR.pl"
fi

switch=$1
deletion_dir=$2/PINDEL2VCF
out_dir_primer=$2/PRIMER
out_dir_epcr=$2/EPCR
chromosome=$3
product_size=$4
ref_dir=$5
primer_size=${6:-25}
primer_gc_content=${7:-50}
primer_tm=${8:-58}
primer_pair=${9:-3}

ref_genome_name="`ls $ref_dir/REFERENCE_GENOME`"
genome_for_MFE=$ref_dir/REFERENCE_DB/$ref_genome_name

# usage perl primer4indel.pl -in=*.indels -which=Query -prefix=/home/sample_dir/xx -range="100-150 80-200" -size=25 -gc=50 -tm=58 -num=3

if [ $switch == "1" ]; then
    mkdir -p $out_dir_primer/$chromosome $out_dir_epcr/$chromosome/DEL
    $primerdesigner -in=$deletion_dir/$chromosome/$chromosome'_D_filter.indels' -which=Query -prefix=$out_dir_primer/$chromosome/$chromosome'_D' -range="$product_size" -size=$primer_size -gc=$primer_gc_content -tm=$primer_tm -num=$primer_pair
    $callMFE $out_dir_primer/$chromosome/$chromosome'_D.pfasta' $genome_for_MFE deletion $out_dir_epcr/$chromosome/DEL
    $ckpcr $out_dir_epcr/$chromosome/DEL/all_deletion.EPCR $deletion_dir/$chromosome/$chromosome'_D_filter.indels' Ref $out_dir_epcr/$chromosome/DEL
else
    echo "This step will be skipped!"
fi


