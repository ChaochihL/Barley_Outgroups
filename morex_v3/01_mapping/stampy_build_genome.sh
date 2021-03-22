#!/bin/bash
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=8
#SBATCH --mem=22gb
#SBATCH --tmp=12gb
#SBATCH -t 03:00:00
#SBATCH --mail-type=ALL
#SBATCH --mail-user=liux1299@umn.edu
#SBATCH -p small,ram256g,ram1t
#SBATCH -o %j.out
#SBATCH -e %j.err

set -e
set -o pipefail

# Dependencies
module load stampy_ML/1.0.32

# User provided input argumnets
REF="/panfs/roc/groups/9/morrellp/shared/References/Reference_Sequences/Barley/Morex_v3/Barley_MorexV3_pseudomolecules_parts.fasta"
PREFIX="Barley_MorexV3_pseudomolecules_parts"
OUT_DIR="/panfs/roc/groups/9/morrellp/shared/References/Reference_Sequences/Barley/Morex_v3/stampy_files"

#-----------------
# Check if out dir exists, if not make it
mkdir -p ${OUT_DIR}
# Go into output dir
cd ${OUT_DIR}

# Build a genome (.stidx) file
stampy.py -G ${PREFIX} ${REF}

# Build a hash table
stampy.py -g ${PREFIX} -H ${PREFIX}
