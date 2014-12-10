#!/bin/bash
# bwa & samtools

switch=$1
out_dir=$2
ref_dir=$3
threads_no=$4
tag=$5
insert_size=$6
reads_type=$7

mapping_out_dir=$out_dir/MAPPING2ALN
out_dir_trim=$out_dir/TRIM_$tag
ref_genome_name="`ls $ref_dir/REFERENCE_GENOME`"
ref_genome_for_mapping=$ref_dir/REFERENCE_INDEX/$ref_genome_name

fastq=()

if [ $switch == "1" ]; then
    if [ -z $tag ];then
        echo "No mapping data and this step will be skipped!"
    else
        if [ $reads_type == "0" ]; then
            line_num=`wc -l $out_dir_trim/$tag"_config"`
            list=(${line_num//,/})
            reads_pair_num=${list[0]}
            for ((i=1; i<reads_pair_num+1; ++i))
                do
                fastq+=("$out_dir_trim/$tag"_"$i"_L.fq.gz"" "$out_dir_trim/$tag"_"$i"_R.fq.gz"" "$out_dir_trim/$tag"_"$i"_L_unpaired.fq.gz"" "$out_dir_trim/$tag"_"$i"_R_unpaired.fq.gz"")
                done
            bwa mem -t $threads_no $ref_genome_for_mapping ${fastq[@]} - | samtools view -Su - | samtools sort -@ $threads_no -m 1G - $mapping_out_dir/$tag"_sorted"
            samtools index $mapping_out_dir/$tag"_sorted.bam"
        else
            i=0
            while read line
                do
                    let i=i+1
                    list=(${line//,/})
                    ngs_reads_1=${list[0]}
                    ngs_reads_2=${list[1]}
                    fastq+=("$ngs_reads_1" "$ngs_reads_2")
                done<$out_dir_trim/$tag"_config"
            bwa mem $ref_genome_for_mapping -t $threads_no ${fastq[@]} - | samtools view -Su - | samtools sort -@ $threads_no -m 1G - $mapping_out_dir/$tag"_sorted"
            samtools index $mapping_out_dir/$tag"_sorted.bam"
        fi
    fi

    echo "$mapping_out_dir/$tag"_sorted.bam" $insert_size $tag" > $mapping_out_dir/$tag.config

elif [ $switch == "0" ]; then
    echo "Don't map reads of $tag to the reference genome!"
    echo "Skip to the next step!"
else
    echo "Don't map reads of $tag to the reference genome!"
    echo "Skip to the next step!"
fi


