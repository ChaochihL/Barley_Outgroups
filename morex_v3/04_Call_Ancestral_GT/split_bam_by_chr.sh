#!/bin/bash
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=8
#SBATCH --mem=22gb
#SBATCH --tmp=18gb
#SBATCH -t 02:00:00
#SBATCH --mail-type=ALL
#SBATCH --mail-user=liux1299@umn.edu
#SBATCH -p small,ram256g,ram1t,amd2tb
#SBATCH -o %j.out
#SBATCH -e %j.err

set -e
set -o pipefail

# H. murinum realigned BAM file is too large for ATLAS to run in a reasonable
#   amount of time with a reasonable amount of memory, so we'll try
#   splitting the BAM file by chromosome and then run it through ATLAS

# Dependencies
module load samtools/1.14
module load parallel/20210822

# User provided input arguments
BAM_FILE="/scratch.global/liux1299/barley_outgroups_morex_v3_2021-03-22/Indel_Realigner/murinum_BCC2017_0.03_realigned.bam"
CHR_LIST="/scratch.global/liux1299/barley_outgroups_morex_v3_2021-03-22/Indel_Realigner/chr_parts_names.txt"
OUT_DIR="/scratch.global/liux1299/barley_outgroups_morex_v3_2021-03-22/realigned_split_murinum"

#-----------------------
mkdir -p ${OUT_DIR}

function split_by_chr() {
    local bam_file="$1"
    local chr_name="$2"
    local out_dir="$3"
    prefix=$(basename ${bam_file} .bam)
    # Output in BAM format
    samtools view -b "${bam_file}" "${chr_name}" > "${out_dir}/${chr_name}-${prefix}.bam"
    # Index BAM
    # ATLAS sofware expects indices to be named with .bam.bai extensions
    #   instead of just .bai
    samtools index -b "${out_dir}/${chr_name}-${prefix}.bam" "${out_dir}/${chr_name}-${prefix}.bam.bai"
}

export -f split_by_chr

# Split by chromosome in parallel
parallel --verbose split_by_chr ${BAM_FILE} {} ${OUT_DIR} :::: ${CHR_LIST}
