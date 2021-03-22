#!/bin/bash
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=2
#SBATCH --mem=30gb
#SBATCH --tmp=20gb
#SBATCH -t 80:00:00
#SBATCH --mail-type=ALL
#SBATCH --mail-user=liux1299@umn.edu
#SBATCH -p ram256g,ram1t,amd2tb
#SBATCH -o stampy-murinum-0.03.sh.%A_%a.out
#SBATCH -e stampy-murinum-0.03.sh.%A_%a.err

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
N_THREADS=2
#   Reference prefix must match .stidx files
REF_PREFIX='Barley_MorexV3_pseudomolecules_parts'
#   What directory contains our reference files?
REF_DIR='/panfs/roc/groups/9/morrellp/shared/References/Reference_Sequences/Barley/Morex_v3/stampy_files'
#   What is our per site substitution rate?
DIVERGENCE='0.03'
#   Where do our output files go?
OUT_DIR=/scratch.global/liux1299/barley_outgroups/stampy_mapped
#   What is our forward read?
FORWARD_LIST=/scratch.global/liux1299/barley_outgroups/Adapter_Trimming/murinum_split/murinum_forward_parts_list.txt
#   What is our reverse read?
REVERSE_LIST=/scratch.global/liux1299/barley_outgroups/Adapter_Trimming/murinum_split/murinum_reverse_parts_list.txt

#-----------------
#   Create an array of fastq.gz files used for job array
#   IMPORTANT: Assumes the sample orders are the same (i.e., both lists are sorted in the same way)
FWD_ARR=($(cat ${FORWARD_LIST}))
REV_ARR=($(cat ${REVERSE_LIST}))
#   Get the current sample we are processing
FWD_SAMPLE=${FWD_ARR[${SLURM_ARRAY_TASK_ID}]}
REV_SAMPLE=${REV_ARR[${SLURM_ARRAY_TASK_ID}]}

function stampy_map() {
    local sample_fwd="$1" # forward sample
    local sample_rev="$2" # reverse sample
    local n_threads="$3" # what is the number of threads requested?
    local ref_prefix="$4" # what is the prefix of our reference?
    local ref_dir="$5" # what is the directory of our reference?
    local divergence="$6" # what is our per site substitution rate?
    local out_dir="$7" # what is our output directory?
    #   What is the sample name without the suffix and forward/reverse indicators?
    #   Note: naming scheme is specific to this set of samples
    #   i.e. murinum_Forward_ScytheTrimmed_part00.fastq.gz
    local sample_name=$(basename ${sample_fwd} .fastq.gz | cut -d '_' -f 1,2,5)
    #   Check if SAM file exists, if so delete. Stampy errors out if file exists
    if [ -f ${out_dir}/${sample_name}_${divergence}.sam ]
    then
        # File exists
        rm ${out_dir}/${sample_name}_${divergence}.sam
    fi
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
           -o "${out_dir}/${sample_name}_${divergence}.sam" \
           -M "${sample_fwd}","${sample_rev}"
}

#   Export the function
export -f stampy_map

#   Run stampy on all parts
stampy_map "${FWD_SAMPLE}" "${REV_SAMPLE}" "${N_THREADS}" "${REF_PREFIX}" "${REF_DIR}" "${DIVERGENCE}" "${OUT_DIR}"
