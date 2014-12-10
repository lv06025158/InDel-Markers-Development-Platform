#!/bin/bash

switch=$1
out_dir_pindel=$2/PINDEL
chromosome=$3
ref_dir=$4

ref_genome_name="`ls $ref_dir/REFERENCE_GENOME`"
ref_genome_for_pindel=$ref_dir/REFERENCE_INDEX/$ref_genome_name
ref_genome_fai=$ref_dir/REFERENCE_INDEX/$ref_genome_name.fai
list=`cat $ref_genome_fai | awk '{print $1}'`

if [ $switch == "1" ]; then
    if [ $chromosome == "ALL" ]; then
        mkdir -p $out_dir_pindel/ALL
        prefix=$out_dir_pindel/ALL/ALL
        logfile=$out_dir_pindel/ALL/logfile_PINDEL
        pindel --fasta $ref_genome_for_pindel --config-file $out_dir_pindel/PINDEL.config --output-prefix $prefix --chromosome ALL --name_of_logfile $logfile
    else
        for chr in $list
            do
                if [ $chr == $chromosome ]; then
                    mkdir -p $out_dir_pindel/$chromosome
                    prefix=$out_dir_pindel/$chromosome/$chr
                    logfile=$out_dir_pindel/$chromosome/logfile_$chr
                    pindel --fasta $ref_genome_for_pindel --config-file $out_dir_pindel/PINDEL.config --output-prefix $prefix --chromosome $chr --name_of_logfile $logfile
                    exit 0
                else
                    echo "The input is not an valid chromosome id of the reference genome! Maybe you can choose the chromosome id from the following: $list!"
                    exit 1
                fi
            done
    fi
else
    echo "This step will be skipped!"
fi

