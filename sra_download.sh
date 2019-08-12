#!/bin/bash
#PBS -l mem=32gb,nodes=1:ppn=8,walltime=24:00:00
#PBS -m abe
#PBS -M liux1299@umn.edu
#PBS -q lab

set -e
set -o pipefail

# Dependencies
module load parallel/20190122

# User provided input arguments
FTP_LIST=/panfs/roc/groups/9/morrellp/liux1299/GitHub/Barley_Outgroups/sra_ftp_links.txt
OUT_DIR=/scratch.global/liux1299/sra_outgroups

# Check if out dir exists, if not make it
mkdir -p ${OUT_DIR}
# Go into OUT_DIR
cd ${OUT_DIR}

# Store list of links in array
FTP_ARR=($(cat "${FTP_LIST}"))

# Download sra files
parallel wget {} ::: ${FTP_ARR[@]}
