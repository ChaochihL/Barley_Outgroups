#!/usr/bin/env bash

#PBS -l mem=22gb,nodes=1:ppn=16,walltime=24:00:00
#PBS -m abe
#PBS -M liux1299@umn.edu
#PBS -q lab

set -e
set -o pipefail

module load R/3.3.3

~/software_development/angsd-wrapper/angsd-wrapper Ancestral /home/morrellp/liux1299/GitHub/Barley_Outgroups/ANGSD-wrapper/Ancestral_Sequence_bulbosum_A12_0.03_Config