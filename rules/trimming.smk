rule trimming_pe:
    output:
        r1 = BASE_OUT +"/"+config["trim_dir"]+ "/{sample}/{sample}_R1_trimmed.fq.gz",
        r2 = BASE_OUT +"/"+config["trim_dir"]+ "/{sample}/{sample}_R2_trimmed.fq.gz",
        u1 = BASE_OUT +"/"+config["trim_dir"]+ "/{sample}/{sample}_R1_unpaired.fq.gz",
        u2 = BASE_OUT +"/"+config["trim_dir"]+ "/{sample}/{sample}_R2_unpaired.fq.gz",
        j = BASE_OUT +"/"+config["trim_dir"]+ "/{sample}/{sample}_fastp.json",
        h = BASE_OUT +"/"+config["trim_dir"]+ "/{sample}/{sample}_fastp.html"
    input:
        r1 = lambda wc: samples_df[samples_df.SAMPLE_ID == (wc.sample).split(sep="_")[0]].fq1,
        r2 = lambda wc: samples_df[samples_df.SAMPLE_ID == (wc.sample).split(sep="_")[0]].fq2
        # [INPUTDIR + "/{sample}_R1_001.fastq.gz",
        #  INPUTDIR + "/{sample}_R2_001.fastq.gz"]
    params:
        trim_tool=config['TRIM_TOOL'],
        # dir = expand('{BASE_DIR}/{QC_DIR}/', BASE_DIR=BASE_OUT, QC_DIR=config["trim_dir"]),
        extra="--detect_adapter_for_pe -W "+ config['rules']['trimming_pe']['w'] +" -M "+config['rules']['trimming_pe']['q']+" -5 -3"
    threads: 4
    benchmark:
        BASE_OUT +"/"+config["trim_dir"]+ "/{sample}/{sample}_trimming.tsv"
    log:
        config["log_dir"] + "/{sample}-trimming.log"
    shell:
        '{params.trim_tool} {params.extra} -w {threads} --in1 {input.r1} --in2 {input.r2} --out1 {output.r1} --out2 {output.r2} --unpaired1 {output.u1} --unpaired2 {output.u2} --json {output.j} --html {output.h}'
