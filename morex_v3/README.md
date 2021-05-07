# Barley Outgroups relative to Morex v3

The methods used below are for mapping the barley outgroups to Morex v3 (barley reference genome). For info on where the samples came from, see the main `README.md` file on this page https://github.com/ChaochihL/Barley_Outgroups.

---

# Methods

As of 2021-03-11 the README.md file in this subdirectory are the steps used to generate outgroup fasta files relative to Morex v3.

We will use already trimmed fastq files from previous processing. Please see [Morex_v2 README Step 00: Downloading samples and data preparation](https://github.com/ChaochihL/Barley_Outgroups/tree/master/morex_v2) for specfics on how we chose these sequences to use and how they were adapter trimmed.

## Step 01: Aligning outgroup sequences

| Dependencies | Version |
| ------------ | ------- |
| Stampy | 1.0.32 |

The H murinum sample was too large to process, so we will use the previously split trimmed FASTQ files. lease see [Morex_v2 README Step 00: Downloading samples and data preparation](https://github.com/ChaochihL/Barley_Outgroups/tree/master/morex_v2) for specfics.


Build stampy reference genome files.

```bash
sbatch stampy_build_genome.sh
```

Align bulbosum_A12.

```bash
# In dir: ~/GitHub/Barley_Outgroups/morex_v3/01_mapping
sbatch stampy-bulbosum_A12-0.03.sh
```

Align pubiflorum.

```bash
sbatch stampy-pubiflorum-0.05.sh
```

Align murinum split into parts.

```bash
# First pass, request 90 hours walltime
sbatch --array=0-31 stampy-murinum-0.03.sh
# A handful finished, others need increased walltime
# Increase walltime to 180 hours for timeout array indices
sbatch --array=0,2-3,5-18,20,22-30 stampy-murinum-0.03.sh
```

#### SAM Processing

Using `sequence_handling` convert the mapped samples to BAM, mark duplicates, and sort BAM.

```bash
# In dir: ~/sequence_handling
# SAM_Processing for bulbosum A12 and pubiflorum
./sequence_handling SAM_Processing ~/GitHub/Barley_Outgroups/morex_v3/01_mapping/Config_bulbosum_and_pubiflorum
```

## Step 02: Indel realignment

H. bulbosum and H. pubiflorum:

```bash
# In dir: ~/sequence_handling
# Bulbosum A12 and pubiflorum
# RTC
./sequence_handling Realigner_Target_Creator ~/GitHub/Barley_Outgroups/morex_v3/02_realignment/Config_Indel_Realign_bp
# Indel Realigner
./sequence_handling Indel_Realigner ~/GitHub/Barley_Outgroups/morex_v3/02_realignment/Config_Indel_Realign_bp
```

## Step 03: Bam to fasta

```bash
# In dir: ~/GitHub/Barley_Outgroups/morex_v3/03_Bam_to_Fasta
sbatch --array=0-1 bam_to_fasta-bp.sh
```
