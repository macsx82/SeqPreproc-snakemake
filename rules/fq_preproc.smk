#define rule for fastqc run on data
rule fastq_qc_pre:
    # wildcard_constraints:
        # sample_fs1='.+_R1_.+',
        # sample_fs2='.+_R2_.+'
    output:
        # BASE_OUT + "/" + config["fastqc_pre_dir"] + "/{r1_strand}_fastqc.html",
        # BASE_OUT + "/" + config["fastqc_pre_dir"] + "/{r1_strand}_fastqc.zip",
        # BASE_OUT + "/" + config["fastqc_pre_dir"] + "/{r2_strand}_fastqc.html",
        # BASE_OUT + "/" + config["fastqc_pre_dir"] + "/{r2_strand}_fastqc.zip"
        # BASE_OUT + "/" + config["fastqc_pre_dir"] + "/{sample_fs1}_fastqc.html",
        # BASE_OUT + "/" + config["fastqc_pre_dir"] + "/{sample_fs1}_fastqc.zip",
        # BASE_OUT + "/" + config["fastqc_pre_dir"] + "/{sample_fs2}_fastqc.html",
        # BASE_OUT + "/" + config["fastqc_pre_dir"] + "/{sample_fs2}_fastqc.zip"
        # BASE_OUT + "/" + config["fastqc_pre_dir"] + "/{sample}_fastqc.html",
        # BASE_OUT + "/" + config["fastqc_pre_dir"] + "/{sample}_fastqc.zip",
        # BASE_OUT + "/" + config["fastqc_pre_dir"] + "/{sample}_fastqc.done"
        # BASE_OUT + "/" + config["fastqc_pre_dir"] + "/{sample}_R2_fastqc.html",
        # BASE_OUT + "/" + config["fastqc_pre_dir"] + "/{sample}_R2_fastqc.zip"
        # expand('{BASE_DIR}/{QC_DIR}/{{sample}}_R1_fastqc.{ext}', BASE_DIR=BASE_OUT, QC_DIR=config["fastqc_pre_dir"], sample=sample_names,ext=['html','zip']),
        # expand('{BASE_DIR}/{QC_DIR}/{{sample}}_R2_fastqc.{ext}', BASE_DIR=BASE_OUT, QC_DIR=config["fastqc_pre_dir"], sample=sample_names,ext=['html','zip'])
        expand('{BASE_DIR}/{QC_DIR}/{{sample}}_fastqc.{ext}', BASE_DIR=BASE_OUT, QC_DIR=config["fastqc_pre_dir"], sample=R1+R2,ext=['html','zip'])
    input:
        r1 = lambda wc: samples_df[samples_df.SAMPLE_ID == (wc.sample).split(sep="_")[0]].fq1,
        r2 = lambda wc: samples_df[samples_df.SAMPLE_ID == (wc.sample).split(sep="_")[0]].fq2
    log:
        config["log_dir"] + "/{sample}-qc-before-trim.log",
        config["log_dir"] + "/{sample}-qc-before-trim.err"
    threads: 2
    resources:
        mem_mb=4000
    benchmark:
        BASE_OUT +"/"+config["fastqc_pre_dir"]+ "/{sample}_fastqc_pre.tsv"
    envmodules:
        "fastqc"
    params:
        dir = expand('{BASE_DIR}/{QC_DIR}/', BASE_DIR=BASE_OUT, QC_DIR=config["fastqc_pre_dir"]),
        qc_tool = config["QC_TOOL"],
        extra_args= config["rules"]["fastq_qc"]["extra_args"]
    message: """--- Quality check of raw data with FastQC before trimming."""
    group: "preproc"
    shell:
        """
        mkdir -p {params.dir};
        {params.qc_tool} -o {params.dir} -t {threads} -f fastq {params.extra_args} {input.r1} {input.r2} 2> {log[1]}
        """
