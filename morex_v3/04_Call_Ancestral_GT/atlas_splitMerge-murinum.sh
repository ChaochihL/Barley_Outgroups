#!/bin/bash
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=8
#SBATCH --mem=56gb
#SBATCH --tmp=50gb
#SBATCH -t 90:00:00
#SBATCH --mail-type=ALL
#SBATCH --mail-user=liux1299@umn.edu
#SBATCH -p small,ram256g,ram1t
#SBATCH -o %A_%a.out
#SBATCH -e %A_%a.err

set -e
set -o pipefail

# Step 1 in the standard pipeline from ATLAS:
#   https://bitbucket.org/wegmannlab/atlas/wiki/Home
# Submit as job arrays to Slurm

# Dependencies
module load atlas_ML/0.9

# User provided input arguments
# List of split BAM files
BAM_LIST="/scratch.global/liux1299/barley_outgroups_morex_v3_2021-03-22/realigned_split_murinum/split_murinum_list.txt"
RG_SETTINGS="/scratch.global/liux1299/barley_outgroups_morex_v3_2021-03-22/realigned_split_murinum/read_group_settings.txt"

#--------------------
# Store list of BAM files in array
BAM_ARR=($(cat ${BAM_LIST}))
# Determine maximum array limit
MAX_ARRAY_LIMIT=$[${#BAM_ARR[@]} - 1]
echo "Maximum array limit is ${MAX_ARRAY_LIMIT}."

# Get the current BAM file we are processing
CURR_BAM=${BAM_ARR[${SLURM_ARRAY_TASK_ID}]}
echo "Current BAM we are processing: ${CURR_BAM}"

function atlas_split_merge() {
    local bam_file="$1"
    local rg_settings="$2"
    # Outputs in the same directory as the BAM file
    atlas task=splitMerge bam="${bam_file}" readGroupSettings="${rg_settings}"
}

export -f atlas_split_merge

# Run atlas on current BAM file we are processing
atlas_split_merge ${CURR_BAM} ${RG_SETTINGS}
