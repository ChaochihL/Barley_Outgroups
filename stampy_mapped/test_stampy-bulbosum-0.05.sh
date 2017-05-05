#!/bin/bash

#PBS -l mem=22gb,nodes=1:ppn=16,walltime=24:00:00
#PBS -m abe
#PBS -M liux1299@umn.edu
#PBS -q lab

set -e
set -o pipefail

#   This script simulates the behaviour of stampy conditional on indels being present.
#   This script was written by Chaochih Liu

module load stampy_ML/1.0.31

#   User provided arguments
#   Reference prefix must match .stidx files
REF_PREFIX='barley_pseudomolecules_parts'
#   What directory contains our reference files?
REF_DIR='/home/morrellp/liux1299/scratch/outgroups'
#   What is our per site substitution rate?
DIVERGENCE='0.05'
#   Where do our output files go?
OUT_DIR='/home/morrellp/liux1299/scratch/outgroups'
#   What is our forward read?
FORWARD='/home/morrellp/liux1299/scratch/outgroups/Adapter_Trimming/bulbosum02_R1_trimmed.fastq.gz'
#   What is our reverse read?
REVERSE='/home/morrellp/liux1299/scratch/outgroups/Adapter_Trimming/bulbosum02_R2_trimmed.fastq.gz'
#   Takes our forward read and generates sample name for output file
SAMPLE_NAME="$(basename ${FORWARD} | cut -f 1 -d '.')"

#   Stampy test run
#       -g is the genome index file, PREFIX.stidx
#       -h is the genome hash file, PREFIX.sthash
#       --substitutionrate is the expected fraction of Poisson-distributed substitutions (default is 0.001)
#       -T runs both: -S command to simulate reads and -P command to parse .sam output
#       -o is our output file
cd ${REF_DIR}
stampy -g "${REF_PREFIX}" \
       -h "${REF_PREFIX}" \
       --substitutionrate="${DIVERGENCE}" \
       -T "${FORWARD}","${REVERSE}"
       -o "${OUT_DIR}/${SAMPLE_NAME}_0.05.sam"
