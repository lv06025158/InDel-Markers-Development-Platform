#!/bin/bash

switch=$1
ProjectOutputLocation=$2
Tag1=$3
Tag2=$4
minmatch_len=20
minmatch_nucmer_len=${5:-$minmatch_len}

nucmerOutput=$ProjectOutputLocation/NUCMER
alignOutput=$ProjectOutputLocation/ALIGN
mummerplotOutput=$ProjectOutputLocation/PLOT
input_dir_1=$ProjectOutputLocation/$Tag1'_genome'
input_dir_2=$ProjectOutputLocation/$Tag2'_genome'

if [ $switch == "1" ]; then

    file_list_1=`ls $input_dir_1`
    file_list_2=`ls $input_dir_2`

    for file_1 in $file_list_1
        do
            for file_2 in $file_list_2
                do
                    chr_1=${file_1%_*}
                    chr_2=${file_2%_*}
                    if [ "$chr_1" == "$chr_2" ]; then
                        prefix_nucmer=$nucmerOutput/"$chr_1"_"$Tag1"_"$Tag2"
                        nucmer --mum --forward --maxgap=1000 --minmatch=$minmatch_nucmer_len --prefix=$prefix_nucmer $input_dir_1/$file_1 $input_dir_2/$file_2
                        delta-filter -g -q $prefix_nucmer.delta > $prefix_nucmer.filter
                        show-aligns -r $prefix_nucmer.filter -w 200 $chr_1"_"$Tag1 $chr_2"_"$Tag2 > $alignOutput/"$chr_1"_"$Tag1"_"$Tag2".aligns
                        mummerplot --prefix=$mummerplotOutput/"$chr_1"_"$Tag1"_"$Tag2" --small --postscript --title="Alignment of $chr_1 between $Tag1 and $Tag2" $prefix_nucmer.delta
                        mummerplot --prefix=$mummerplotOutput/"$chr_1"_"$Tag1"_"$Tag2""_filter" --small --postscript --title="Alignment of $chr_1 between $Tag1 and $Tag2" $prefix_nucmer.filter

                    else
                        continue
                    fi
                done
        done
else
    echo "This step will be skipped!"
fi




