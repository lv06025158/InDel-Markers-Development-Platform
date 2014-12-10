#!/bin/bash

switch=$1
ProjectOutputLocation=$2
Tag1=$3
Tag2=$4
genome1_config=$5
genome2_config=$6

genomeTag1=$ProjectOutputLocation/$Tag1'_genome'
Index_genomeTag1=$ProjectOutputLocation/$Tag1'_genome_index'
genomeTag2=$ProjectOutputLocation/$Tag2'_genome'
Index_genomeTag2=$ProjectOutputLocation/$Tag2'_genome_index'
nucmerOutput=$ProjectOutputLocation/NUCMER
AlignOutput=$ProjectOutputLocation/ALIGN
MummerplotOutput=$ProjectOutputLocation/PLOT
IndelOutput=$ProjectOutputLocation/INDEL
Pirmer3Output=$ProjectOutputLocation/PRIMER
epcr_tag1=$ProjectOutputLocation/EPCR/$Tag1
epcr_tag2=$ProjectOutputLocation/EPCR/$Tag2
markers=$ProjectOutputLocation/MARKER

function genome_pre()
{
    genome_config=${1}
    out_dir=${2}
    cat $genome_config | while read line
        do
            list=(${line//,/})         #/home/yang/Desktop/Nip_vs_9311/genome/nip/chr10_Nip.fa chr10 Nip. ##### split by ' ', '\t' or ','
            chr_ori_1=${list[0]}
            chr=${list[1]}
            tag=${list[2]}
            cp $chr_ori_1 $genomeTag1/tmp.fa
            sed '1d' $genomeTag1/tmp.fa | sed "1i >$chr"_"$tag" > $genomeTag1/$chr'_'$tag.fa
            cp $genomeTag1/$chr'_'$tag.fa $Index_genomeTag1/
            rm $genomeTag1/tmp.fa
            echo '------'
        done
    find  $genomeTag1 -name *.fa | xargs cat > $Index_genomeTag1/ALL_$Tag1.fa

}

if [ $switch == "1" ]; then
    rm -rf $ProjectOutputLocation
    mkdir -p $ProjectOutputLocation $genomeTag1 $genomeTag2 $nucmerOutput $AlignOutput $MummerplotOutput $IndelOutput $Pirmer3Output $epcr_tag1 $epcr_tag2 $markers $Index_genomeTag1 $Index_genomeTag2
# Preprocess the genome for genome 1
    cat $genome1_config | while read line
        do
            list=(${line//,/})         #/home/yang/Desktop/Nip_vs_9311/genome/nip/chr10_Nip.fa chr10 Nip. ##### split by ' ', '\t' or ','
            chr_ori_1=${list[0]}
            chr=${list[1]}
            tag=${list[2]}
            cp $chr_ori_1 $genomeTag1/tmp.fa
            sed '1d' $genomeTag1/tmp.fa | sed "1i >$chr"_"$tag" > $genomeTag1/$chr'_'$tag.fa
            cp $genomeTag1/$chr'_'$tag.fa $Index_genomeTag1/
            rm $genomeTag1/tmp.fa
            echo '------'
        done
    find  $genomeTag1 -name *.fa | xargs cat > $Index_genomeTag1/ALL_$Tag1.fa

# Preprocess the genome for genome 2
    cat $genome2_config | while read lines
        do
            list=(${lines//,/})
            chr_ori_2=${list[0]}
            chr=${list[1]}
            tag=${list[2]}
            cp $chr_ori_2 $genomeTag2/tmp.fa
            sed '1d' $genomeTag2/tmp.fa | sed "1i >$chr"_"$tag" > $genomeTag2/$chr'_'$tag.fa
            cp $genomeTag2/$chr'_'$tag.fa $Index_genomeTag2/
            rm $genomeTag2/tmp.fa
            echo '***'
        done
    find  $genomeTag2 -name *.fa | xargs cat > $Index_genomeTag2/ALL_$Tag2.fa
else
    echo "Skip to the next step!"
fi

