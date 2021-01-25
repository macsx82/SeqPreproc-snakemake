#rule to generate the multiqc report
rule multiqc:
  output:
    orig_html = BASE_OUT + "/" + config["multiqc_dir"] + "/raw_multiqc.html", 
    trim_html = BASE_OUT + "/" + config["multiqc_dir"] + "/trimmed_multiqc.html"
  input:
    orig = expand("{BASE_DIR}/{QC_DIR}/{sample}_fastqc.zip", BASE_DIR= BASE_OUT, QC_DIR=config["fastqc_pre_dir"], sample=R1+R2),
    trimmed = expand("{BASE_DIR}/{QC_DIR}/{sample}_R{num}_trimmed_fastqc.zip", BASE_DIR= BASE_OUT, QC_DIR=config["fastqc_post_dir"],sample=sample_names,num=[1,2])
  params:
    dir = expand('{BASE_DIR}/{QC_DIR}/', BASE_DIR=BASE_OUT, QC_DIR=config["multiqc_dir"]),
    orig_html_name = "raw_multiqc.html", 
    trim_html_name = "trimmed_multiqc.html"
  # conda:
  #  "envs/multiqc-env.yaml"
  threads: 1
  resources:
    mem_mb=3000
  log:
    config["log_dir"] + "/multiqc.log",
    config["log_dir"] + "/multiqc.e"
  shell: 
    """
    multiqc -o {params.dir} -n {params.orig_html_name} {input.orig} 2> {log[1]} #run multiqc
    #repeat for trimmed data
    multiqc -o {params.dir} -n {params.trim_html_name} {input.trimmed} 2> {log[1]} #run multiqc
    """ 