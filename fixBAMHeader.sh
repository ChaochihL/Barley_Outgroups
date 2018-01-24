#!/bin/bash

set -eo pipefail

#   Check for dependencies
$(type readarray > /dev/null 2> /dev/null) || (echo "Please use BASH 4 or higher for this script" >&2; exit 1)
$(command -v samtools > /dev/null 2> /dev/null) || (echo "Please install SAMTools for this script" >&2; exit 1)
$(command -v parallel > /dev/null 2> /dev/null) || (echo "Please install GNU Parallel for this script" >&2; exit 1)

#   Some useful global variables
OUT_DEFAULT="$(pwd -P)/reheader"
declare -a VALID_PLATFORMS=('CAPILLARY' 'LS454' 'ILLUMINA' 'SOLID' 'HELICOS' 'IONTORRENT' 'ONT' 'PACBIO')

#   Usage message
function Usage() {
    echo -e "\
Usage: $0 -t|--table <table> -p|--platform <platform> -s|--sample-list <sample list> [-o|--outdirectory <outdirectory>]\n\
Where:      <table> is the sample name table (see below)\n\
            <platform> is the new sequencing platform \n\
            <sample list> is the list of BAM files \n\
            [<outdirectory>] is an optional output directory, defaults to ${OUT_DEFAULT} \n\
\n\
The sample name table is a whitespace-delimited table where the new sample name \n\
    is in the first column and the old sample names are in subsequent columns \n\
    Each row does not need to have the same number of columns as other rows \n\
    Lines starting with a '#' symbol are treated as comments and ignored \n\
\n\
Example: \n\
#This line is ignored
NewName1    OldName1    OldName2    OldName3
NewName2    NameOld1    NameOld2    NameOld3    NameOld4
#   This line is also ignored
NewName3    Old1        Old2
\n\
The sample name table MUST have a trailing newline
" >&2
    exit 1
}

#   If we don't have enough arguments, exit with usage
[[ "$#" -lt 6 ]] && Usage

#   Parse the arguments
while [[ "$#" -gt 1 ]];
do
    KEY="$1"
    case "${KEY}" in
        -t|--table) # Table of sample names
            TABLE="$2"
            shift
            ;;
        -p|--platform) # New platform (PL) value
            PLATFORM="$2"
            shift
            ;;
        -s|--sample-list) # Sample list
            SAMPLE_LIST="$2"
            shift
            ;;
        -o|--outdirectory) # Output directory
            OUTDIRECTORY="$2"
            shift
            ;;
        *) # Anything else
            Usage
            ;;
    esac
    shift
done

#   Argument checking
[[ -z "${PLATFORM}" ]] && (echo "Please specify a replacement sequencing platform") # Make sure we have a platform specified
[[ "${VALID_PLATFORMS[@]}" =~ "${PLATFORM}" ]] || (echo "Invalid platform: '${PLATFORM}'" >&2; echo "Please choose from:" >&2; for plat in "${VALID_PLATFORMS[@]}"; do echo -e "\t${plat}"; done; exit 1) # Ensure our platform is valid
[[ -z "${OUTDIRECTORY}" ]] && OUTDIRECTORY="${OUT_DEFAULT}" # Create a default outdirectory if not specified
[[ -f "${TABLE}" ]] || (echo "Cannot find ${TABLE}, exiting..."; exit 1) # Ensure our sample table exists
[[ -f "${SAMPLE_LIST}" ]] || (echo "Cannot find ${SAMPLE_LIST}, exiting..."; exit 1) # Ensure our sample list exists
for sample in $(<"${SAMPLE_LIST}"); do [[ -f "${sample}" ]] || (echo "Cannot find ${sample}, exiting..." >&2; exit 1); done # Ensure our sample files exist

#   Make our output directory
mkdir -p "${OUTDIRECTORY}"

