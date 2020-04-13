# Barley_Outgroups relative to Morex v2

The methods used below are for mapping the barley outgroups to Morex v2 (barley reference genome). For info on where the samples came from, see the main `README.md` file on this page https://github.com/ChaochihL/Barley_Outgroups.

---

## Dependencies

| Stage Used | Dependency | Version |
| ---------- | ---------- | ------- |
| Step 01: Aligning outgroup sequences | Stampy | 1.0.32 |

---

# Methods

As of 2019-11-25 the README.md file in this subdirectory are the steps used to generate outgroup fasta files relative to Morex v2.

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

# Look at contents
head -n 5 old_bam_murinum_names.txt
murinum_BCC2017_part00_0.03
murinum_BCC2017_part01_0.03
murinum_BCC2017_part02_0.03
murinum_BCC2017_part03_0.03
murinum_BCC2017_part04_0.03

#   Reformat into correct table format to input into fixBAMHeader.sh
#   Make sure this table has trailing new line at the end
new_name="murinum_BCC2017"
old_names=$(cat old_bam_murinum_names.txt | tr '\n' ' ')
echo ${new_name} ${old_names} > bam_murinum_reheader_table.txt

# Look at contents
cat bam_murinum_reheader_table.txt
murinum_BCC2017 murinum_BCC2017_part00_0.03 murinum_BCC2017_part01_0.03 murinum_BCC2017_part02_0.03 murinum_BCC2017_part03_0.03 murinum_BCC2017_part04_0.03 murinum_BCC2017_part05_0.03 murinum_BCC2017_part06_0.03 murinum_BCC2017_part07_0.03 murinum_BCC2017_part08_0.03 murinum_BCC2017_part09_0.03 murinum_BCC2017_part10_0.03 murinum_BCC2017_part11_0.03 murinum_BCC2017_part12_0.03 murinum_BCC2017_part13_0.03 murinum_BCC2017_part14_0.03 murinum_BCC2017_part15_0.03

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

## Infer Ancestral State with ANGSD

If you would like to infer the ancestral state and output a VCF file to use with downstream analyses, you can modify the script [`angsd_anc_inf.job`](https://github.com/ChaochihL/Barley_Outgroups/blob/master/morex_v1/angsd_anc_inf.job) but note that this script was used when processing data relative to Morex v1. Please make sure you modify this script accordingly and use the latest version of ANGSD.
