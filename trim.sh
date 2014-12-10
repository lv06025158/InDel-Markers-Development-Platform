#!/bin/bash
# trimming by trimmomatic

trimmomatic=/usr/local/program/Trimmomatic-0.32/trimmomatic-0.32.jar
switch=$1
tag1=$2
reads_type_1=$3 #1 for 'Ori' or 0 for 'Clean'
threads_no=$4
out_dir=$5
tag2=$6
reads_type_2=$7

config_tag1=$5/TRIM_$tag1/$tag1'_config'
config_tag2=$5/TRIM_$tag2/$tag2'_config'



function trim()             #trim ABCV /home/yang/Desktop/LONI_NGS/test_2 /home/yang/Desktop/LONI_NGS/config_2
{
    tag=${1}
    out_dir_trim=${2}/TRIM_$tag
    config_tag=${3}
    i=0
    cat $config_tag | while read line
        do
        let i+=1
        list=(${line//,/})         #/home/yang/Desktop/Nip_vs_9311/genome/nip/chr10_Nip.fa chr10 Nip. ##### split by ' ', '\t' or ','
        ngs_reads_1=${list[0]}
        ngs_reads_2=${list[1]}
        adapter_type=${list[2]}    # 'TruSeq 2 --> GA II, TruSeq 3 for HiSeq or MiSeq'
        #adapter_type=`echo $adapter_type | tr 'A-Z' 'a-z'`
        if [ $adapter_type == "3" ]; then
            adapters_hiseq='/usr/local/program/Trimmomatic-0.32/adapters/TruSeq3-PE-2.fa'
        elif [ $adapter_type == "2" ]; then
            adapters_hiseq='/usr/local/program/Trimmomatic-0.32/adapters/TruSeq2-PE.fa'
        else
            echo "Please input the adapter type of the NGS data!"
            exit 1
        fi
        trimlogFile=$out_dir_trim/trimlogFile
        java -jar $trimmomatic PE -threads $threads_no -trimlog $trimlogFile $ngs_reads_1 $ngs_reads_2 $out_dir_trim/$tag"_$i""_L.fq.gz" $out_dir_trim/$tag"_$i""_L_unpaired.fq.gz" $out_dir_trim/$tag"_$i""_R_fq.gz" $out_dir_trim/$tag"_$i""_R_unpaired.fq.gz" ILLUMINACLIP:$adapters_hiseq:2:30:10 LEADING:20 TRAILING:20 SLIDINGWINDOW:4:25 MINLEN:36
        rm $trimlogFile
        done
    return 0

}
#--------------------------------------------------------------------------------------------------------#
if [ $switch == "1" ]; then
    if [ -z "$tag2" ]; then
        if [ $reads_type_1 == "0" ]; then
            echo "The ngs data of $tag1 are original reads. This step will trim the adapters and low quality fragments!"
            trim $tag1 $out_dir $config_tag1
        else
            echo "Given the input data of $tag1 are clean reads, this step will be skipped!"
        fi
    else
        if [ $reads_type_1 == "0" ] && [ $reads_type_2 == "0" ]; then
            echo "The ngs data of $tag1 are original reads. This step will trim the adapters and low quality fragments!"
            trim $tag1 $out_dir $config_tag1
            echo "The ngs data of $tag2 are original reads. This step will trim the adapters and low quality fragments!"
            trim $tag2 $out_dir $config_tag2
        elif [ $reads_type_1 == "0" ] && [ $reads_type_2 != "0" ]; then
            echo "The ngs data of $tag1 are original reads. This step will trim the adapters and low quality fragments!"
            trim $tag1 $out_dir $config_tag1
        elif [ $reads_type_1 != "0" ] && [ $reads_type_2 == "0" ]; then
            echo "The ngs data of $tag2 are original reads. This step will trim the adapters and low quality fragments!"
            trim $tag2 $out_dir $config_tag2
        else
            echo "Given the input data of $tag1 and $tag2 are clean reads, this step will be skipped!"
        fi
    fi
else
    echo "This step will be skipped!"
fi

