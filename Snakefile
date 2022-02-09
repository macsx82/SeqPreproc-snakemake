#Snakefile for the pipeline to perform pre processing on sequence data, WES or WGS,
# to assess quality and evetually apply trimming and adapter removal
#
#
# 22/01/2021
#
# Author: massimiliano [dot] Cocca [at] burlo [dot] trieste [dot] it
#import libraries
import pandas as pd
import pathlib
import io
import os
import re
from snakemake.exceptions import print_exception, WorkflowError
from snakemake.utils import validate, min_version

##### set minimum snakemake version #####
min_version("5.31.0")

#read samplesheet
samples_df = pd.read_table(config["samples"], sep=" ", header=0, dtype='object')
#get samples ids from tablesheet
sample_names = list(samples_df.SAMPLE_ID)
# we need file names for R1 and R2
R1 = [ os.path.splitext(os.path.splitext(os.path.basename(fq1))[0])[0] for fq1 in samples_df.fq1]
R2 = [ os.path.splitext(os.path.splitext(os.path.basename(fq2))[0])[0] for fq2 in samples_df.fq2]
# Define some variables
PROJ= config["proj_name"]
BASE_OUT=config["base_out"]

##### local rules #####
localrules: all

##### target rules #####

rule all:
    input:
        #multiqc output
        orig_html = BASE_OUT + "/" + config["multiqc_dir"] + "/raw_multiqc.html", 
        trim_html = BASE_OUT + "/" + config["multiqc_dir"] + "/trimmed_multiqc.html"


##### load rules #####

include_prefix="rules"
include:
    include_prefix + "/fq_preproc_split.smk"
include:
    include_prefix + "/trimming.smk"
include:
    include_prefix + "/fq_postproc.smk"
include:
    include_prefix + "/multiqc.smk"
