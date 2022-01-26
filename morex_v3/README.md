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
#sbatch --array=15-18,20,22-30 stampy-murinum-0.03.sh
```

#### SAM Processing

Using `sequence_handling` convert the mapped samples to BAM, mark duplicates, and sort BAM.

```bash
# In dir: ~/sequence_handling
# SAM_Processing for bulbosum A12 and pubiflorum
./sequence_handling SAM_Processing ~/GitHub/Barley_Outgroups/morex_v3/01_mapping/Config_bulbosum_and_pubiflorum
# murinum
./sequence_handling SAM_Processing ~/GitHub/Barley_Outgroups/morex_v3/01_mapping/Config_murinum
```

After mapping all H murinum parts (file was split into 32 parts) with Stampy, processing SAM files with `sequence_handling`, and getting finished BAM statistics, the statistics showed between 64.8% - 84% mapped (with 28 out of 32 parts having >82% mapped), 16.36% - 28.79% properly paired, and 1.73% - 8.87% singletons. Previously (Morex v1 and v2), 3% divergence rate had the highest percent mapped (~80%), so we picked 3% divergence rate here for Morex v3. We did not try other divergence rates because each part took much longer to align than previous reference versions, each part took about 4 days to align. In previous reference versions, we also found minimal differences in percent mapped for 3%, 5%, 9%, and 11% divergence rates. So, given that most of the split parts had >82% mapped, we will move forward with the current divergence rate.

#### Murinum reheader and merge bam

```bash
# In dir: ~/scratch/barley_outgroups/SAM_Processing/Picard
# Extract old names from BAM files split into parts
module load samtools/1.9
for i in $(ls murinum_BCC2017_part*.bam | sort -V)
do
    samtools view -H ${i} | grep "@RG" | cut -f 2 | sed -e 's/ID://g' >> old_bam_murinum_names.txt
done

# Reformat into correct table format to input into fixBAMHeader.sh
# Make sure this table has trailing new line at the end
new_name="murinum_BCC2017"
old_names=$(cat old_bam_murinum_names.txt | tr '\n' ' ')
echo ${new_name} ${old_names} > bam_murinum_reheader_table.txt

# Look at contents
cat bam_murinum_reheader_table.txt

# Fix BAM headers by submitting script on MSI
# In dir: ~/GitHub/Barley_Outgroups/morex_v3/01_mapping
sbatch fix_bam_header.job
```

Merge murinum parts into a single BAM file:

```bash
# In dir: ~/GitHub/Barley_Outgroups/morex_v3/01_mapping
sbatch merge_bam.sh
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

# murinum
# RTC
./sequence_handling Realigner_Target_Creator ~/GitHub/Barley_Outgroups/morex_v3/02_realignment/Config_Indel_Realign_murinum
# Indel Realigner
./sequence_handling Indel_Realigner ~/GitHub/Barley_Outgroups/morex_v3/02_realignment/Config_Indel_Realign_murinum
```

## Step 03: Bam to fasta

```bash
# In dir: ~/GitHub/Barley_Outgroups/morex_v3/03_Bam_to_Fasta
# Bulbosum and pubiflorum
sbatch --array=0-1 bam_to_fasta-bp.sh

# Murinum
sbatch --array=0 bam_to_fasta-murinum.sh
```

## Call ancestral genotypes with ATLAS / Infer ancestral allele with ANGSD

The method you choose depends on if you need the ancestral genotypes called (use ATLAS) or just the ancestral allele inferred (ANGSD). For both methods, it is recommended to do some form of realignment around indels.

#### Call ancestral genotypes with ATLAS

If your software requires ancestral genotypes to be called (same format as individual genotypes in a VCF file), you can use ATLAS (https://bitbucket.org/wegmannlab/atlas/wiki/Home). Here are some relevant papers:

- ATLAS software manuscript: Link et al. 2017 bioRxiv. ATLAS: Analysis Tools for Low-depth and Ancient Samples. https://doi.org/10.1101/105346
- Comparison of GATK vs ATLAS performance when calling genotypes at the phylogenetic level: Duchen and Salamin 2021 Systematic Biology. A Cautionary Note on the Use of Genotype Callers in Phylogenomics. https://doi.org/10.1093/sysbio/syaa081

We'll use ATLAS, but because of its long runtimes and memory requirements for large genomes, we'll first split our realigned H. murinum BAM file by chromosome parts.

```bash
# In dir: ~/GitHub/Barley_Outgroups/morex_v3/04_Call_Ancestral_GT
sbatch split_bam_by_chr.sh
```

Next, we'll follow [ATLAS's recommended pipeline](https://bitbucket.org/wegmannlab/atlas/wiki/Home). The first step is running their `splitMerge` tool. Since we split our realigned BAM file by chromosome parts, we'll run these as job arrays on Slurm.

```bash
# In dir: ~/GitHub/Barley_Outgroups/morex_v3/04_Call_Ancestral_GT
sbatch --array=0-13 atlas_splitMerge-murinum.sh
```

#### Infer ancestral allele with ANGSD

Alternatively, if you would like to infer the ancestral allele for a given set of realigned BAM files, you can run [ANGSD](http://www.popgen.dk/angsd/index.php/ANGSD#Overview) to generate allele frequences and use the `-anc` flag to give it an ancestral FASTA file. ANGSD's `*.mafs.gz` output file will have information on the ancestral allele.
