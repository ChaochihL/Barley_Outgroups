#!/bin/bash
#PBS -l mem=12gb,nodes=1:ppn=16,walltime=12:00:00
#PBS -m abe
#PBS -M liux1299@umn.edu
#PBS -q mesabi

set -e
set -u
set -o pipefail

#   This script takes reheader murinum BAM parts 0-15 and merges them using samtools
#       and was intended to be submitted as a job on MSI

#   Dependencies
module load samtools/1.9

#   User provided arguments
BAM_LIST=/panfs/roc/groups/9/morrellp/shared/Datasets/Alignments/barley_outgroups/reheader_bam/reheadered_bam_list.txt
OUT_DIR=/panfs/roc/groups/9/morrellp/shared/Datasets/Alignments/barley_outgroups/merged_bam
OUT_FILE=murinum_BCC2017_0.03.bam

#   Check if outdirectory exists
mkdir -p "${OUT_DIR}"

#   Merge bam files
samtools merge -b "${BAM_LIST}" "${OUT_DIR}/${OUT_FILE}"

#   Index bam files
samtools index -b "${OUT_DIR}/${OUT_FILE}"
#   Rename indexed bam file
cd ${OUT_DIR}
rename -v ".bam.bai" ".bai" *.bam.bai
