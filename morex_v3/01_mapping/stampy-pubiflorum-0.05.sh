#!/bin/bash
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=2
#SBATCH --mem=60gb
#SBATCH --tmp=40gb
#SBATCH -t 60:00:00
#SBATCH --mail-type=ALL
#SBATCH --mail-user=liux1299@umn.edu
#SBATCH -p ram256g,ram1t,amd2tb
#SBATCH -o %j.out
#SBATCH -e %j.err

set -e
set -o pipefail

#   This script maps barley outgroup sequences and outputs a SAM file.
#   This script was written by Chaochih Liu

module load stampy_ML/1.0.32

#   User provided arguments
#   Reference prefix must match .stidx files
REF_PREFIX='Barley_MorexV3_pseudomolecules_parts'
#   What directory contains our reference files?
REF_DIR='/panfs/roc/groups/9/morrellp/shared/References/Reference_Sequences/Barley/Morex_v3/stampy_files'
#   What is our per site substitution rate?
DIVERGENCE='0.05'
#   Where do our output files go?
OUT_DIR='/scratch.global/liux1299/barley_outgroups/stampy_mapped'
#   What is our forward read?
FORWARD='/scratch.global/liux1299/barley_outgroups/Adapter_Trimming/pubiflorum_BCC2028_Forward_ScytheTrimmed.fastq.gz'
#   What is our reverse read?
REVERSE='/scratch.global/liux1299/barley_outgroups/Adapter_Trimming/pubiflorum_BCC2028_Reverse_ScytheTrimmed.fastq.gz'
#   Takes our forward read and generates sample name for output file
SAMPLE_NAME="pubiflorum_BCC2028"

#-----------------
#   Check that out dir exists, if not make it
mkdir -p ${OUT_DIR}

#   Stampy run
#       -g is the genome index file, PREFIX.stidx
#       -h is the genome hash file, PREFIX.sthash
#       --substitutionrate is the expected fraction of Poisson-distributed substitutions (default is 0.001)
#       -f is the output file format
#       -M reads to map
#       -o is our output file
cd ${REF_DIR}
stampy.py -g "${REF_PREFIX}" \
       -h "${REF_PREFIX}" \
       --substitutionrate="${DIVERGENCE}" \
       -f sam \
       -o "${OUT_DIR}/${SAMPLE_NAME}_${DIVERGENCE}.sam" \
       -M "${FORWARD}","${REVERSE}"

