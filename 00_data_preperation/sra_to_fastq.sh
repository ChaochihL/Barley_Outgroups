#!/bin/bash
#PBS -l mem=22gb,nodes=1:ppn=8,walltime=24:00:00
#PBS -m abe
#PBS -M liux1299@umn.edu
#PBS -q lab
#PBS -N sra2fastq

# This script runs uses NCBI's SRA Toolkit to convert SRA files to FASTQ files.

# Dependencies
module load parallel/20190122
module load sratoolkit_ML/2.9.6

# User provided input arguments
SRA_LIST=/scratch.global/liux1299/sra_outgroups/sra_outgroups_list.txt
OUT_DIR=/scratch.global/liux1299/sra_outgroups/fastq

SRA_ARR=($(cat "${SRA_LIST}"))

mkdir -p "${OUT_DIR}"

# Run download script
parallel fastq-dump --split-files {} --outdir "${OUT_DIR}" --gzip ::: ${SRA_ARR[@]}
