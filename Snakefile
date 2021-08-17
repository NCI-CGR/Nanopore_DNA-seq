### This pipeline is for Oxford Nanopore DNA sequencing data analysis
# 1) Modified base calling using the tool Megalodon
# 2) Structural variant calling using the pipeline-structural-variation
# 3) Haplotype-aware variant calling using the PEPPER-Margin-DeepVariant piepline

## vim: ft=python
import sys
import os
import glob
import itertools

shell.prefix("set -eo pipefail; ")
configfile:"config/config.yaml"
localrules: all

# Path
run = os.getcwd() + "/"
raw = config["raw"]
out = config.get("out","output")
pepper = config["pepper"]
bind = config["bind"]
snpeff = config["snpeff"]

# Sample names
def parse_sampleID(fname):
    return fname.split(raw)[-1].split('_fast5')[0]

dire = sorted(glob.glob(raw + '*_fast5'), key=parse_sampleID)

d = {}
for key, value in itertools.groupby(dire, parse_sampleID):
    d[key] = list(value)

samples = d.keys()

# Map to HPV genome or not
if config["hpv"]=="yes":
   include: "modules/Snakefile_MBC"
   include: "modules/Snakefile_SV"
   include: "modules/Snakefile_MBC_hpv"
   include: "modules/Snakefile_SV_hpv"
   include: "modules/Snakefile_VC"
   include: "modules/Snakefile_VC_hpv"
   rule all:
        input:
              expand(out + "mbc/basic/{sample}/mod_mappings.5mC_sorted.bam.bai",sample=samples),
              expand(out + "mbc/model_based/{sample}/mod_mappings.5mC_sorted.bam.bai",sample=samples),
              expand(out + "sv/{sample}/sv_calls/{sample}_cutesv_filtered_ann_Qfiltered.vcf",sample=samples),
              expand(out + "sv/{sample}/qc",sample=samples),
              expand(out + "mbc_hpv/basic/{sample}/mod_mappings.5mC_sorted.bam.bai",sample=samples),
              expand(out + "mbc_hpv/model_based/{sample}/mod_mappings.5mC_sorted.bam.bai",sample=samples),
              expand(out + "sv_hpv/{sample}/sv_calls/{sample}_cutesv_filtered_ann.vcf",sample=samples),
              expand(out + "sv_hpv/{sample}/qc",sample=samples),
              expand(out + "vc/{sample}/complete.txt",sample=samples),
              expand(out + "vc/{sample}/filter/{sample}_PEPPER_Margin_DeepVariant.phased_ann_Qfiltered_ann.vcf",sample=samples),
              expand(out + "vc_hpv/{sample}/complete.txt",sample=samples),
              expand(out + "vc_hpv/{sample}/{sample}_PEPPER_Margin_DeepVariant.phased_ann.vcf",sample=samples),

else:
    include: "modules/Snakefile_MBC"
    include: "modules/Snakefile_SV"
    include: "modules/Snakefile_VC"
    rule all:
         input:
               expand(out + "mbc/basic/{sample}/mod_mappings.5mC_sorted.bam.bai",    sample=samples),
               expand(out + "mbc/model_based/{sample}/mod_mappings.5mC_sorted.bam    .bai",sample=samples),
               expand(out + "sv/{sample}/sv_calls/{sample}_cutesv_filtered_ann_Qf    iltered.vcf",sample=samples),
               expand(out + "sv/{sample}/qc",sample=samples),
               expand(out + "vc/{sample}/complete.txt",sample=samples),
               expand(out + "vc/{sample}/filter/{sample}_PEPPER_Margin_DeepVariant.phased_ann_Qfiltered_ann.vcf",sample=samples)
