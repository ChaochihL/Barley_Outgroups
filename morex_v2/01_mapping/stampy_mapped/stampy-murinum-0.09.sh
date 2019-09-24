#!/bin/bash

set -e
set -u
set -o pipefail

#   This script maps barley outgroup sequences and outputs a SAM file.
#   This script was written by Chaochih Liu

#   Dependencies
module load stampy_ML/1.0.32

#   User provided arguments
#   Number of threads available
#   Note this has to match number of threads requested
N_THREADS=24
#   Reference prefix must match .stidx files
REF_PREFIX=Barley_Morex_V2_pseudomolecules_parts
#   What directory contains our reference files?
REF_DIR=/home/morrellp/liux1299/Shared/References/Reference_Sequences/Barley/Morex_v2/stampy_files
#   What is our per site substitution rate?
DIVERGENCE='0.09'
#   Where do our output files go?
OUT_DIR=/scratch.global/liux1299/barley_outgroups/stampy_mapped
#   What is our forward read?
FORWARD_LIST=/panfs/roc/groups/9/morrellp/shared/Datasets/Alignments/barley_outgroups/Adapter_Trimming/murinum_split/murinum_forward_parts_list.txt
#   What is our reverse read?
REVERSE_LIST=/panfs/roc/groups/9/morrellp/shared/Datasets/Alignments/barley_outgroups/Adapter_Trimming/murinum_split/murinum_reverse_parts_list.txt

function stampy_map() {
    local fwd_list="$1" # forward reads sample list
    local rev_list="$2" # reverse reads sample list
    local n_threads="$3" # what is the number of threads requested?
    local ref_prefix="$4" # what is the prefix of our reference?
    local ref_dir="$5" # what is the directory of our reference?
    local divergence="$6" # what is our per site substitution rate?
    local out_dir="$7" # what is our output directory?
    #   Convert sample list into an array
    declare -a fwd_array=($(grep -E ".fastq.gz" "${fwd_list}")) # forward reads
    declare -a rev_array=($(grep -E ".fastq.gz" "${rev_list}")) # reverse reads
    #   Which sample are we currently working on?
    local sample_fwd="${fwd_array[${PBS_ARRAYID}]}" # forward samples
    local sample_rev="${rev_array[${PBS_ARRAYID}]}" # reverse samples
    #   What is the sample name without the suffix and forward/reverse indicators?
    #   Note: naming scheme is specific to this set of samples
    #   i.e. murinum_Forward_ScytheTrimmed_part00.fastq.gz
    local sample_name=$(basename ${sample_fwd} .fastq.gz | cut -d '_' -f 1,2,5)

    #   Make sure out directory exists
    mkdir -p "${out_dir}"
    #   Go into directory with stampy compatible reference
    cd "${ref_dir}"

    #   Read map using Stampy
    #       -g is the genome index file, PREFIX.stidx
    #       -h is the genome hash file, PREFIX.sthash
    #       --substitutionrate is the expected fraction of Poisson-distributed substitutions (default is 0.001)
    #       -f is the output file format
    #       -M reads to map
    #       -o is our output file
    stampy.py -g "${ref_prefix}" \
           -h "${ref_prefix}" \
           --substitutionrate="${divergence}" \
           -t "${n_threads}" \
           -f sam \
           -o "${out_dir}/${sample_name}_0.09.sam" \
           -M "${sample_fwd}","${sample_rev}"
}

#   Export the function
export -f stampy_map

#   Create an array of fastq.gz files used for job array
FWD_ARRAY=($(grep -E ".fastq.gz" "${FORWARD_LIST}")) # forward reads
REV_ARRAY=($(grep -E ".fastq.gz" "${REVERSE_LIST}")) # reverse reads

#   Run stampy on all parts
stampy_map "${FORWARD_LIST}" "${REVERSE_LIST}" "${N_THREADS}" "${REF_PREFIX}" "${REF_DIR}" "${DIVERGENCE}" "${OUT_DIR}"
