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
        "fastqc/0.11.9"
    group: "preproc"
    message: """--- Quality check of trimmed data with FastQC """
    shell:
        """
        mkdir -p {params.dir};
        {params.qc_tool} -o {params.dir} -t {threads} -f fastq {input[0]} {input[1]} 2>> {log[1]}
        # {params.qc_tool} -o {params.dir} -f fastq {input[1]} 2>> {log[1]}
        """

#define a shadow rule to insert in the processing group before the multiqc rule, in order to be able to run rules grouped by sample
rule preproc_collect:
    output:
        touch(BASE_OUT + "/" + config["fastqc_post_dir"] + "/{sample}_preproc.done")
    input:
        rules.fastq_qc_pre_r1.output[0], rules.fastq_qc_pre_r2.output[0],
        rules.trimming_pe.output.r1, rules.trimming_pe.output.r2,
        rules.fastq_qc_post.output
    log:
        config["log_dir"] + "/{sample}-preproc_collect.log",config["log_dir"] + "/{sample}-preproc_collect.e"
    threads: 1
    resources:
        mem_mb=1000
    group: "preproc"
    message: """--- Collection rule """
    shell:
        """
        sleep 10 2>> {log[1]}
        """
