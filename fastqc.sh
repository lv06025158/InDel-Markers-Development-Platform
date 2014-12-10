#!/bin/bash
# fastqc before trimming

switch=$1
out_dir=$2
threads_no=$3
tag1=$4
tag2=$5


function trim_fastqc()
{
    tag=${1}
    out_dir_fastqc=${2}/FASTQC
    threads_no=${3}
    trim_config=$out_dir/TRIM_$tag/$tag'_config'
    mkdir -p $out_dir_fastqc $out_dir/TRIM_$tag
    cat $trim_config | while read line
        do
            list=(${line//,/})
            ngs_reads_1=${list[0]}
            ngs_reads_2=${list[1]}
            fastqc --outdir $out_dir_fastqc --noextract --threads $threads_no --quiet $ngs_reads_1
            fastqc --outdir $out_dir_fastqc --noextract --threads $threads_no --quiet $ngs_reads_2
            done
}

if [ $switch == "1" ]; then
    if [ -z $tag2 ]; then
        trim_fastqc $tag1 $out_dir $threads_no
    else
        trim_fastqc $tag1 $out_dir $threads_no
        trim_fastqc $tag2 $out_dir $threads_no
    fi
fi



