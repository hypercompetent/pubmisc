#!/bin/bash
# This script performs a parallel md5sum, and records the results in a single file.
#
# It requires GNU parallel: https://www.gnu.org/software/parallel/
# 
# usage: parallel_md5sum.sh source_folder source_ext out_file n_cores
#
# example: parallel_md5sum.sh my_fastqs/ .fastq.gz 20180620_md5sums.txt 8


source_folder=$1
source_ext=$2
out_file=$3

# If no n_parallel provided, run on just one core.
if [ -z "$4" ]; then
	n_parallel=1
else
	n_parallel=$4
fi


find ${source_folder}/ -name *${source_ext} | parallel --gnu -j $n_parallel "md5sum {} >> ${out_file}"
