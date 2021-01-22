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
        # r1 = lambda wc: samples_df[samples_df.SAMPLE_ID == wc.sample].fq1,
        # r2 = lambda wc: samples_df[samples_df.SAMPLE_ID == wc.sample].fq2
        # r1 = expand("{FASTQ_DIR}/{sample}_{prefix}_R1_{postfix}.fastq.gz", FASTQ_DIR=sample_locations, sample=sample_names,prefix=prefix, postfix=postfix),
        # r2 = expand("{FASTQ_DIR}/{sample}_{prefix}_R2_{postfix}.fastq.gz", FASTQ_DIR=sample_locations, sample=sample_names,prefix=prefix, postfix=postfix)
        # r1 = expand('{FASTQ_DIR}/{sample}_{prefix}_R1_{postfix}.fastq.gz', FASTQ_DIR=sample_locations, sample=sample_names),
        # r2 = expand('{FASTQ_DIR}/{sample}_{prefix}_R2_{postfix}.fastq.gz', FASTQ_DIR=sample_locations, sample=sample_names)
    log:
        # config["log_dir"] + "/{sample}-qc-before-trim.log"
        config["log_dir"] + "/{sample_fs1}-qc-before-trim.log",
        config["log_dir"] + "/{sample_fs2}-qc-before-trim.log"
        # config["log_dir"] + "/{r2_strand}-qc-before-trim.log"
    threads: 1
    params:
        dir = expand('{BASE_DIR}/{QC_DIR}/', BASE_DIR=BASE_OUT, QC_DIR=config["fastqc_pre_dir"]),
        qc_tool = config["QC_TOOL"]
    message: """--- Quality check of raw data with FastQC before trimming."""
    shell:
    # 'module load fastqc/0.11.5;'
        'mkdir -p {params.dir};'
        '{params.qc_tool} -o {params.dir} -f fastq {input.r1} & '
        '{params.qc_tool} -o {params.dir} -f fastq {input.r2}'
        # 'touch {output[2]}'

# rule fastq_qc_pre_r2:
#     # wildcard_constraints:
#     #     sample="\.+_R2_\.+"
#     output:
#         # BASE_OUT + "/" + config["fastqc_pre_dir"] + "/{r1_strand}_fastqc.html",
#         # BASE_OUT + "/" + config["fastqc_pre_dir"] + "/{r1_strand}_fastqc.zip",
#         # BASE_OUT + "/" + config["fastqc_pre_dir"] + "/{r2_strand}_fastqc.html",
#         # BASE_OUT + "/" + config["fastqc_pre_dir"] + "/{r2_strand}_fastqc.zip"
#         # BASE_OUT + "/" + config["fastqc_pre_dir"] + "/{sample_fs1}_fastqc.html",
#         # BASE_OUT + "/" + config["fastqc_pre_dir"] + "/{sample_fs1}_fastqc.zip",
#         # BASE_OUT + "/" + config["fastqc_pre_dir"] + "/{sample_fs2}_fastqc.html",
#         # BASE_OUT + "/" + config["fastqc_pre_dir"] + "/{sample_fs2}_fastqc.zip"
#         BASE_OUT + "/" + config["fastqc_pre_dir"] + "/{sample}_fastqc.html",
#         BASE_OUT + "/" + config["fastqc_pre_dir"] + "/{sample}_fastqc.zip",
#         BASE_OUT + "/" + config["fastqc_pre_dir"] + "/{sample}_fastqc.done"
#         # BASE_OUT + "/" + config["fastqc_pre_dir"] + "/{sample}_R2_fastqc.html",
#         # BASE_OUT + "/" + config["fastqc_pre_dir"] + "/{sample}_R2_fastqc.zip"
#         # expand('{BASE_DIR}/{QC_DIR}/{sample}_R1_fastqc.{ext}', BASE_DIR=BASE_OUT, QC_DIR=config["fastqc_pre_dir"], sample=sample_names,ext=['html','zip']),
#         # expand('{BASE_DIR}/{QC_DIR}/{sample}_R2_fastqc.{ext}', BASE_DIR=BASE_OUT, QC_DIR=config["fastqc_pre_dir"], sample=sample_names,ext=['html','zip'])
#     input:
#         rules.fastq_qc_pre_r1.output[2],
#         r1 = lambda wc: samples_df[samples_df.SAMPLE_ID == (wc.sample).split(sep="_")[0]].fq1,
#         r2 = lambda wc: samples_df[samples_df.SAMPLE_ID == (wc.sample).split(sep="_")[0]].fq2
#         # r1 = lambda wc: samples_df[samples_df.SAMPLE_ID == wc.sample].fq1,
#         # r2 = lambda wc: samples_df[samples_df.SAMPLE_ID == wc.sample].fq2
#         # r1 = expand("{FASTQ_DIR}/{sample}_{prefix}_R1_{postfix}.fastq.gz", FASTQ_DIR=sample_locations, sample=sample_names,prefix=prefix, postfix=postfix),
#         # r2 = expand("{FASTQ_DIR}/{sample}_{prefix}_R2_{postfix}.fastq.gz", FASTQ_DIR=sample_locations, sample=sample_names,prefix=prefix, postfix=postfix)
#         # r1 = expand('{FASTQ_DIR}/{sample}_{prefix}_R1_{postfix}.fastq.gz', FASTQ_DIR=sample_locations, sample=sample_names),
#         # r2 = expand('{FASTQ_DIR}/{sample}_{prefix}_R2_{postfix}.fastq.gz', FASTQ_DIR=sample_locations, sample=sample_names)
#     log:
#         config["log_dir"] + "/{sample}-qc-before-trim.log"
#         # config["log_dir"] + "/{sample_fs1}-qc-before-trim.log",
#         # config["log_dir"] + "/{sample_fs2}-qc-before-trim.log"
#         # config["log_dir"] + "/{r2_strand}-qc-before-trim.log"
#     threads: 1
#     params:
#         dir = expand('{BASE_DIR}/{QC_DIR}/', BASE_DIR=BASE_OUT, QC_DIR=config["fastqc_pre_dir"]),
#         qc_tool = config["QC_TOOL"]
#     message: """--- Quality check of raw data with FastQC before trimming."""
#     shell:
#     # 'module load fastqc/0.11.5;'
#         'mkdir -p {params.dir};'
#         # '{params.qc_tool} -o {params.dir} -f fastq {input.r1} & '
#         '{params.qc_tool} -o {params.dir} -f fastq {input.r2};'
#         'touch {output[2]}'
#define rule for fastqc run on data
# rule fastq_qc_post:
#     input:
#         INPUTDIR + "/{sample}_R{num}_001.fastq.gz"
#     output:
#         html = SCRATCH_PROJ + "/fastqc/{sample}_{num}_fastqc.html",
#         zip = SCRATCH_PROJ + "/fastqc/{sample}_{num}_fastqc.zip"
#     log:
#         SCRATCH_PROJ + "/logs/fastqc/{sample}_{num}.log"
#     wrapper:
#         "0.66.0/bio/fastqc"

