#!/bin/bash

#PBS -l walltime=95:00:00,mem=60gb,nodes=1:ppn=6
#PBS -m abe
#PBS -M hoff0792@umn.edu
#PBS -q mesabi

set -eo pipefail

module load stampy
module load parallel

declare -a DEPENDENCIES=(parallel stampy.py)
STAMPY_SCRIPT='/panfs/roc/scratch/hoffmanp/sandbox/Diverged/runStampy.sh'

for dep in ${DEPENDENCIES[@]}
do
    if ! $(command -v ${dep} > /dev/null 2> /dev/null)
    then
        echo "Please install ${dep}" >&2
        exit 1
    fi
done

if ! [[ -f "${STAMPY_SCRIPT}" ]]; then echo "Cannot find stampy script, exiting" >&2; exit 1; fi

SAMPLE_LIST='/panfs/roc/scratch/hoffmanp/sandbox/Diverged/Pubiflorum.txt'
FWD_NAMING='_R1_trimmed.fastq.gz'
DIVERGENCE='0.10'
REF_GEN='/panfs/roc/scratch/hoffmanp/sandbox/Diverged/barley_pseudomolecules_parts.fa'

declare -a FORWARD=($(grep "${FWD_NAMING}" "${SAMPLE_LIST}" | sort))
declare -a REVERSE=($(grep -v "${FWD_NAMING}" "${SAMPLE_LIST}" | sort))
if [[ "${#FORWARD[@]}" -ne "${#REVERSE[@]}" ]]; then echo "Unequal forward and reverse samples, exiting" >&2; exit 1; fi

declare -a SAMPLE_NAMES=($(echo "${FORWARD[@]}" | xargs -n 1 -I {} basename {} "${FWD_NAMING}"))

parallel --verbose --xapply "bash ${STAMPY_SCRIPT} {1} {2} ${REF_GEN} ${DIVERGENCE} {3}" ::: "${FORWARD[@]}" ::: "${REVERSE[@]}" ::: "${SAMPLE_NAMES[@]}"
