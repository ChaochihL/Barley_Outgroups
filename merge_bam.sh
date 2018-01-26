#!/bin/bash

#PBS -l mem=62gb,nodes=1:ppn=24,walltime=42:00:00
#PBS -m abe
#PBS -M liux1299@umn.edu
#PBS -q small

set -e
set -u
set -o pipefail

#   This script takes reheader murinum BAM parts 0-15 and merges them using samtools
#       and was intended to be submitted as a job on MSI

#   Dependencies
module load samtools_ML/1.3.1

#   User provided arguments
BAM_LIST=/home/morrellp/liux1299/scratch/outgroups/reheader_bam/murinum_0.03_reheader_bam_list.txt
OUT_DIR=/home/morrellp/liux1299/scratch/outgroups/merged_bam
OUT_FILE=murinum_0.03.bam

#   Check if outdirectory exists
mkdir -p "${OUT_DIR}"
#   Merge bam files
samtools merge -b "${BAM_LIST}" "${OUT_DIR}"/"${OUT_FILE}"