# rule qc_before_trim:
#     input:
#         r1 = expand('{FASTQ_DIR}/{sample}_R1.fastq.gz', FASTQ_DIR=sample_locations, sample=sample_names),
#         r2 = expand('{FASTQ_DIR}/{sample}_R2.fastq.gz', FASTQ_DIR=sample_locations, sample=sample_names)
#     output:
#         expand('{QC_DIR}/{QC_TOOL}/before_trim/{sample}_R1_fastqc.html', QC_DIR=dirs_dict["QC_DIR"], QC_TOOL=config["QC_TOOL"], sample=sample_names),
#         expand('{QC_DIR}/{QC_TOOL}/before_trim/{sample}_R1_fastqc.zip', QC_DIR=dirs_dict["QC_DIR"], QC_TOOL=config["QC_TOOL"], sample=sample_names),
#         expand('{QC_DIR}/{QC_TOOL}/before_trim/{sample}_R2_fastqc.html', QC_DIR=dirs_dict["QC_DIR"], QC_TOOL=config["QC_TOOL"], sample=sample_names),
#         expand('{QC_DIR}/{QC_TOOL}/before_trim/{sample}_R2_fastqc.zip', QC_DIR=dirs_dict["QC_DIR"], QC_TOOL=config["QC_TOOL"], sample=sample_names)
#     log: expand('{LOG_DIR}/{sample}-{QC_TOOL}-qc-before-trim.log', QC_TOOL=config["QC_TOOL"], LOG_DIR=dirs_dict["LOG_DIR"], sample=sample_names)
#     resources:
#         mem = 1000,
#         time = 30
#     threads: 1
#     params:
#         dir = expand('{QC_DIR}/{QC_TOOL}/before_trim/', QC_DIR=dirs_dict["QC_DIR"], QC_TOOL=config["QC_TOOL"])
#     message: """--- Quality check of raw data with FastQC before trimming."""
#     shell:
#         'module load fastqc/0.11.5;'
#     'fastqc -o {params.dir} -f fastq {input.r1} &'
#     'fastqc -o {params.dir} -f fastq {input.r2}'