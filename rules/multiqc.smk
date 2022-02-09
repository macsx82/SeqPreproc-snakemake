#rule to generate the multiqc report
rule multiqc_pre:
  output:
    orig_html = BASE_OUT + "/" + config["multiqc_dir"] + "/raw_multiqc.html"
  input:
    orig = expand("{BASE_DIR}/{QC_DIR}/{sample}_fastqc.zip", BASE_DIR= BASE_OUT, QC_DIR=config["fastqc_pre_dir"], sample=R1+R2)
  params:
    dir = expand('{BASE_DIR}/{QC_DIR}/', BASE_DIR=BASE_OUT, QC_DIR=config["multiqc_dir"]),
    orig_html_name = "raw_multiqc.html"
  threads: 1
  resources:
    mem_mb=3000
  benchmark:
        BASE_OUT +"/"+config["multiqc_dir"]+ "/multiqc-pre.tsv"
  log:
    config["log_dir"] + "/multiqc_pre.log",
    config["log_dir"] + "/multiqc_pre.e"
  envmodules:
    "multiqc/1.9"
  shell: 
    """
    #collect fastq results for original data
    multiqc -o {params.dir} -n {params.orig_html_name} {input.orig} 2> {log[1]} #run multiqc
    """ 

rule multiqc_post:
  output:
    trim_html = BASE_OUT + "/" + config["multiqc_dir"] + "/trimmed_multiqc.html"
  input:
    trimmed = expand("{BASE_DIR}/{QC_DIR}/{sample}_R{num}_trimmed_fastqc.zip", BASE_DIR= BASE_OUT, QC_DIR=config["fastqc_post_dir"],sample=sample_names,num=[1,2]),
    fastp = expand("{BASE_DIR}/{TRIM_DIR}/{sample}/{sample}_fastp.json", BASE_DIR= BASE_OUT, TRIM_DIR=config["trim_dir"],sample=sample_names)
  params:
    dir = expand('{BASE_DIR}/{QC_DIR}/', BASE_DIR=BASE_OUT, QC_DIR=config["multiqc_dir"]),
    trim_html_name = "trimmed_multiqc.html"
  threads: 1
  resources:
    mem_mb=3000
  benchmark:
        BASE_OUT +"/"+config["multiqc_dir"]+ "/multiqc-post.tsv"
  log:
    config["log_dir"] + "/multiqc_post.log",
    config["log_dir"] + "/multiqc_post.e"
  envmodules:
    "multiqc/1.9"
  shell: 
    """
    #multiqc collection for trimmed data
    multiqc -o {params.dir} -n {params.trim_html_name} {input.trimmed} {input.fastp} 2>> {log[1]} #run multiqc
    """ 