#!/bin/bash
# fastqc after trimming

out_dir=$1
tag1=$2
reads_type_tag1=$3
threads_no=$4
tag2=$5
reads_type_tag2=$6

function fastqc_2()
{
    tag=${1}
    out_dir_trim=${2}/TRIM_$tag
    out_dir_fastqc=${2}/FASTQC
    threads_no=${3}
    ngs_reads_list=`ls $out_dir_trim`
    mkdir -p $out_dir_fastqc $out_dir_trim
    for reads in $ngs_reads_list
        do
            if [ ${reads##*.} == "gz" ]; then
                fastqc --outdir $out_dir_fastqc --noextract --threads $threads_no --quiet $out_dir_trim/$reads
            else
                continue
            fi
        done
}


if [ $reads_type_tag1 == "1" ]; then
    fastqc_2 $tag1 $out_dir $threads_on
elif [ $reads_type_tag2 == "1" ];then
    fastqc_2 $tag2 $out_dir $threads_on
else
    echo "The input NGS data are clean reads! This step will be ignored!"
fi



