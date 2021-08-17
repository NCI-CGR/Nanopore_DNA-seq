# Nanopore long-read DNA sequencing data analysis pipeline

## Description
This snakemake pipeline is for Nanopore long-read DNA sequencing data analysis. The pipeline may be run on an HPC or in a local environment.

Major steps in this workflow include:

1) Modified basing calling using [Megalodon](https://github.com/nanoporetech/megalodon)
2) Structural variant calling using Nanopore [pipeline-structural-variation](https://github.com/nanoporetech/pipeline-structural-variation)
3) Haplotype-aware variant calling using [PEPPER-Margin-DeepVariant](https://github.com/kishwarshafin/pepper)

## Software Requirements
* [Snakemake](https://snakemake.readthedocs.io/en/stable/)
* [Megalodon](https://github.com/nanoporetech/megalodon)
* [Singularity](https://sylabs.io/singularity/)
* [PEPPER-Margin-DeepVariant](https://github.com/kishwarshafin/pepper)
* [SNPEFF](https://pcingola.github.io/SnpEff/download/)

## User's guide
### I. Input requirements
* Edited config/config.yaml
* Demultiplexed Nanopore fast5 data
* Reference genome file

### II. Editing the config.yaml
Basic parameters:
* raw: Path to the directory where demultiplexed fast5 data is stored. The name of sub-directory for each sample should be in this format: {sampleID}_fast5
* out: Output directory, default without input: "output" in working directory
* reference: Path to primary reference genome fasta file
* pepper: Path to the directory where PEPPER-Margin-DeepVariant singularity is downloaded
* bind: Singularity bind mounting
* snpeff: Path to SNPEFF installed location

Parameters for modified base calling:
* outputs: Desired outputs
* base_conv: modified base conversion
* motif: Restrict modified base results to the specified motifs
* thresh: Hard threshold for modified base aggregation (probability of modified/canonical base), default 0.75
* config: Guppy model config file

Parameters for SV calling:
* min_sv_length: Minimum SV length
* max_sv_length: Maximum SV length
* min_read_length: Minimum read length
* min_read_mapping_quality: Minimum mapping quality
* min_read_support: Minimum read support required to call a SV (auto for auto-detect)
* snpsift: Run snpsift filtering or not
* snpsift_filter: SnpSift filtering parameters if the input of the above parameter is "yes"
* target_bed: (Optional) BED file containing targeted regions where SVs will only be called

Parameters for Haplotype-aware variant calling:
* snpsift2: Run snpsift filtering or not
* snpsift_filter2: SnpSift filtering parameters if the input of the above parameter is "yes"


Optional parameters to run the full analysis on HPV genomes:

(This function was originally designed for the HPV project, however, it can be applied to any secondary genome analysis of any species with references.)

* hpv: Run the analysis on HPV genomes or not
* hpv_ref: Path to HPV reference genome fasta file
* snpeff_hpv: Name of the pre-build HPV snpEff annotation
* snpeff_config: Path to the HPV snpEff config file

### III. To run
* Clone the repository to your working directory
  ```bash
  git clone https://github.com/NCI-CGR/Nanopore_DNA-seq.git
  ```
* Install required software
* Edit and save config/config.yaml
* To run on an HPC using slurm job scheduler like NIH Biowulf (Pascal GPU or higher architecture required):

  Edit config/cluster_config.yaml according to your HPC information and adjust the computing resources as needed. Run sbatch.sh to initiate pipeline running.
  ```bash
  bash sbatch.sh
  ```
* To run in a local environment:
  ```bash
  snakemake -p --cores 16 --keep-going --rerun-incomplete --jobs 300 --latency-wait 120 all
  ```
* Look in log directory for logs for each rule
* To view the snakemkae rule graph:
  ```bash
  snakemake --rulegraph | dot -T png > nanopore.png
  ````
![dag](https://github.com/NCI-CGR/Nanopore_DNA-seq/blob/master/nanopore.png)

### IV Output directory structure
```bash
{output directory}
├── mbc # Modified base calling on primary (eg human) genome
│   ├── basic # using the default model
│   │   └── {sampleID}
│   └── model_based # using a specific model
│       └── {sampleID}
├── mbc_hpv # Modified base calling on secondary (eg HPV) genome
│   ├── basic # using the default model
│   │   └── {sampleID}
│   └── model_based # using a specific model
│       └── {sampleID}
├── sv # SV calling on primary genome
│   └── {sampleID}
├── sv_hpv # SV calling on secondary genome
│   └── {sampleID}
├── vc # Haplotype-aware variant calling on primary genome
│   └── {smapleID}
└── vc_hpv # Haplotype-aware variant calling on secondary genome
    └── {smapleID}
```
