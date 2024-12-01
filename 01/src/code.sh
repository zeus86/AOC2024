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

$1
