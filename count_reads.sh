#!/bin/bash

#PBS -l mem=16gb,nodes=1:ppn=16,walltime=02:00:00
#PBS -m abe
#PBS -M liux1299@umn.edu
#PBS -q lab 

set -e
set -o pipefail

module load parallel

#   This script uses bioawk (https://github.com/lh3/bioawk) to count the number of
#       reads in a .fastq.gz file and outputs a .txt file with read counts
BIOAWK=/panfs/roc/groups/9/morrellp/liux1299/Software/bioawk/bioawk
SAMPLE_LIST=/home/morrellp/liux1299/scratch/outgroups/Adapter_Trimming/murinum_trimmed_adapters.txt
OUT_FILENAME=murinum_trimmed_read_counts.txt
OUT_DIR=/home/morrellp/liux1299/scratch/outgroups/Adapter_Trimming

#   Check that out directory exists, if not make one
mkdir -p "${OUT_DIR}"

#   Build our fastq list
FASTQ_LIST=($(cat "${SAMPLE_LIST}" | sort -uV))

function countReads() {
    local fastq_file=$1
    local outname=$2
    local out_dir=$3
	local bioawk=$4
    sample_name=$(basename "${fastq_file}" .fastq.gz)
    num_reads=$("${bioawk}" -cfastx 'END{print NR}' "${fastq_file}")
    echo -e "${sample_name}\t${num_reads}" >> ${out_dir}/${outname}
}

export -f countReads

#   Create file with headers
printf "Sample\tRead_Count\n" > "${OUT_DIR}"/"${OUT_FILENAME}"

#   Count reads in parallel for each sample
parallel countReads {} "${OUT_FILENAME}" "${OUT_DIR}" "${BIOAWK}" ::: "${FASTQ_LIST[@]}"

