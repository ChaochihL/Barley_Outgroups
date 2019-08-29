#!/bin/bash
#PBS -l mem=60gb,nodes=1:ppn=24,walltime=90:00:00
#PBS -m abe
#PBS -M liux1299@umn.edu
#PBS -q mesabi

set -e
set -o pipefail

#   This script maps barley outgroup sequences and outputs a SAM file.
#   This script was written by Chaochih Liu

module load stampy_ML/1.0.32

#   User provided arguments
#   Reference prefix must match .stidx files
REF_PREFIX='Barley_Morex_V2_pseudomolecules_parts'
#   What directory contains our reference files?
REF_DIR='/home/morrellp/liux1299/Shared/References/Reference_Sequences/Barley/Morex_v2/stampy_files'
#   What is our per site substitution rate?
DIVERGENCE='0.03'
#   Where do our output files go?
OUT_DIR='/scratch.global/liux1299/barley_outgroups/stampy_mapped'
#   What is our forward read?
FORWARD='/panfs/roc/groups/9/morrellp/shared/Datasets/Alignments/barley_outgroups/Adapter_Trimming/bulbosum_A12_Forward_ScytheTrimmed.fastq.gz'
#   What is our reverse read?
REVERSE='/panfs/roc/groups/9/morrellp/shared/Datasets/Alignments/barley_outgroups/Adapter_Trimming/bulbosum_A12_Reverse_ScytheTrimmed.fastq.gz'
#   Takes our forward read and generates sample name for output file
SAMPLE_NAME=bulbosum_A12

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
       -o "${OUT_DIR}/${SAMPLE_NAME}_0.03.sam" \
       -M "${FORWARD}","${REVERSE}"
