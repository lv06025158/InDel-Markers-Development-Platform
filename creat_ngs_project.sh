#!/bin/bash
# create folder for InDel markers development

ProjectOutputLocation=$1
tag1=$2
config_tag1=$3
tag2=$4
config_tag2=$5



TrimTag1Output=$ProjectOutputLocation/"TRIM_$tag1"
TrimTag2Output=$ProjectOutputLocation/"TRIM_$tag2"
Mapping2Align=$ProjectOutputLocation/MAPPING2ALN
PindelOutput=$ProjectOutputLocation/PINDEL
Pindel2VcfOutput=$ProjectOutputLocation/PINDEL2VCF

Pirmer3Output=$ProjectOutputLocation/PRIMER
epcr=$ProjectOutputLocation/EPCR
markers=$ProjectOutputLocation/MARKER


if [ -z $tag2 ]; then
    mkdir -p $ProjectOutputLocation $TrimTag1Output $Mapping2Align $PindelOutput $Pindel2VcfOutput $Pirmer3Output $epcr $markers $Mapping2Align/"$tag1"_qualimap""
    sed '/^$/d' $config_tag1 | sed '/^\s*$/d' > $TrimTag1Output/"$tag1"_config""     #delete blank line
else
    mkdir -p $ProjectOutputLocation $TrimTag1Output $TrimTag2Output $Mapping2Align $PindelOutput $Pindel2VcfOutput $Pirmer3Output $epcr $markers $Mapping2Align/"$tag1"_qualimap"" $Mapping2Align/"$tag2"_qualimap""
    sed '/^$/d' $config_tag1 | sed '/^\s*$/d' > $TrimTag1Output/"$tag1"_config""     #delete blank line
    sed '/^$/d' $config_tag2 | sed '/^\s*$/d' > $TrimTag2Output/"$tag2"_config""     #delete blank line
fi

