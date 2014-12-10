#!/bin/bash

DIRNAME=$0
if [ "${DIRNAME:0:1}" = "/" ]; then
    getseq_from_multifasta=`dirname $DIRNAME`"/getseq_from_multifasta.pl"
else
    getseq_from_multifasta="`pwd`""/$DIRNAME""/getseq_from_multifasta.pl"
fi

switch=$1
chr=$2
out_dir=$3
ref_dir=$4
name_and_version_of_reference_genome=$5
date_of_reference_genome_version=$6
min_len_indel=$7
max_len_indel=$8

prefix=$out_dir/PINDEL/$chr/$chr
vcf_output=$out_dir/PINDEL2VCF/$chr/$chr

genome_for_get_indels_dir=$ref_dir/REFERENCE_FLANK_DB
ref_genome_name="`ls $ref_dir/REFERENCE_GENOME`"
ref_genome_for_pindel=$ref_dir/REFERENCE_INDEX/$ref_genome_name
ref_genome_fai=$ref_dir/REFERENCE_INDEX/$ref_genome_name.fai
list=`cat $ref_genome_fai | awk '{print $1}'`


function indel_filter()
{
    pindel2vcf -p $prefix"_D" -r $ref_genome_for_pindel --reference_name $name_and_version_of_reference_genome --reference_date $date_of_reference_genome_version -v $vcf_output"_D.vcf" -m 1 -e 2

    pindel2vcf -p $prefix"_SI" -r $ref_genome_for_pindel --reference_name $name_and_version_of_reference_genome --reference_date $date_of_reference_genome_version -v $vcf_output"_SI.vcf" -m 1 -e 2
    egrep 'SVTYPE=DEL' $vcf_output"_D.vcf" | sed 's/;HOMSEQ/_HOMSEQ/g' | sed 's/SVLEN=//g' | awk -v min_len=$min_len_indel -v max_len=$max_len_indel 'BEGIN {FS=";"} $3 <= -min_len && $3 >= -max_len {print $1 ";" $2 ";" "SVLEN="$3 ";" $4}' > $vcf_output"_D_filter.vcf"
    $getseq_from_multifasta $vcf_output"_D_filter.vcf" DEL $vcf_output"_D_filter.indels" $genome_for_get_indels_dir

    egrep 'SVTYPE=INS' $vcf_output"_SI.vcf" | sed 's/;HOMSEQ/_HOMSEQ/g' | sed 's/SVLEN=//g' | awk -v min_len=$min_len_indel -v max_len=$max_len_indel 'BEGIN {FS=";"} $3 >= min_len && $3 <= max_len {print $1 ";" $2 ";" "SVLEN="$3 ";" $4}' > $vcf_output"_SI_filter.vcf"
    $getseq_from_multifasta $vcf_output"_SI_filter.vcf" INS $vcf_output"_SI_filter.indels" $genome_for_get_indels_dir
    cat $vcf_output"_D_filter.indels" $vcf_output"_SI_filter.indels" > $vcf_output"_filter.indels"
}




if [ $switch == "1" ]; then
    if [ $chr == "ALL" ]; then
        mkdir -p $out_dir/PINDEL2VCF/$chr
        indel_filter
    else
        for chr in $list
            do
                if [ $chr == $chromosome ]; then
                    mkdir -p $out_dir/PINDEL2VCF/$chr
                    indel_filter
                    exit 0
                else
                    echo "The input is not an valid chromosome id of the reference genome! Maybe you can choose the chromosome id from the following:" 
                    echo "$list"
                    exit 1
                fi
            done
    fi
else 
    echo "This step will be skipped!"
fi

