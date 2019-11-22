#!/bin/bash
#PBS -l mem=22gb,nodes=1:ppn=16,walltime=02:00:00
#PBS -m abe
#PBS -M liux1299@umn.edu
#PBS -q mesabi

set -e
set -o pipefail

# Dependencies
module load angsd_ML/0.931-9-gd22308a
module load samtools/1.9

# User provided input arguments
# Full filepath to a list of bam files to convert to fasta format
BAM_LIST=/panfs/roc/groups/9/morrellp/shared/Datasets/Alignments/barley_outgroups/Indel_Realigner/realigned_bam_list_murinum.txt
OUT_DIR=/panfs/roc/groups/9/morrellp/shared/Datasets/Alignments/barley_outgroups/morex_v2_partsRef
# Ancestral sequence parameters
#   Listed below are the defaults, please modify for your samples
#   Extract FASTA sequence from BAM file
#   For possible values of DO_FASTA:
#       See documentation: http://www.popgen.dk/angsd/index.php/Fasta
DO_FASTA=3
# Count allele frequencies
# If DO_FASTA is 1 or 2, DO_COUNTS must be 1
# Otherwise, DO_COUNTS can be any other legal value
#   Possible values of DO_COUNTS:
#       0 is do not count allele frequencies
#       1 is count allele frequencies
DO_COUNTS=1

# Check that out dir exists, if not make it
mkdir -p ${OUT_DIR}

# Run angsd using PBS task arrays
CURRENT_BAM=$(cut -f 1 "${BAM_LIST}" | sed "${PBS_ARRAYID}q;d")

# Generate sample name from input bam
# Currently, assumes bam file ends in _realigned.bam
SAMPLE_NAME=$(basename ${CURRENT_BAM} _realigned.bam)

# Run angsd to convert bam to fasta
angsd \
    -doFasta ${DO_FASTA} \
    -doCounts ${DO_COUNTS} \
    -i ${CURRENT_BAM} \
    -out ${OUT_DIR}/${SAMPLE_NAME}

# Unzip the gzipped fasta file
gzip -d "${OUT_DIR}/${SAMPLE_NAME}.fa.gz"

# Index fasta file
samtools faidx "${OUT_DIR}/${SAMPLE_NAME}.fa"