#   Read our sample names table into an associative array
declare -A SAMPLE_NAMES # Use an associative array to match old samples with new ones
while read line # For every line in our table
do
    name=$(echo "${line}" | tr '[:space:]' ' ' | cut -f 1 -d ' ') # Get the first column of the line, this is the new sample name
    [[ "${name:0:1}" == '#' ]] && continue # If the line starts with '#', skip this line
    for sample in $(echo "${line}" | tr '[:space:]' ' ' | cut -f 2- -d ' ') # For every old sample in the rest of the line
    do
        SAMPLE_NAMES["${sample}"]="${name}" # Assign the old name to our associative array as the key, with our new name as the value
    done
done < "${TABLE}" # Read from $TABLE

#   A function to find the right BAM files
function findBAM() { # takes < 2 sec for ~ 250 BAM files 1.5-8 GB in size
    local bamfile="$1" # What BAM file are we working with?
    local oldname="$2" # What is our old sample name
    $(samtools view -H "${bamfile}" | grep "SM:${oldname}" > /dev/null 2> /dev/null) && echo "${bamfile}" # Ask if the old name is in the SM field for the @RG tag. If so, return the name of the BAM file
}

#   Export the function
export -f findBAM

#   A function to find the new lane information
function findLane() {
    local bamfile="$1" # What BAM file are we working with?
    echo $(samtools view "${bamfile}" | head -1 | cut -f 1 | rev | cut -f 4- -d ':' | rev) # Fancy cutting and stuff
    # I make some major assumptions with this, namely that the entire BAM file is one lane
    # Now it's documented here, I'll document it better later
}

#   Export the function
export -f findLane

#   A function to do the reheader stuff
function reheader() {
    local bamfile="$1" # What BAM file are we working with?
    local oldname="$2" # What is our old sample name?
    local newname="$3" # What is our new sample name?
    local platform="$4" # What is the new platform information?
    local outdirectory="$5" # Where should we put the reheaded BAM file?
    local lane="$6" # What is the new lane information?
    #   Collect some information
    local oldlane="$(samtools view -H ${bamfile} | grep '^@RG' | tr '[:space:]' '\n' | grep 'PU' | cut -f 2 -d ':')" # Old lane information
    local oldplatform="$(samtools view -H ${bamfile} | grep '^@RG' | tr '[:space:]' '\n' | grep 'PL' | cut -f 2 -d ':')" # Old platform information
    #   Create output name
    local outbam="${outdirectory}/$(basename ${bamfile} .bam)_reheader.bam"
    #   Run the damn thing
    (set -x; samtools view -H "${bamfile}" | sed -e "s/SM:${oldname}/SM:${newname}/" -e "s/PU:${oldlane}/PU:${lane}/" -e "s/PL:${oldplatform}/PL:${platform}/" | samtools reheader - "${bamfile}" > "${outbam}")
}

#   Export the function
export -f reheader

#   Master driving function
function master() { # I need a better name for this
    local bamlist="$1" # Where is our list of BAM files?
    local oldname="$2" # What is the old name we're working with?
    local newname="$3" # What is the corresponding new name?
    local platform="$4" # What is the new sequencing platform?
    local outdirectory="$5" # Where do we put the reheaded BAM files?
    #   Collect the information we need
    local -a myBAM=($(parallel findBAM {} "${oldname}" :::: "${bamlist}" 2> /dev/null)) # Get the BAM files for this old name
    local -a myLanes=($(parallel -k findLane {} ::: "${myBAM[@]}" 2> /dev/null)) # Get the new lane information for these BAM files
    #   Do reheader
    parallel --verbose --xapply "reheader {1} ${oldname} ${newname} ${platform} ${outdirectory} {2}" ::: "${myBAM[@]}" ::: "${myLanes[@]}"
}

#   Export the function
export -f master

#   Run 'master' in parallel
#       Use ${!SAMPLE_NAMES[@]} to get all the keys (old sample names) from the associative array
#       Use ${SAMPLE_NAMES[@]} to get all the values (new sample names) from the associative array
parallel --verbose --xapply "master ${SAMPLE_LIST} {1} {2} ${PLATFORM} ${OUTDIRECTORY}" ::: "${!SAMPLE_NAMES[@]}" ::: "${SAMPLE_NAMES[@]}"
