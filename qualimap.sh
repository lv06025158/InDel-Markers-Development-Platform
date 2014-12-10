#!/bin/bash

switch=$1
out_dir=$2
tag=$3
threads_no=$4
out_format=$5
if [ $switch == "1" ]; then
    qualimap bamqc -bam $out_dir/$tag'_sorted.bam' -nt $threads_no -outdir $out_dir/$tag'_qualimap' -outformat $out_format --java-mem-size=2G
elif [ $switch == "0" ]; then
    echo "Don't qualimap "$out_dir/$tag"_sorted.bam!"
    echo "Skip to the next step!"
fi


