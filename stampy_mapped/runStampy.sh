#!/bin/bash

#PBS -l mem=20gb,nodes=1:ppn=4,walltime=95:00:00
#PBS -m abe
#PBS -M hoff0792@umn.edu
#PBS -q mesabi

set -e
set -o pipefail

# module load stampy
# module load parallel

if ! $(command -v stampy.py > /dev/null 2> /dev/null); then echo "Failed to find stampy.py, exiting..." >&2; exit 1; fi
if ! $(command -v parallel > /dev/null 2> /dev/null); then echo "Failed to find GNU Parallel, exiting..." >&2; exit 1; fi

if [[ "$#" -lt 2 ]]; then echo "Fail" >&2; exit 1; fi

FORWARD="$1"
REVERSE="$2"
REF_GENOME="$3"
DIVERGENCE="$4"
NAME="${5:-$(basename ${SAMPLE} | cut -f 1 -d '.')}"
# REF_SPECIES="${6:-'barley'}"
QUALITY="${6:-'sanger'}"

# Pubilforum: ~10%
# Bulbosum: ~2-3%
# Tauschii: ??

function checkSample() {
    local sample="$1"
    if ! [[ -f "${sample}" ]]
    then
        echo "Failed to find "${sample}", exiting..." >&2
        exit 1
    fi
}

#   Export the function
export -f checkSample

# REF_GENOME='/Users/hoffmanp/Diverged/barley_pseudomolecules_parts.fa'
# REF_SPECIES='barley'
# SAMPLE_LIST='/panfs/roc/scratch/hoffmanp/Morex_Diverged_Map/Quality_Trimming/bulbosum.txt'
# SAMPLE_LIST=''
# DIVERGENCE=0.03
# FORWARD_NAMING='_R1_trimmed.fastq.gz'
# REVERSE_NAMING='_R2_trimmed.fastq.gz'
# QUALITY='sanger'
OUTDIRECTORY="$(pwd -P)/run"
VERBOSITY=5

#   Stuff for reference index and hash files
REF_EXT=$(basename "${REF_GENOME}" | rev | cut -f 1 -d '.' | rev)
REF_PREFIX="$(dirname ${REF_GENOME})/$(basename ${REF_GENOME} .${REF_EXT})"

#   Simple checks
checkSample "${REF_GENOME}"
checkSample "${FORWARD}"
checkSample "${REVERSE}"

# checkSample "${SAMPLE_LIST}"
# declare -a COL=($(cat "${SAMPLE_LIST}" | awk '{print NF}' | sort -u))
# if [[ "${#COL[@]}" -ne 1 ]] || [[ "${COL}" ]] -ne 2 ]]; then echo "Each row in \${SAMPLE_LIST} must contain two columns: FASTQ file and divergence" >&2; exit 1; fi
# declare -a SAMPLES=($(cut -f 1 "${SAMPLE_LIST}"))
# parallel "checkSample {}" ::: "${SAMPLES[@]}"

#   Build reference genome index
echo "Looking for reference index" >&2
# if ! [[ -f "${REF_PREFIX}.stidx" ]]; then echo "Building reference index" >&2; (set -x; stampy.py --species="${REF_SPECIES}" -G "${REF_PREFIX}" "${REF_GENOME}"); fi
if ! [[ -f "${REF_PREFIX}.stidx" ]]; then echo "Failed to find reference index, exiting" >&2; exit 1; fi

#   Build the reference hash
echo "Looking for reference hash" >&2
if ! [[ -f "${REF_PREFIX}.sthash" ]]; then echo "Failed to find reference hash, exiting" >&2; exit 1; fi
# if ! [[ -f "${REF_PREFIX}.sthash" ]]; then echo "Building reference hash" >&2; (set -x; stampy.py -g "${REF_PREFIX}" -H "${REF_PREFIX}"); fi

#   Build our arrays of samples and divergences
# declare -a FORWARD_SAMPLES=($(grep "${FORWARD_NAMING}" "${SAMPLE_LIST}" | cut -f 1))
# declare -a REVERSE_SAMPLES=($(grep "${REVERSE_NAMING}" "${SAMPLE_LIST}" | cut -f 1))
# declare -a BASENAMES=($(printf "%s\n" "${FORWARD_SAMPLES[@]}" | xargs -I {} basename {} "${FORWARD_NAMING}"))
# declare -a DIVERGENCES=($(grep -E "$(echo ${FORWARD_SAMPLES[@]} | tr ' ' '|')" "${SAMPLE_LIST}" | cut -f 2))

# if [[ "${#FORWARD_SAMPLES[@]}" -ne "${#REVERSE_SAMPLES[@]}" ]]; then echo "Unequal numbers of forward and reverse samples! Exiting..." >&2; exit 1; fi
# if [[ "${#FORWARD_SAMPLES[@]}" -ne "${#BASENAMES[@]}" ]] || [[ "${#FORWARD_SAMPLES[@]}" -ne "${#DIVERGENCES[@]}" ]]; then echo "Something happened..." >&2; exit 1; fi

#   Make an output directory
mkdir -p "${OUTDIRECTORY}"

# parallel --verbose --xapply "stampy.py --genome=${REF_PREFIX} --hash=${REF_PREFIX} --substitutionrate=${DIVERGENCE} --output=${OUTDIRECTORY}{1/.}.sam --outputformat=sam --map={1} {2}" ::: ${FORWARD_SAMPLES[@]} ::: ${REVERSE_SAMPLES[@]}

(
    set -x; stampy.py \
        -g "${REF_PREFIX}" \
        -h "${REF_PREFIX}" \
        --substitutionrate="${DIVERGENCE}" \
        -f sam \
        -o "${OUTDIRECTORY}/${NAME}.sam" \
        -M "${FORWARD}","${REVERSE}"
)

