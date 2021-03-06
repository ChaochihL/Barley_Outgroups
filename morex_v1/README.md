# Barley_Outgroups relative to Morex v1

The methods used below are for mapping the barley outgroups to Morex v1 (barley reference genome).

---

## Methods

### Stampy

#### Bulbosum and Pubiflorum Mapping and SAM Processing

Samples were quality assessed and trimmed by Paul using `sequence_handling` Adapter_Trimming and `/home/morrellp/liux1299/Shared/References/Adapters/MascherAdapters.fasta` adapters. Next, I used [Stampy 1.0.31](http://www.well.ox.ac.uk/project-stampy) to map the samples to `barley_pseudomolecules_parts.fa` reference. Scripts for Stampy mapping are located in the `stampy_mapped` directory. I mapped pubiflorum with Stampy using 9%, 10%, and 11% divergence rates and got SAM files. Then I used `sequence_handling` SAM_Processing to get finished BAM files and BAM stats. Based on the statistics reported, there is no difference seen when using the 3 different divergence rates for the pubiflorum sample.

I mapped bulbosum_A12 with Stampy using 3%, 4%, and 5% divergence rates. After processing the SAM files with `sequence_handling`, I got BAM file statistics. The statistics showed differences with the different divergence rates:
- 3% divergence: 98.09% mapped, 78.80% properly paired, and 0.66% singletons
- 4% divergence: 98.07% mapped, 78.40% properly paired, and 0.67% singletons
- 5% divergence: 98.04% mapped, 78.21% properly paired, and 0.69% singletons

**Note:** All `sequence_handling` config files are located in the `seq_handling_configs` directory.

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

#   Map with 3% divergence
#   What is the maximum number of Torque tasks (# in array)
#   Note: array is 0 indexed
SINGLE_ARRAY_LIMIT=15
echo "source /panfs/roc/groups/9/morrellp/liux1299/GitHub/Barley_Outgroups/stampy_mapped/stampy-murinum-0.03.sh && /panfs/roc/groups/9/morrellp/liux1299/GitHub/Barley_Outgroups/stampy_mapped/stampy-murinum-0.03.sh" | qsub -t 0-"${SINGLE_ARRAY_LIMIT}" -q mesabi -l mem=62gb,nodes=1:ppn=24,walltime=72:00:00 -m abe -M liux1299@umn.edu
```

After mapping all H murinum parts (file was split into 16 parts) with Stampy using 11% divergence rates, processing SAM files with `sequence_handling`, and getting finished BAM statistics, the statistics showed ~80% mapped, ~25% properly paired, and ~2% singletons. To try and improve mapping, I mapped all H murinum parts using 9% divergence rates and picked one set of reads (part01) to test 3%, 5%, and 7.5% divergence rates. The original logic for trying 9% divergence rate for all the parts was based on Li downloading ITS sequences of H murinum subsp. leporinum, H murinum subsp. murinum, and H vulgare subsp vulgare and aligning the the two murinum subspecies to vulgare in Geneious. Li then counted the number of base pairs that differed in the alignments.
- For H murinum subsp leporinum aligned to H vulgare subsp. vulgare: 57 different bps out of 606
   - Divergence calculated by: 57/606 = 9.4%
- For H murinum subsp murinum aligned to H vulgare subsp. vulgare: 59 different bps out of 602
   - Divergence calculated by: 59/602 = 9.8%

3% divergence rate mapped the best for the murinum parts with between 76%-83% of reads mapped and 20%-26% of reads were properly paired. There were 1.6%-4.6% singletons across the parts.

Prior to indel realignment, the murinum parts headers were fixed for the finished BAM files using Li's [`fixBAMHeader.sh` script](https://github.com/lilei1/Utilites/blob/master/script/fixBAMHeader.sh). The table of new and old sample names required by the `fixBAMHeader.sh` script was created as follows:

```bash
#   Extract old names from merged bam file
samtools view -H murinum_0.03.bam | grep "@RG" | cut -f 2 | sed 's/ID://g' > merged_bam_sample_names.txt
#   Reformat into correct table format to input into fixBAMHeader.sh
#   Make sure this table has trailing new line at the end
new_name="murinum "
old_names=$(cat merged_bam_sample_names.txt | tr '\n' ' ')
echo $new_name $old_names > bam_reheader_table.txt

#   Submitted job script as job on MSI
qsub fix_bam_header.job
```

Next the reheader BAM files were merged into a single BAM file using the `merge_bam.sh` script.

### GATK Indel Realignment - Bulbosum, Pubiflorum, Murinum

We will proceed by realigning pubiflorum mapped with 9% divergence rate but also test pubiflorum mapped with 5%, 7%, and 8% divergence rates to report in the manuscript. We realigned bulbosum_A12 mapped with 3% divergence rate and realigned murinum with 3% divergence rate.

### Coverage Summary

Used `sequence_handling` to calculated coverage summary statistics for H murinum realigned bam file.

### BAM to FASTA - Bulbosum, Pubiflorum, Murinum

[ANGSD-wrapper](https://github.com/mojaveazure/angsd-wrapper) was used to extract FASTA sequence from realigned BAM files. Config files used for this step are located in the `Bam_to_Fasta` directory. Scripts used to run ANGSD-wrapper commands as a job are also in the same directory. FASTA sequence was extracted using `DO_FASTA=3`, which uses the base with the highest effective depth, and `DO_COUNTS=1`, which counts allele frequencies.

### Ancestral state inference

Used `angsd_anc_inf.job` script to infer ancestral state with ANGSD.
