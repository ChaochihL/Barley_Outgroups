# Barley_Outgroups

Mapping Barley outgroups: H. bulbosum, H. pubiflorum, and H. murinum

## Where did these samples come from?

H. murinum sample was sequenced by Dan Koenig from UC Riverside and was downloaded from [SRA Study SRP163145, BioProject PRJNA491526](https://www.ncbi.nlm.nih.gov/sra/?term=PRJNA491526). H. bulbosum and H. pubiflorum whole exome capture samples were published in the [Mascher et al. 2013 paper](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC4241023/#__sec16title). Reads were downloaded from [SRA Study ERP002487, BioProject PRJEB1810](https://www.ncbi.nlm.nih.gov/Traces/study/?acc=ERP002487). The following samples were downloaded and renamed:

| Run       | Sample Name (Published/Downloaded)   | Renamed Sample Prefix | Sequencing Strategy |
| --------- | ------------------------------------ | --------------------- | ------------------- |
| ERR271731 | BEC_H. Pubiflorum BCC2028            | pubiflorum_BCC2028    | WXS |
| ERR271732 | BEC_H. Bulbosum ?                    | bulbosum01            | WXS |
| ERR271733 | BEC_H. Bulbosum ??                   | bulbosum02            | WXS |
| ERR271734 | BEC_H. Bulbosum A12                  | bulbosum_A12          | WXS |
| ERR271811 | WGS_H. bulbosum1                     | bulbosum_wgs          | WGS |
| SRR7956029 | Hordeum murinum subsp. glaucum BCC2017 | murinum_BCC2017       | WGS |

## Step 00: Downloading samples and data preparation

Use a list of FTP links (stored in `sra_ftp_links.txt`) to download the samples. Since a few are stored in NCBI SRA and others are stored in the [European Nucleotide Archive](https://www.ebi.ac.uk/ena) and the base urls differ, we couldn't use Tom's `SRA_Fetch.sh` script without modifying it multiple times.

Submitted SRA download as a job on an HPC system:

```bash
qsub sra_download.sh
```

The `sra_download.sh` script outputs SRA files that then need to be split into forward and reverse fastq files with the following:

```bash
qsub sra_to_fastq.sh
```

Now, let's rename the downloaded FASTQ files to more meaningful names.

```bash
# Before renaming in directory containing fastq files
ls
ERR271731_1.fastq.gz  ERR271732_1.fastq.gz  ERR271733_1.fastq.gz  ERR271734_1.fastq.gz  ERR271811_1.fastq.gz  SRR7956029_1.fastq.gz
ERR271731_2.fastq.gz  ERR271732_2.fastq.gz  ERR271733_2.fastq.gz  ERR271734_2.fastq.gz  ERR271811_2.fastq.gz  SRR7956029_2.fastq.gz

# In dir: ~/GitHub/Barley_Outgroups/00_data_preperation
# Dry-run of renaming as a check before the actual renaming
./rename_sra_fastq.py sra_lookup_ids_outgroups_list.txt /scratch.global/liux1299/sra_outgroups/fastq --dry-run
Dry-run, print old name and new name. Please run with --rename option to do the actual renaming.
Old_Name	 New_Name
ERR271731_1.fastq.gz pubiflorum_BCC2028_1.fastq.gz
ERR271731_2.fastq.gz pubiflorum_BCC2028_2.fastq.gz
ERR271732_1.fastq.gz bulbosum01_1.fastq.gz
ERR271732_2.fastq.gz bulbosum01_2.fastq.gz
ERR271733_1.fastq.gz bulbosum02_1.fastq.gz
ERR271733_2.fastq.gz bulbosum02_2.fastq.gz
ERR271734_1.fastq.gz bulbosum_A12_1.fastq.gz
ERR271734_2.fastq.gz bulbosum_A12_2.fastq.gz
ERR271811_1.fastq.gz bulbosum_wgs_1.fastq.gz
ERR271811_2.fastq.gz bulbosum_wgs_2.fastq.gz
SRR7956029_1.fastq.gz murinum_BCC2017_1.fastq.gz
SRR7956029_2.fastq.gz murinum_BCC2017_2.fastq.gz

# Do the actual renaming
./rename_sra_fastq.py sra_lookup_ids_outgroups_list.txt /scratch.global/liux1299/sra_outgroups/fastq --rename
Renaming files...

# After renaming in directory containing fastq files
ls
bulbosum01_1.fastq.gz  bulbosum02_1.fastq.gz  bulbosum_A12_1.fastq.gz  bulbosum_wgs_1.fastq.gz  murinum_BCC2017_1.fastq.gz  pubiflorum_BCC2028_1.fastq.gz
bulbosum01_2.fastq.gz  bulbosum02_2.fastq.gz  bulbosum_A12_2.fastq.gz  bulbosum_wgs_2.fastq.gz  murinum_BCC2017_2.fastq.gz  pubiflorum_BCC2028_2.fastq.gz
```

**Quality Assessment and Adapter Trimming:**

Before we start aligning the outgroup sequences, we will perform some quality control and adapter trimming to remove non-biological sequence. We will be using [`sequence_handling`](https://github.com/MorrellLAB/sequence_handling) for these steps with the config file located in the directory `00_data_preparation`.

```bash
# In dir: ~/sequence_handling
# Quality Assessment on raw samples
./sequence_handling Quality_Assessment /home/morrellp/liux1299/GitHub/Barley_Outgroups/00_data_preperation/outgroups_config

# Adapter Trimming
./sequence_handling Adapter_Trimming /panfs/roc/groups/9/morrellp/liux1299/GitHub/Barley_Outgroups/00_data_preperation/outgroups_config

# Quality Assessment on trimmed samples
./sequence_handling Quality_Assessment /panfs/roc/groups/9/morrellp/liux1299/GitHub/Barley_Outgroups/00_data_preperation/outgroups_config
```

## Step 01: Aligning outgroup sequences

| Dependencies | Version |
| ------------ | ------- |
| Stampy | 1.0.32 |

Since H murinum sample was too large to process, we split the trimmed FASTQ file for both forward and reverse reads prior to mapping with stampy.

```bash
# In dir: ~/GitHub/Barley_Outgroups/morex_v2/01_mapping
qsub split_forward_murinum.job
qsub split_reverse_murinum.job
```

Murinum was split into 16 parts. Next, we need to prepare the reference for stampy by building a genome (`.stidx`) file.

```bash
# In dir: ~/GitHub/Barley_Outgroups/morex_v2/01_mapping
qsub stampy_build_genome.sh
```

We will proceed by aligning with stampy v1.0.32 and use the following commands to submit scripts as job arrays:

```bash
#   Murinum
#   In dir: /home/morrellp/liux1299/GitHub/Barley_Outgroups/morex_v2/01_mapping/stampy_mapped
#   Map with 3% divergence
#   What is the maximum number of Torque tasks (# in array)
#   Note: array is 0 indexed
SINGLE_ARRAY_LIMIT=15
qsub -t 0-"${SINGLE_ARRAY_LIMIT}" stampy-murinum-0.03.sh

#   Map with 9% divergence
#   What is the maximum number of Torque tasks (# in array)
#   Note: array is 0 indexed
SINGLE_ARRAY_LIMIT=15
qsub -t 0-"${SINGLE_ARRAY_LIMIT}" stampy-murinum-0.09.sh

#   Pubiflorum
qsub stampy-pubiflorum-0.05.sh
qsub stampy-pubiflorum-0.09.sh
qsub stampy-pubiflorum-0.11.sh

#   Bulbosum A12
qsub stampy-bulbosum_A12-0.03.sh
qsub stampy-bulbosum_A12-0.05.sh
```

#### SAM Processing

Using `sequence_handling` we will convert the mapped samples to BAM, mark duplicates, and sort BAM.

```bash
# Murinum

# Bulbosum A12 and Pubiflorum
./sequence_handling SAM_Processing /panfs/roc/groups/9/morrellp/liux1299/GitHub/Barley_Outgroups/morex_v2/01_mapping/bulbosum_and_pubiflorum_parts_ref_config

# Murinum split into parts
./sequence_handling SAM_Processing /panfs/roc/groups/9/morrellp/liux1299/GitHub/Barley_Outgroups/morex_v2/01_mapping/murinum_parts_ref_config
```

#### Murinum reheader and merge bam

```bash
# Extract old names from BAM files split into parts
for i in $(ls murinum_BCC2017*.bam)
do
    samtools view -H ${i} | grep "@RG" | cut -f 2 | sed -e 's/ID://g' >> old_bam_murinum_names.txt
done

#   Reformat into correct table format to input into fixBAMHeader.sh
#   Make sure this table has trailing new line at the end
new_name="murinum_BCC2017"
old_names=$(cat old_bam_murinum_names.txt | tr '\n' ' ')
echo ${new_name} ${old_names} > bam_murinum_reheader_table.txt

#   Submitted job script as job on MSI
qsub fix_bam_header.job
```

Merge murinum parts into a single BAM file:

```bash
qsub merge_bam.sh
```

## Step 02: Indel realignment

H. bulbosum and H. pubiflorum:

```bash
# Bulbosum A12 and pubiflorum
# RTC
./sequence_handling Realigner_Target_Creator /panfs/roc/groups/9/morrellp/liux1299/GitHub/Barley_Outgroups/morex_v2/02_realignment/Config_Indel_Realign-b_and_p

# Indel realignment
./sequence_handling Indel_Realigner /panfs/roc/groups/9/morrellp/liux1299/GitHub/Barley_Outgroups/morex_v2/02_realignment/Config_Indel_Realign-b_and_p
```

H. murinum:

```bash
# RTC
./sequence_handling Realigner_Target_Creator /panfs/roc/groups/9/morrellp/liux1299/GitHub/Barley_Outgroups/morex_v2/02_realignment/Config_Indel_Realign-murinum

# Indel realignment
./sequence_handling Indel_Realigner /panfs/roc/groups/9/morrellp/liux1299/GitHub/Barley_Outgroups/morex_v2/02_realignment/Config_Indel_Realign-murinum
```

## Step 03: Bam to fasta

```bash
# In dir: ~/GitHub/Barley_Outgroups/morex_v2/03_Bam_to_Fasta
# Bulbosum A12 and pubiflorum
# Submitted as PBS task array
qsub -t 1-2 bam_to_fasta-bp.sh

# Murinum
qsub -t 1 bam_to_fasta-murinum.sh
```

---

## Where are the output files located?

Filepaths last updated: October 11, 2017

H. pubiflorum Realigned BAM and FASTA Directory:

`/panfs/roc/groups/9/morrellp/shared/Datasets/NGS/Outgroups/H_pubiflorum`

H. bulbosum Realigned BAM and FASTA Directory:

`/panfs/roc/groups/9/morrellp/shared/Datasets/NGS/Outgroups/H_bulbosum`

H. murinum Realigned BAM and FASTQ Directory:

`/panfs/roc/groups/9/morrellp/shared/Datasets/NGS/Outgroups/H_murinum`

## Methods

Barley has had multiple releases of the barley reference genome, called Morex. This repository contains scripts and detailed methods (in the README files) to map the three barley outgroups to the reference genome. It is organized as follows:

**Morex v1:** All scripts are in a directory called `morex_v1`. Detailed methods are located in the README file within `morex_v1`: https://github.com/ChaochihL/Barley_Outgroups/tree/master/morex_v1.

**Morex v2:** All scripts are in a directory called `morex_v2`. Detailed methods are located in the README file within `morex_v2`: https://github.com/ChaochihL/Barley_Outgroups/tree/master/morex_v2.

