#!/bin/bash
#PBS -l mem=22gb,nodes=1:ppn=8,walltime=02:00:00
#PBS -m abe
#PBS -M liux1299@umn.edu
#PBS -q lab

set -e
set -o pipefail

# Dependencies
module load stampy_ML/1.0.32

# User provided input argumnets
REF=/panfs/roc/groups/9/morrellp/shared/References/Reference_Sequences/Barley/Morex_v2/Barley_Morex_V2_pseudomolecules_parts.fasta
PREFIX=Barley_Morex_V2_pseudomolecules_parts
OUT_DIR=/panfs/roc/groups/9/morrellp/shared/References/Reference_Sequences/Barley/Morex_v2/stampy_files

# Check if out dir exists, if not make it
mkdir -p ${OUT_DIR}
# Go into output dir
cd ${OUT_DIR}

# Build a genome (.stidx) file
stampy.py -G ${PREFIX} ${REF}

# Build a hash table
stampy.py -g ${PREFIX} -H ${PREFIX}
