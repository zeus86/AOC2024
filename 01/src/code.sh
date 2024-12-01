#!/bin/bash

INPUTDIR="input"
INPUTFILE="input"
#INPUTFILE="input_dummy"
INPUT="$INPUTDIR/$INPUTFILE"



stage1 () {
echo -e "stage 1.1: split input into seperate files, sorted and unsorted."
cat $INPUT | tr -s " " | cut -f 1 -d " " > $INPUTDIR/$INPUTFILE.split_left_01
cat $INPUTDIR/$INPUTFILE.split_left_01 | sort > $INPUTDIR/$INPUTFILE.split_left_sorted_01
cat $INPUT | tr -s " " | cut -f 2 -d " " > $INPUTDIR/$INPUTFILE.split_right_01
cat $INPUTDIR/$INPUTFILE.split_right_01 | sort > $INPUTDIR/$INPUTFILE.split_right_sorted_01
echo "done."

echo -e "stage 1.2: merge again into a sorted list."
paste -d " " $INPUTDIR/$INPUTFILE.split_left_sorted_01 $INPUTDIR/$INPUTFILE.split_right_sorted_01 > $INPUTDIR/$INPUTFILE.joined_sorted_01
echo -e "           also create an inputfile (valueFromFile2-valueFromFile1) to be usable directly with bc."
paste -d "-" $INPUTDIR/$INPUTFILE.split_right_sorted_01 $INPUTDIR/$INPUTFILE.split_left_sorted_01 > $INPUTDIR/$INPUTFILE.joined_sorted_bc_01
echo "done."


echo "stage 1.3: compare fields and write distance-file"
> $INPUTDIR/$INPUTFILE.sorted_distance_01
echo $INPUTDIR/$INPUTFILE.joined_sorted_bc_01 | while read -r line 
do 
	bc "$line" >> $INPUTDIR/$INPUTFILE.sorted_distance_01
done

echo "done."

echo "stage 1.4: invert negative values, then add up distance"
cat $INPUTDIR/$INPUTFILE.sorted_distance_01 | tr -d "-" | paste -sd+ | bc > $INPUTDIR/$INPUTFILE.distance_sum_01
echo "done."

echo "stage one final result is:"
cat $INPUTDIR/$INPUTFILE.distance_sum_01
}

stage2 () {
echo -e "stage 2.1: the first steps are the same: create left and light lists in sorted form"
cat $INPUT | tr -s " " | cut -f 1 -d " " > $INPUTDIR/$INPUTFILE.split_left_02
cat $INPUTDIR/$INPUTFILE.split_left_02 | sort > $INPUTDIR/$INPUTFILE.split_left_sorted_02
cat $INPUT | tr -s " " | cut -f 2 -d " " > $INPUTDIR/$INPUTFILE.split_right_02
cat $INPUTDIR/$INPUTFILE.split_right_02 | sort > $INPUTDIR/$INPUTFILE.split_right_sorted_02
echo "done."

echo -e "stage 2.2: count values in second list, and add them bc-friendly"
> $INPUTDIR/$INPUTFILE.combined_sorted_similarity_02
while read -r line
do
	SIMILARITY=$(grep ^$line$ $INPUTDIR/$INPUTFILE.split_right_sorted_02 | wc -l || echo "0")
	# echo "line $line sim $SIMILARITY"
	# we need only similarities >0
	[[ $SIMILARITY -gt 0 ]] && echo "$line * $SIMILARITY" >> $INPUTDIR/$INPUTFILE.combined_sorted_similarity_02
	# also write them down in calculated form for bc
	[[ $SIMILARITY -gt 0 ]] && echo "$line * $SIMILARITY" | bc >> $INPUTDIR/$INPUTFILE.combined_sorted_similarity_bc_02
done < $INPUTDIR/$INPUTFILE.split_left_sorted_02

echo "stage 2.3: add up the values"
cat $INPUTDIR/$INPUTFILE.combined_sorted_similarity_bc_02 | paste -sd+ | bc > $INPUTDIR/$INPUTFILE.similarity_sum_02
echo "done."

echo "stage two final result is:"
cat $INPUTDIR/$INPUTFILE.similarity_sum_02
}


$1
