#!/bin/bash

#PBS -l mem=62gb,nodes=1:ppn=24,walltime=96:00:00
#PBS -m abe
#PBS -M liux1299@umn.edu
#PBS -q small

set -e
set -u
set -o pipefail

#   This script takes murinum BAM parts 0-15 and merges them using samtools
#       and was intended to be submitted as a job on MSI

#   Dependencies
samtools_ML/1.3.1

#   User provided arguments
BAM_LIST=/panfs/roc/scratch/liux1299/outgroups/SAM_Processing/Picard/murinum_bam_list_0.03.txt
OUT_DIR=/panfs/roc/scratch/liux1299/outgroups/merged_bam
OUT_FILE=murinum_0.03.bam

#   Check if outdirectory exists
mkdir -p "${OUT_DIR}"
#   Merge bam files
samtools merge -b "${BAM_LIST}" "${OUT_DIR}"/"${OUT_FILE}"
