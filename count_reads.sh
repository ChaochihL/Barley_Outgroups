#!/bin/bash

#PBS -l mem=16gb,nodes=1:ppn=16,walltime=01:00:00
#PBS -m abe
#PBS -M liux1299@umn.edu
#PBS -q mesabi

set -e
set -o pipefail

module load parallel

#   This script uses bioawk (https://github.com/lh3/bioawk) to count the number of
#       reads in a .fastq.gz file and outputs a .txt file with read counts

SAMPLE_LIST=/home/morrellp/liux1299/scratch/outgroups/Adapter_Trimming/tmp_test/tmp_list.txt
OUT_FILENAME=murinum_trimmed_read_counts.txt
OUT_DIR=/panfs/roc/scratch/liux1299/outgroups/Adapter_Trimming/tmp_test

#   Check that out directory exists, if not make one
mkdir -p "${OUT_DIR}"

#   Build our fastq list
FASTQ_LIST=($(cat "${SAMPLE_LIST}" | sort -uV))

#   Define read count function
function countReads() {
    local fastq_file=$1
    local outname=$2
    local out_dir=$3
    sample_name=$(basename "${fastq_file}" .fastq.gz)
    num_reads=$(bioawk -cfastx 'END{print NR}' "${fastq_file}")
    echo -e "${sample_name}\t${num_reads}\n" >> ${out_dir}/${outname}
}

export -f countReads

#   Create file with headers
printf "Sample\tRead_Count\n" > "${OUT_DIR}"/"${OUT_FILENAME}"
#   Count reads in parallel for each sample
parallel countReads {} "${OUT_FILENAME}" "${OUT_DIR}" ::: "${FASTQ_LIST[@]}"
