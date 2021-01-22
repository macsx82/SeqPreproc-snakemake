#define rule for fastqc run on data
rule fastq_qc_pre_r1:
    wildcard_constraints:
        sample='.+_R1_.+',
    output:
        BASE_OUT + "/" + config["fastqc_pre_dir"] + "/{sample}_fastqc.html",
        BASE_OUT + "/" + config["fastqc_pre_dir"] + "/{sample}_fastqc.zip"
    input:
        r1 = lambda wc: samples_df[samples_df.SAMPLE_ID == (wc.sample).split(sep="_")[0]].fq1
    log:
        config["log_dir"] + "/{sample}-qc-before-trim.log"
    threads: 1
    params:
        dir = expand('{BASE_DIR}/{QC_DIR}/', BASE_DIR=BASE_OUT, QC_DIR=config["fastqc_pre_dir"]),
        qc_tool = config["QC_TOOL"]
    message: """--- Quality check of raw data with FastQC before trimming."""
    shell:
        'mkdir -p {params.dir};'
        '{params.qc_tool} -o {params.dir} -f fastq {input.r1}'

rule fastq_qc_pre_r2:
    wildcard_constraints:
        sample=".+_R2_.+"
    output:
        BASE_OUT + "/" + config["fastqc_pre_dir"] + "/{sample}_fastqc.html",
        BASE_OUT + "/" + config["fastqc_pre_dir"] + "/{sample}_fastqc.zip"
    input:
        r2 = lambda wc: samples_df[samples_df.SAMPLE_ID == (wc.sample).split(sep="_")[0]].fq2
    log:
        config["log_dir"] + "/{sample}-qc-before-trim.log"
    threads: 1
    params:
        dir = expand('{BASE_DIR}/{QC_DIR}/', BASE_DIR=BASE_OUT, QC_DIR=config["fastqc_pre_dir"]),
        qc_tool = config["QC_TOOL"]
    message: """--- Quality check of raw data with FastQC before trimming."""
    shell:
        'mkdir -p {params.dir};'
        '{params.qc_tool} -o {params.dir} -f fastq {input.r2};'