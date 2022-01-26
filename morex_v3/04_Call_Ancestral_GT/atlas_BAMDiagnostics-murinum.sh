#!/bin/bash
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=8
#SBATCH --mem=22gb
#SBATCH --tmp=20gb
#SBATCH -t 06:00:00
#SBATCH --mail-type=ALL
#SBATCH --mail-user=liux1299@umn.edu
#SBATCH -p small,ram256g,ram1t
#SBATCH -o %j.out
#SBATCH -e %j.err

set -e
set -o pipefail

# Dependencies
module load atlas_ML/0.9

# User provided input arguments
# Output .txt files by defaults outputs to the same directory as the realigned BAM file
BAM_FILE="/scratch.global/liux1299/barley_outgroups_morex_v3_2021-03-22/Indel_Realigner/murinum_BCC2017_0.03_realigned.bam"
OUT_DIR="/scratch.global/liux1299/barley_outgroups_morex_v3_2021-03-22/atlas"
RG_NAME="murinum_BCC2017_part1_0.03"
MAX_MQ="200"

#--------------------
# Check that out dir exists, if not make it
mkdir -p ${OUT_DIR}
cd ${OUT_DIR}

atlas task=BAMDiagnostics bam=${BAM_FILE} readGroup=${RG_NAME} maxMQ=${MAX_MQ} verbose
