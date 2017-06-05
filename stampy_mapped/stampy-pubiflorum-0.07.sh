#!/bin/bash

#PBS -l mem=62gb,nodes=1:ppn=24,walltime=72:00:00
#PBS -m abe
#PBS -M liux1299@umn.edu
#PBS -q mesabi

set -e
set -o pipefail

#   This script maps barley outgroup sequences and outputs a SAM file.
#   This script was written by Chaochih Liu

module load stampy_ML/1.0.31

#   User provided arguments
#   Reference prefix must match .stidx files
REF_PREFIX='barley_pseudomolecules_parts'
#   What directory contains our reference files?
REF_DIR='/home/morrellp/liux1299/scratch/outgroups'
#   What is our per site substitution rate?
DIVERGENCE='0.07'
#   Where do our output files go?
OUT_DIR='/home/morrellp/liux1299/scratch/outgroups/stampy_mapped'
#   What is our forward read?
FORWARD='/home/morrellp/liux1299/scratch/outgroups/pubiflorum_BCC2028_R1_trimmed.fastq.gz'
#   What is our reverse read?
REVERSE='/home/morrellp/liux1299/scratch/outgroups/pubiflorum_BCC2028_R2_trimmed.fastq.gz'
#   Takes our forward read and generates sample name for output file
SAMPLE_NAME="$(basename ${FORWARD} | cut -f 1 -d '.')"

#   Stampy test run
#       -g is the genome index file, PREFIX.stidx
#       -h is the genome hash file, PREFIX.sthash
#       --substitutionrate is the expected fraction of Poisson-distributed substitutions (default is 0.001)
#       -f is the output file format
#       -M reads to map
#       -o is our output file
cd ${REF_DIR}
stampy -g "${REF_PREFIX}" \
       -h "${REF_PREFIX}" \
       --substitutionrate="${DIVERGENCE}" \
       -f sam \
       -o "${OUT_DIR}/${SAMPLE_NAME}_0.07.sam" \
       -M "${FORWARD}","${REVERSE}"

