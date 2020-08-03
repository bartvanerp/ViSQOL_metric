#!/bin/bash
echo start

# specify directory of files to evaluate
DIR_files="audio/to_evaluate"

# specify directory of original files
DIR_original="audio/original"

# fetch timestamp
dateofeval=`date +%Y%m%d_%H%M`	

for file in `ls $DIR_files`
do

	# what is the correct sound file?
	sound=`cut -d "." -f 1 <<< "$file"`
	sound=`echo "$sound" | rev | cut -d '_' -f 1 | rev`

	# specify path to current signal
	PATH_file=$DIR_files"/"$file

	# specify path to original signal
	PATH_original=$DIR_original"/original_$sound.wav"
	
	# first upsample files and create correct header
	ffmpeg -y -i $PATH_file -vn -ar 16000 -loglevel 24 $PATH_file
	ffmpeg -y -i $PATH_original -vn -ar 16000 -loglevel 24 $PATH_original
	
	# rename results file name to include time of evaluation
	PATH_results="results/ViSQOL_scores_$dateofeval.csv"

	# calculate ViSQOL metric
	bazel-bin/visqol.exe \
		--reference_file $PATH_original \
		--degraded_file $PATH_file \
		--use_speech_mode \
		--results_csv $PATH_results
done


