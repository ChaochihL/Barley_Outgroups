#!/bin/bash
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=16
#SBATCH --mem=20gb
#SBATCH --tmp=18gb
#SBATCH -t 12:00:00
#SBATCH --mail-type=ALL
#SBATCH --mail-user=liux1299@umn.edu
#SBATCH -p small,ram256g,ram1t
#SBATCH -o %j.out
#SBATCH -e %j.err

set -e
set -u
set -o pipefail

#   This script takes reheader murinum BAM parts 0-15 and merges them using samtools
#       and was intended to be submitted as a job on MSI

#   Dependencies
module load samtools/1.9

#   User provided arguments
BAM_LIST=/scratch.global/liux1299/barley_outgroups/reheader_bam/reheadered_bam_list.txt
OUT_DIR=/scratch.global/liux1299/barley_outgroups/merged_bam
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
