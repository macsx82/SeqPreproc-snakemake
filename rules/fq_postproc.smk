#define rule for fastqc run on trimmed data
rule fastq_qc_post:
    output:
        # BASE_OUT + "/" + config["fastqc_post_dir"] + "/{sample}_fastqc.html",
        # BASE_OUT + "/" + config["fastqc_post_dir"] + "/{sample}_fastqc.zip"
        expand('{BASE_DIR}/{QC_DIR}/{{sample}}_R1_trimmed_fastqc.{ext}', BASE_DIR=BASE_OUT, QC_DIR=config["fastqc_post_dir"], sample=sample_names,ext=['html','zip']),
        expand('{BASE_DIR}/{QC_DIR}/{{sample}}_R2_trimmed_fastqc.{ext}', BASE_DIR=BASE_OUT, QC_DIR=config["fastqc_post_dir"], sample=sample_names,ext=['html','zip'])
    input:
        # r1 = BASE_OUT +"/"+config["trim_dir"]+ "/{pippo}/{pippo}_R1_trimmed.fq.gz",
        # r2 = BASE_OUT +"/"+config["trim_dir"]+ "/{pippo}/{pippo}_R2_trimmed.fq.gz",
        rules.trimming_pe.output.r1, rules.trimming_pe.output.r2
    log:
        config["log_dir"] + "/{sample}-qc-post-trim.log",config["log_dir"] + "/{sample}-qc-post-trim.e"
    threads: 1
    params:
        dir = expand('{BASE_DIR}/{QC_DIR}/', BASE_DIR=BASE_OUT, QC_DIR=config["fastqc_post_dir"]),
        qc_tool = config["QC_TOOL"]
    message: """--- Quality check of trimmed data with FastQC """
    shell:
        'module load fastqc;'
        'mkdir -p {params.dir};'
        '{params.qc_tool} -o {params.dir} -f fastq {input[0]} & {params.qc_tool} -o {params.dir} -f fastq {input[1]}'
        # '{params.qc_tool} -o {params.dir} -f fastq {input[0]} & {params.qc_tool} -o {params.dir} -f fastq {input[1]} 2> {log}'
