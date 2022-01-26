# Barley_Outgroups

Mapping Barley outgroups: H. bulbosum, H. pubiflorum, and H. murinum

These outputs get shared across multiple barley projects.

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

---

## Where are the output files located?

Filepaths last updated: Jan 26, 2022

Morex_v3 H. pubiflorum, H. bulbosum, and H. murinum FASTA files are in: `/panfs/roc/groups/9/morrellp/shared/Datasets/Outgroups/morex_v3_outgroups_partsRef`. To save storage space, realigned BAM files for these three outgroups are backed up on Chaochih's S3 account.

Morex_v2 H. pubiflorum, H. bulbosum, and H. murinum FASTA files are in: `/panfs/roc/groups/9/morrellp/shared/Datasets/Outgroups/morex_v2_outgroups`. To save storage space, realigned BAM files for these three outgroups are backed up on Chaochih's S3 account.

Morex_v1 H. pubiflorum, H. bulbosum, and H. murinum FASTA and realigned BAM files are in: `/panfs/roc/groups/9/morrellp/shared/Datasets/Outgroups/morex_v1_outgroups`.

---

## Methods

Barley has had multiple releases of the barley reference genome, called Morex. This repository contains scripts and detailed methods (in the README files) to map the three barley outgroups to the reference genome. It is organized as follows:

**Morex v3:** All scripts are in a directory called `morex_v3`. Detailed methods are located in the README file within `morex_v3`: https://github.com/ChaochihL/Barley_Outgroups/tree/master/morex_v3

**Morex v2:** All scripts are in a directory called `morex_v2`. Detailed methods are located in the README file within `morex_v2`: https://github.com/ChaochihL/Barley_Outgroups/tree/master/morex_v2.

**Morex v1:** All scripts are in a directory called `morex_v1`. Detailed methods are located in the README file within `morex_v1`: https://github.com/ChaochihL/Barley_Outgroups/tree/master/morex_v1.
