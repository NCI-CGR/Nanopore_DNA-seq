#!/bash/bin
module load snakemake/5.13.0 graphviz
snakemake --rulegraph | dot -T png > nanopore.png

