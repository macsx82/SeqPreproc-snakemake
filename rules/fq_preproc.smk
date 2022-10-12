#define rule for fastqc run on data
rule fastq_qc_pre:
    wildcard_constraints:
        sample_fs1='.+_R1_.+',
        sample_fs2='.+_R2_.+'
    output:
        # BASE_OUT + "/" + config["fastqc_pre_dir"] + "/{r1_strand}_fastqc.html",
        # BASE_OUT + "/" + config["fastqc_pre_dir"] + "/{r1_strand}_fastqc.zip",
        # BASE_OUT + "/" + config["fastqc_pre_dir"] + "/{r2_strand}_fastqc.html",
        # BASE_OUT + "/" + config["fastqc_pre_dir"] + "/{r2_strand}_fastqc.zip"
        BASE_OUT + "/" + config["fastqc_pre_dir"] + "/{sample_fs1}_fastqc.html",
        BASE_OUT + "/" + config["fastqc_pre_dir"] + "/{sample_fs1}_fastqc.zip",
        BASE_OUT + "/" + config["fastqc_pre_dir"] + "/{sample_fs2}_fastqc.html",
        BASE_OUT + "/" + config["fastqc_pre_dir"] + "/{sample_fs2}_fastqc.zip"
        # BASE_OUT + "/" + config["fastqc_pre_dir"] + "/{sample}_fastqc.html",
        # BASE_OUT + "/" + config["fastqc_pre_dir"] + "/{sample}_fastqc.zip",
        # BASE_OUT + "/" + config["fastqc_pre_dir"] + "/{sample}_fastqc.done"
        # BASE_OUT + "/" + config["fastqc_pre_dir"] + "/{sample}_R2_fastqc.html",
        # BASE_OUT + "/" + config["fastqc_pre_dir"] + "/{sample}_R2_fastqc.zip"
        # expand('{BASE_DIR}/{QC_DIR}/{sample}_R1_fastqc.{ext}', BASE_DIR=BASE_OUT, QC_DIR=config["fastqc_pre_dir"], sample=sample_names,ext=['html','zip']),
        # expand('{BASE_DIR}/{QC_DIR}/{sample}_R2_fastqc.{ext}', BASE_DIR=BASE_OUT, QC_DIR=config["fastqc_pre_dir"], sample=sample_names,ext=['html','zip'])
    input:
        r1 = lambda wc: samples_df[samples_df.SAMPLE_ID == (wc.sample_fs1).split(sep="_")[0]].fq1,
        r2 = lambda wc: samples_df[samples_df.SAMPLE_ID == (wc.sample_fs2).split(sep="_")[0]].fq2
    log:
        # config["log_dir"] + "/{sample}-qc-before-trim.log"
        config["log_dir"] + "/{sample_fs1}-qc-before-trim.log",
        config["log_dir"] + "/{sample_fs2}-qc-before-trim.log"
    threads: 2
    envmodules:
        "fastqc"
    params:
        dir = expand('{BASE_DIR}/{QC_DIR}/', BASE_DIR=BASE_OUT, QC_DIR=config["fastqc_pre_dir"]),
        qc_tool = config["QC_TOOL"]
    message: """--- Quality check of raw data with FastQC before trimming."""
    shell:
        """
        mkdir -p {params.dir};
        {params.qc_tool} -o {params.dir} -t {threads} -f fastq {input.r1} {input.r2} 2>> {log[1]}
        """

#define rule for fastqc run on trimmed data
rule fastq_qc_post:
    output:
        expand('{BASE_DIR}/{QC_DIR}/{{sample}}_R1_trimmed_fastqc.{ext}', BASE_DIR=BASE_OUT, QC_DIR=config["fastqc_post_dir"], sample=sample_names,ext=['html','zip']),
        expand('{BASE_DIR}/{QC_DIR}/{{sample}}_R2_trimmed_fastqc.{ext}', BASE_DIR=BASE_OUT, QC_DIR=config["fastqc_post_dir"], sample=sample_names,ext=['html','zip'])
    input:
        rules.trimming_pe.output.r1, rules.trimming_pe.output.r2
    log:
        config["log_dir"] + "/{sample}-qc-post-trim.log",config["log_dir"] + "/{sample}-qc-post-trim.e"
    threads: 2
    resources:
        mem_mb=4000
    benchmark:
        BASE_OUT +"/"+config["fastqc_post_dir"]+ "/{sample}_fastqc_post.tsv"
    params:
        dir = expand('{BASE_DIR}/{QC_DIR}/', BASE_DIR=BASE_OUT, QC_DIR=config["fastqc_post_dir"]),
        qc_tool = config["QC_TOOL"]
    envmodules:
        "fastqc"
    group: "preproc"
    message: """--- Quality check of trimmed data with FastQC """
    shell:
        """
        mkdir -p {params.dir};
        {params.qc_tool} -o {params.dir} -t {threads} -f fastq {input[0]} {input[1]} 2>> {log[1]}
        """

