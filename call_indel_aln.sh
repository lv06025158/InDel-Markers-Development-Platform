#!/bin/bash

DIRNAME=$0
if [ "${DIRNAME:0:1}" = "/" ]; then
    get_indels=`dirname $DIRNAME`"/get_indels.pl"
else
    get_indels="`pwd`""/$DIRNAME""/get_indels.pl"
fi


switch=$1
ProjectOutputLocation=$2
Tag1=$3
Tag2=$4
min_len=6
max_len=100
flanking_length=150
flanking_identity=0.98
min_indel_len=${5:-$min_len}
max_indel_len=${6:-$max_len}
Flanking_len=${7:-$flanking_length}
Flanking_iden=${8:-$flanking_identity}


alignOutput=$ProjectOutputLocation/ALIGN
IndelOutput=$ProjectOutputLocation/INDEL

if [ $switch == "1" ]; then
    align_list=`ls $alignOutput`
        for each_align in $align_list
            do
                prefix=${each_align%.aligns}
                $get_indels -min=$min_indel_len -max=$max_indel_len -flanking=$Flanking_len -iden=$Flanking_iden -file=$alignOutput/$each_align -out=$IndelOutput/$prefix.INDELS
            done
        rm $IndelOutput/ALL_INDELS.indels
        find  $IndelOutput -name *.INDELS | xargs cat > $IndelOutput/ALL_INDELS.indels
else
    echo "This step will be skipped!"
fi

