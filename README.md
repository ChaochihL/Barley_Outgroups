# Barley_Outgroups
Mapping Barley outgroups: H. bulbosum and H. pubiflorum

---

## Where did these samples come from?

H. bulbosum and H. pubiflorum samples were published in the [Mascher et al. 2013 paper](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC4241023/#__sec16title). Reads were downloaded from [SRA Study ERP002487, BioProject PRJEB1810](https://www.ncbi.nlm.nih.gov/Traces/study/?acc=ERP002487). The following samples were downloaded and renamed:

| Run       | Sample Name (Published)   | Renamed Sample Prefix |
| --------- | ------------------------- | --------------------- |
| ERR271731 | BEC_H. Pubiflorum BCC2028 | pubiflorum_BCC2028    |
| ERR271732 | BEC_H. Bulbosum ?         | bulbosum01            |
| ERR271733 | BEC_H. Bulbosum ??        | bulbosum02            |
| ERR271734 | BEC_H. Bulbosum A12       | bulbosum_A12          |

---

## Where are the output files located?

Filepaths last updated: May 19, 2017

H. pubiflorum Realigned BAM and FASTA Directory:

`/home/morrellp/liux1299/Shared/Datasets/NGS/Alignments/Outgroup_Sequences/outgroup_partsRef/H_pubiflorum`

---

## Methods

#### Stampy

Samples were trimmed by Paul using `sequence_handling` Adapter_Trimming and `/home/morrellp/liux1299/Shared/References/Adapters/MascherAdapters.fasta` adapters. Next, I used [Stampy 1.0.31](http://www.well.ox.ac.uk/project-stampy) to map the samples. I mapped pubiflorum with Stampy using 9%, 10%, and 11% divergence rates and got SAM files. Then I used `sequence_handling` SAM_Processing to get finished BAM files and BAM stats.  Based on the statistics reported, there is no difference seen when using the 3 different divergence rates.

#### GATK Indel Realignment

We will proceed by realigning pubiflorum mapped with 9% divergence rate but also test pubiflorum mapped with 5%, 7%, and 8% divergence rates to report in the manuscript.

#### BAM to FASTA

[ANGSD-wrapper](https://github.com/mojaveazure/angsd-wrapper) was used to extract FASTA sequence from realigned BAM files. FASTA sequence was extracted using `DO_FASTA=3`, which uses the base with the highest effective depth, and `DO_COUNTS=1`, which counts allele frequencies.
