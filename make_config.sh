#!/bin/bash

switch=$1
pindel_dir=$2/PINDEL
mapping_dir=$2/MAPPING2ALN
tag1=$3
tag2=$4


if [ $switch == "1" ]; then

    if [ -z $tag2 ]; then
        cat $mapping_dir/$tag1'.config' > $pindel_dir/'PINDEL.config'
    else
        cat $mapping_dir/$tag1'.config' $mapping_dir/$tag2'.config' > $pindel_dir/'PINDEL.config'
    fi
else
    echo "This step will be skipped!"
fi
