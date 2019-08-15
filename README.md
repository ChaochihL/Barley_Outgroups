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

