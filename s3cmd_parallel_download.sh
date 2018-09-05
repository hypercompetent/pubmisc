#!/bin/bash
# This script performs a parallel, batch downloads of files in an AWS S3 directory to a local directory
#
# It requires s3cmd and GNU parallel
# s3cmd: http://s3tools.org/s3cmd
# GNU parallel: https://www.gnu.org/software/parallel/
#
# Before use, run s3cmd --configure to set up your account credentials.
#
# usage: s3cmd_parallel_deposit.sh source_directory file_extension target_directory n_parallel rate_limit
#
# example: s3cmd_parallel_download.sh s3://aibs-u19-brain-grant/SMARTer/cells/VIS/VISp/fastq/ .fastq.gz /local1/VISp_fastq/ 8 25m


source_directory=$1
source_ext=$2
target_directory=$3

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

echo "Retrieving manifest for ${source_directory}"
s3cmd ls --requester-pays ${source_directory} > temp_s3_manifest.txt

echo "Downloading ${source_ext} files from ${source_directory}"
cat temp_s3_manifest.txt | \
  awk -F'[ ]+' '{print $4}' | \
  grep ${source_ext}'$' | \
  parallel --gnu -j $n_parallel "s3cmd --requester-pays --continue --skip-existing --limit-rate=${rate_limit} get {} ${target_directory}{/}"
# --requester-pays - required for retrieving data from s3://aibs-u19-brain-grant/
# --continue - continue downloading partially downloaded files - should allow you to resume if interrupted
# --skip-existing - skip files you already have - also for resuming if interrupted.
# --limit-rate - Limit download rate for each core
rm temp_s3_manifest.txt
