# Barley_Outgroups

Mapping Barley outgroups: H. bulbosum, H. pubiflorum, and H. murinum

---

## Where did these samples come from?

H. murinum sample was sequenced by Dan Koenig from UC Riverside and were downloaded via this link: http://biocluster.ucr.edu/~dkoenig/Hm_RESEQ/. H. bulbosum and H. pubiflorum whole exome capture samples were published in the [Mascher et al. 2013 paper](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC4241023/#__sec16title). Reads were downloaded from [SRA Study ERP002487, BioProject PRJEB1810](https://www.ncbi.nlm.nih.gov/Traces/study/?acc=ERP002487). The following samples were downloaded and renamed:

| Run       | Sample Name (Published/Downloaded)   | Renamed Sample Prefix |
| --------- | ------------------------------------ | --------------------- |
| ERR271731 | BEC_H. Pubiflorum BCC2028            | pubiflorum_BCC2028    |
| ERR271732 | BEC_H. Bulbosum ?                    | bulbosum01            |
| ERR271733 | BEC_H. Bulbosum ??                   | bulbosum02            |
| ERR271734 | BEC_H. Bulbosum A12                  | bulbosum_A12          |
| N/A       | AG_1a_S1_R1_001                      | murinum_R1            |
| N/A       | AG_1a_S1_R2_001                      | murinum_R2            |

---

## Where are the output files located?

Filepaths last updated: October 11, 2017

H. pubiflorum Realigned BAM and FASTA Directory:

`/panfs/roc/groups/9/morrellp/shared/Datasets/NGS/Outgroups/H_pubiflorum`

H. bulbosum Realigned BAM and FASTA Directory:

`/panfs/roc/groups/9/morrellp/shared/Datasets/NGS/Outgroups/H_bulbosum`

H. murinum Realigned BAM and FASTQ Directory:

`/panfs/roc/groups/9/morrellp/shared/Datasets/NGS/Outgroups/H_murinum`

---

## Methods

#### Stampy

Samples were trimmed by Paul using `sequence_handling` Adapter_Trimming and `/home/morrellp/liux1299/Shared/References/Adapters/MascherAdapters.fasta` adapters. Next, I used [Stampy 1.0.31](http://www.well.ox.ac.uk/project-stampy) to map the samples to `barley_pseudomolecules_parts.fa` reference. I mapped pubiflorum with Stampy using 9%, 10%, and 11% divergence rates and got SAM files. Then I used `sequence_handling` SAM_Processing to get finished BAM files and BAM stats.  Based on the statistics reported, there is no difference seen when using the 3 different divergence rates for the pubiflorum sample.

I mapped bulbosum_A12 with Stampy using 3%, 4%, and 5% divergence rates. After processing the SAM files with `sequence_handling`, I got BAM file statistics. The statistics showed differences with the different divergence rates:
- 3% divergence: 98.09% mapped, 78.80% properly paired, and 0.66% singletons
- 4% divergence: 98.07% mapped, 78.40% properly paired, and 0.67% singletons
- 5% divergence: 98.04% mapped, 78.21% properly paired, and 0.69% singletons

#### GATK Indel Realignment

We will proceed by realigning pubiflorum mapped with 9% divergence rate but also test pubiflorum mapped with 5%, 7%, and 8% divergence rates to report in the manuscript. We realigned bulbosum_A12 mapped with 3% divergence rate.

#### BAM to FASTA

[ANGSD-wrapper](https://github.com/mojaveazure/angsd-wrapper) was used to extract FASTA sequence from realigned BAM files. FASTA sequence was extracted using `DO_FASTA=3`, which uses the base with the highest effective depth, and `DO_COUNTS=1`, which counts allele frequencies.
