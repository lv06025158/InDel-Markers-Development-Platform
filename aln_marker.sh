#!/bin/bash

ProjectOutputLocation=$1
out_dir_marker=$ProjectOutputLocation/MARKER
diff_seq=$out_dir_marker/diff_seq

sed 's/-R//g' $diff_seq | awk 'BEGIN {FS="\t"} $2 == 0 {print $1 "\t" $5 "\t" $4 "\t" $6 "\t" $7 "\t" $8 "\t" $9 "\t" $10 "\t" $11 "\t" $12 "\t" $13 "\t" $14 "\t" $15 "\t" $16 "\t" $17 "\t" $18 "\t" $19}' | sed '1i #InDel_ID	primer_ID	FpSeq	RpSeq	HitID	PPC	Size	BindingStart	BindingStop	AmpSeq	|	HitID	PPC	Size	BindingStart	BindingStop	AmpSeq' > $out_dir_marker/marker.txt

