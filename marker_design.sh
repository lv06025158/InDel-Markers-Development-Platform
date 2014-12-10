#!/bin/bash

epcr_dir=$1/EPCR
out_dir_marker=$1/MARKER
out_dir_primer=$1/PRIMER
chromosome=$2

cat $epcr_dir/$chromosome/INS/all'_insertion.EPCR' $epcr_dir/$chromosome/DEL/all'_deletion.EPCR' > $out_dir_marker/markers_1.txt
cat $out_dir_primer/$chromosome/$chromosome'_D'.ptab $out_dir_primer/$chromosome/$chromosome'_SI'.ptab > $out_dir_primer/$chromosome/$chromosome.ptab

sort -d -f -i -k 1,2 -o $out_dir_marker/markers_2.txt -s -t "	" -u $out_dir_marker/markers_1.txt
sort -d -f -i -k 1 -o $out_dir_primer/$chromosome/$chromosome"_sorted".ptab -s -t "	" -u $out_dir_primer/$chromosome/$chromosome.ptab
join -t "	" -1 2 -2 1 $out_dir_marker/markers_2.txt $out_dir_primer/$chromosome/$chromosome"_sorted".ptab > $out_dir_marker/markers_3.txt
join -t "	" -1 3 -2 1 $out_dir_marker/markers_3.txt $out_dir_primer/$chromosome/$chromosome"_sorted".ptab | sed 's/-R//g' | cut -f '1,3-16' \
| awk '{print $2 "\t" $1 "\t" $14 "\t" $15 "\t" $3 "\t" $4 "\t" $5 "\t" $6 "\t" $7 "\t" $8 "\t" $9 "\t" $10 "\t" $11 "\t" $12 "\t" $13}' \
| sed '1i #InDel_ID	Primer_ID	FpID	RpID	HitID	PPC	Size	AmpGC	FpTm	RpTm	FpDg	RpDg	BindingStart	BindingStop	AmpSeq' > $out_dir_marker/marker.txt

rm -rf $out_dir_marker/markers_1.txt $out_dir_marker/markers_2.txt $out_dir_marker/markers_3.txt

