#25/09/2020

Create a pre-processing pipeline to get first look at fastq data. With this pipelinie we will:

1) perform fastQC check on raw fastq data
2) perform trimming on the data
3) rerun a fastQC check after trimming 
4) generate a multiQC report to have a comprehensive look at the data

To run the pipeline:


```bash
module load fastp
module load fastqc
conda activate snakemake

snakemake -np -r -s /home/max/Work/scripts/pipelines/SeqPreproc-snakemake/Snakefile --configfile /home/max/Work/scripts/pipelines/SeqPreproc-snakemake/preproc.yaml

snakemake -p -r -s /home/max/Work/scripts/pipelines/SeqPreproc-snakemake/Snakefile --configfile /home/max/Work/scripts/pipelines/SeqPreproc-snakemake/preproc.yaml -cores 2
```