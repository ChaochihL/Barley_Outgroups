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

### Stampy

#### Bulbosum and Pubiflorum Mapping and SAM Processing

Samples were trimmed by Paul using `sequence_handling` Adapter_Trimming and `/home/morrellp/liux1299/Shared/References/Adapters/MascherAdapters.fasta` adapters. Next, I used [Stampy 1.0.31](http://www.well.ox.ac.uk/project-stampy) to map the samples to `barley_pseudomolecules_parts.fa` reference. I mapped pubiflorum with Stampy using 9%, 10%, and 11% divergence rates and got SAM files. Then I used `sequence_handling` SAM_Processing to get finished BAM files and BAM stats.  Based on the statistics reported, there is no difference seen when using the 3 different divergence rates for the pubiflorum sample.

I mapped bulbosum_A12 with Stampy using 3%, 4%, and 5% divergence rates. After processing the SAM files with `sequence_handling`, I got BAM file statistics. The statistics showed differences with the different divergence rates:
- 3% divergence: 98.09% mapped, 78.80% properly paired, and 0.66% singletons
- 4% divergence: 98.07% mapped, 78.40% properly paired, and 0.67% singletons
- 5% divergence: 98.04% mapped, 78.21% properly paired, and 0.69% singletons

#### Murinum Mapping and SAM Processing

For H murinum sample, initially tried adapter trimming using recommended adapters for NextSeq platform but the FastQC results indicated the following overrepresented sequences for the trimmed sample: `GATCGGAAGAGCACACGTCTGAACTCCAGTCACATCACGATCTCGTATGC`. The possible source for this overrepresented sequence was suggested to be from TruSeq Adapter, Index 1. So, I re-ran adapter trimming using the following adapter sequences: `/home/morrellp/liux1299/Shared/References/Adapters/novogene_truseq_adapters.fa` because the overrepresented sequence was in this adapters file and this adapters list is shorter than `/home/morrellp/liux1299/Shared/References/Adapters/adapter_from_Shichen_Wang.fa` meaning it is less resource intensive. The command used to check this is:

```bash
grep "GATCGGAAGAGCACACGTCTGAACTCCAGTCACATCACGATCTCGTATGC" *
```

Since H murinum sample was too large, the trimmed fastq file for both forward and reverse reads were split into 16 files using the `split_forward.job` and `split_reverse.job` scripts. Then used the following commands to submit `stampy-murinum-0.11.sh` script as job array:

```bash
#   Map with 11% divergence
#   What is the maximum number of Torque tasks (# in array)
#   Note: array is 0 indexed
SINGLE_ARRAY_LIMIT=15
#   Submit job
echo "source /panfs/roc/groups/9/morrellp/liux1299/GitHub/Barley_Outgroups/stampy_mapped/stampy-murinum-0.11.sh && /panfs/roc/groups/9/morrellp/liux1299/GitHub/Barley_Outgroups/stampy_mapped/stampy-murinum-0.11.sh" | qsub -t 0-"${SINGLE_ARRAY_LIMIT}" -q mesabi -l mem=62gb,nodes=1:ppn=24,walltime=96:00:00 -m abe -M liux1299@umn.edu

#   Map with 9% divergence
#   What is the maximum number of Torque tasks (# in array)
#   Note: array is 0 indexed
SINGLE_ARRAY_LIMIT=15
echo "source /panfs/roc/groups/9/morrellp/liux1299/GitHub/Barley_Outgroups/stampy_mapped/stampy-murinum-0.09.sh && /panfs/roc/groups/9/morrellp/liux1299/GitHub/Barley_Outgroups/stampy_mapped/stampy-murinum-0.09.sh" | qsub -t 0-"${SINGLE_ARRAY_LIMIT}" -q mesabi -l mem=62gb,nodes=1:ppn=24,walltime=72:00:00 -m abe -M liux1299@umn.edu
```

After mapping all H murinum parts (file was split into 16 parts) with Stampy using 11% divergence rates, processing SAM files with `sequence_handling`, and getting finished BAM statistics, the statistics showed ~80% mapped, ~25% properly paired, and ~2% singletons. To try and improve mapping, I mapped all H murinum parts using 9% divergence rates and picked one set of reads (part01) to test 5%, 7.5%, and 10% divergence rates. The logic for using 9% divergence rate for all the parts was based on Li downloading ITS sequences of H murinum subsp. leporinum, H murinum subsp. murinum, and H vulgare subsp vulgare and aligning the the two murinum subspecies to vulgare in Geneious. Li then counted the number of base pairs that differed in the alignments.
- For H murinum subsp leporinum aligned to H vulgare subsp. vulgare: 57 different bps out of 606
   - Divergence calculated by: 57/606 = 9.4%
- For H murinum subsp murinum aligned to H vulgare subsp. vulgare: 59 different bps out of 602
   - Divergence calculated by: 59/602 = 9.8%

### GATK Indel Realignment - Bulbosum, Pubiflorum, Murinum

We will proceed by realigning pubiflorum mapped with 9% divergence rate but also test pubiflorum mapped with 5%, 7%, and 8% divergence rates to report in the manuscript. We realigned bulbosum_A12 mapped with 3% divergence rate.

### BAM to FASTA - Bulbosum, Pubiflorum, Murinum

[ANGSD-wrapper](https://github.com/mojaveazure/angsd-wrapper) was used to extract FASTA sequence from realigned BAM files. FASTA sequence was extracted using `DO_FASTA=3`, which uses the base with the highest effective depth, and `DO_COUNTS=1`, which counts allele frequencies.
