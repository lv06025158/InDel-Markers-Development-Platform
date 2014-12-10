#!/bin/bash

DIRNAME=$0
if [ "${DIRNAME:0:1}" = "/" ]; then
    primerdesigner=`dirname $DIRNAME`"/primer4indel.pl"
    callMFE=`dirname $DIRNAME`"/callMFE.pl"
    ckpcr=`dirname $DIRNAME`"/ckPCR.pl"
    ckindel=`dirname $DIRNAME`"/ckIndel.pl"
else
    primerdesigner="`pwd`""/$DIRNAME""/primer4indel.pl"
    callMFE="`pwd`""/$DIRNAME""/callMFE.pl"
    ckpcr="`pwd`""/$DIRNAME""/ckPCR.pl"
    ckindel="`pwd`""/$DIRNAME""/ckIndel.pl"
fi

switch=$1
ProjectOutputLocation=$2
Tag1=$3
Tag2=$4
product_size=$5
primer_size=${6:-25}
primer_gc_content=${7:-50}
primer_tm=${8:-58}
primer_pair=${9:-3}


indels=$ProjectOutputLocation/INDEL/ALL_INDELS.indels
out_dir_primer=$ProjectOutputLocation/PRIMER
out_dir_marker=$ProjectOutputLocation/MARKER
epcr_tag1=$ProjectOutputLocation/EPCR/$Tag1
epcr_tag2=$ProjectOutputLocation/EPCR/$Tag2
Index_genomeTag1=$ProjectOutputLocation/$Tag1'_genome_index'
Index_genomeTag2=$ProjectOutputLocation/$Tag2'_genome_index'

if [ $switch == "1" ]; then
    $primerdesigner -in=$indels -which=Ref -prefix=$out_dir_primer/$Tag1"_PRIMER" -range="\"$product_size\"" -size=$primer_size -gc=$primer_gc_content -tm=$primer_tm -num=$primer_pair
    $primerdesigner -in=$indels -which=Query -prefix=$out_dir_primer/$Tag2"_PRIMER" -range="\"$product_size\"" -size=$primer_size -gc=$primer_gc_content -tm=$primer_tm -num=$primer_pair

    if [ ! -f $Index_genomeTag1/ALL_$Tag1.fa.sqlite3.db ]; then
        IndexDb $Index_genomeTag1/ALL_$Tag1.fa
    fi

    if [ ! -f $Index_genomeTag2/ALL_$Tag2.fa.sqlite3.db ]; then
        IndexDb $Index_genomeTag2/ALL_$Tag2.fa
    fi

    $callMFE $out_dir_primer/$Tag1'_PRIMER.pfasta' $Index_genomeTag1/ALL_$Tag1.fa $Tag1 $epcr_tag1
    $callMFE $out_dir_primer/$Tag2'_PRIMER.pfasta' $Index_genomeTag2/ALL_$Tag2.fa $Tag2 $epcr_tag2
    $ckpcr $epcr_tag1/all_$Tag1.EPCR $indels Ref $epcr_tag1
    $ckpcr $epcr_tag2/all_$Tag2.EPCR $indels Query $epcr_tag2
    $ckindel $indels $epcr_tag1/all_$Tag1.EPCR $epcr_tag2/all_$Tag2.EPCR $out_dir_marker/ $out_dir_primer/$Tag1'_PRIMER.ptab'
else
    echo "This step will be skipped!"
fi

