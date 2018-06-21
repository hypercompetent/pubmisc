#!/bin/bash
# This script performs a parallel, batch upload of files in a directory to a bucket ot AWS S3
#
# It requires s3cmd and GNU parallel
# s3cmd: http://s3tools.org/s3cmd
# GNU parallel: https://www.gnu.org/software/parallel/
#
# Before use, run s3cmd configure to set up your account credentials.
#
# usage: s3cmd_parallel_deposit.sh source_folder source_ext target_folder n_parallel rate_limit
#
# example: s3cmd_parallel_deposit.sh my_fastqs/ .fastq s3://aibs-u19-deposit/Sandberg/20180620/ 8 25m


source_folder=$1
source_ext=$2
target_folder=$3

# If no n_parallel provided, run on just one core.
if [ -z "$4" ]; then
	n_parallel=1
else
	n_parallel=$4
fi

# If no rate provided, limit to 25m per core.
if [ -z "$5" ]; then
	rate_limit=25m
else
	rate_limit=$5
fi

find ${source_folder}/ -name *${source_ext} | parallel --gnu -j $n_parallel "s3cmd --continue-put --limit-rate=${rate_limit} put {} ${target_folder}{/}"
