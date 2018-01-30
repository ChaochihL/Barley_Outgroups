#!/usr/bin/env bash

#PBS -l mem=62gb,nodes=1:ppn=24,walltime=72:00:00
#PBS -m abe
#PBS -M liux1299@umn.edu
#PBS -q small

set -e
set -o pipefail

module load R/3.3.3

~/software_development/angsd-wrapper/angsd-wrapper Ancestral /home/morrellp/liux1299/GitHub/Barley_Outgroups/Bam_to_Fasta/Ancestral_Sequence_murinum_0.03_Config
