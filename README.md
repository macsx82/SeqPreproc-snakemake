# Preprocessing pipeline for sequence data.

This pipeline aims to provide a tool to get a first look at fastq data. With this pipelinie we will:

1) Perform a FastQC check on raw fastq data
2) Perform trimming on the fastq files
3) Rerun a fastQC check after trimming 
4) Generate a multiQC report to have a comprehensive look at the data


## Setting things up

In order to run the pipeline, there are some requirements to fullfill and some set up needs to be perfomed. In this current version, the pipeline is tested and configured to be run on the [ORFEO cluster](https://orfeo-documentation.readthedocs.io/en/latest/) . It is possible to run the pipeline on the Apollo cluster, but it will require to manually specify fastp and fastQC binary location in the provided config file.


### Required Software

The following software has to be installed system-wide or in a user-defined Conda environment (something more about conda below).

+ awk
+ sed
+ python3
+ fastp
+ fastQC
+ git

### Required python packages

In order to run the pipeline, the following python packages have to be installed in your conda environment:

+ pandas
+ pathlib
+ io
+ os
+ re
+ snakemake

### Other requirements

If the fastq files are provided as multiplexed files (multiple fastq files per sample), it is necessary to perform a merging step, to generate the initial files to be processed.

As a practical example, data produced by the AREA sequencing facility are generated performing different sequencing runs on the same sample, therefore, we will have multiple fastq files with the same file name, located in different folders. 
Below an example of the code that can be used to merge files coming from two different runs.

```bash
declare -A runs=()
#set the run array
runs[RUN_1]=$(echo "220114_A00618_0204_AHKWWJDSX2")
runs[RUN_2]=$(echo "220121_A00618_0207_AHKWLGDSX2")

out_folder=${HOME}/analyses/BATCH_20220218/LISTS
mkdir -p ${out_folder}

for run_n in RUN_1 RUN_2
do
run_name=(${runs[${run_n}]})
echo ${run_name}

find -L /analisi_da_consegnare/burlo/${run_name} -type f -name "*.gz" | fgrep -v "Undetermined"| sort > ${out_folder}/${run_n}_files_list.txt
done
```

Generate a list of commands to merge data from the 2 different runs

```bash
out_path=${HOME}/BATCH_20220218/0.RAW_DATA
base_lists=${HOME}/analyses/BATCH_20220218/LISTS

(paste -d " " ${base_lists}/RUN_1_files_list.txt ${base_lists}/RUN_2_files_list.txt | awk -v outfile=${out_path} '{OFS=" "}{split($1,a,"/");split(a[7],b,"_"); print "cat",$0,">",outfile"/"b[1]"_"b[2]"_L001_"b[3]"_"b[4]}') > ${base_lists}/MERGE_batch_20220218.sh

```

The command generated can be used to merge the fastq files. In this case the command will also take care of the file naming, using the [**Illumina convention**](https://support.illumina.com/help/BaseSpace_OLH_009008/Content/Source/Informatics/BS/NamingConvention_FASTQ-files-swBS.htm).

Absolute paths of the fastq files (saparate files for R1 and R2 strand) to be processed, named with the **Illumina convention**, demultiplexed.

Manifest file following the template provided in the **resource** folder, space separated and with the following header line:

```
SAMPLE_ID fq1 fq2
```


### ORFEO/general set up
1. Install Snakemake via conda ([link](https://snakemake.readthedocs.io/en/stable/getting\_started/installation.html));
    ```bash
    conda create -c conda-forge -c bioconda -n snakemake snakemake ruamel.yaml
    ```
2. Activate the environment you created
    ```bash
    conda activate snakemake
    ```

### Apollo set up

1. Add the global snakemake environment to your environment list:
    ```bash
    conda config --append envs_dirs /shared/software/conda/envs
    conda config --prepend envs_dirs ~/.conda/envs
    ```

2. Check that the environment is available to you (you should see an entry "snakemake_g" in the list)
    ```bash
    conda env list
    ```
3. Load the environment
    ```bash
    conda activate snakemake_g
    ```


## Usage

It is advised to clone the pipeline to a personal folder from the git repository, in order to be able to correctly execute the workflow.
The clone command to use is:

```bash
	git clone https://gitlab.burlo.trieste.it/max/SeqPreproc-snakemake.git
```

This command will create a new folder, in the current location, named **SeqPreproc-snakemake**


Before running the pipeline, it is necessary to provide some information using a config file. A config file template, with default values is provided and it is named **config.yaml**

It is advisable not to execute the pipeline in the repository folder, but to create a separate folder and a copy a copy of the config file to fill the relevant parameters.

To exploit the trimming functions of the pipeline, the parameters:

+ cR1
+ cR2
+ tpcR1
+ tpcR2

should be set according to the desired number of base pairs to trim from each read.

### Running the pipeline

There are differen ways to run the pipeline: **Local mode**, **Cluster mode** or **Single node mode**

### Local mode

In Local mode, the pipeline is executed in an interactive shell session (locally or on a cluster) and all the rules are treated as processes that can be run sequentially or in parallel, depending on the resources provided. One example of a Local execution is:

```bash
conda activate snakemake

base_cwd=/<USER_DEFINED_PATH>/PREPROCESSING
log_folder=${base_cwd}/Log
mkdir -p ${log_folder}
cd ${base_cwd}

snakefile=/<USER_DEFINED_PATH>/SeqPreproc-snakemake/Snakefile
configfile=/<USER_DEFINED_PATH>/PREPROCESSING/preprocessing_pipeline.yaml
cores=24

snakemake -p -r -s ${snakefile} --configfile ${configfile} --use-envmodules --keep-going --cores ${cores}

```

In this example we assumed we had 24 CPU available for our calculation



### Cluster mode

In cluster mode, the pipeline runs on a interactive shell (**screen or tmux**) and each rule is submitted as a job on the cluster.
One example of a Cluster execution, on the **ORFEO cluster**, is:

```bash
module load conda
conda activate snakemake

base_cwd=/<USER_DEFINED_PATH>/PREPROCESSING
log_folder=${base_cwd}/Log
mkdir -p ${log_folder}
cd ${base_cwd}

snakefile=/<USER_DEFINED_PATH>/SeqPreproc-snakemake/Snakefile
configfile=/<USER_DEFINED_PATH>/PREPROCESSING/preprocessing_pipeline.yaml

log_name=preprocessing_pipeline.log
stderr_name=preprocessing_pipeline.err
cores=24
queue=thin

snakemake -p -r -s ${snakefile} --configfile ${configfile} --use-envmodules --keep-going --cluster "qsub -q ${queue} -V -k eod -l select=1:ncpus={threads}:mem={resources.mem_mb}mb -l walltime=96:00:00" -j ${cores} 1> ${log_name} 2> ${stderr_name}
```

In this example we defined also the name for two additional log files, which will help to keep track of the pipeline execution. In this case, the **-j** option will define how many concurrent jobs are submitted on the cluster.



### Single node mode

In Single node mode, the pipeline runs as a job on the cluster and all rules are treated as processes that can be run sequentially or in parallel, depending on the resources provided. Similar to the Local execution mode.
One example of a single node mode execution, on the **ORFEO cluster**, is:

```bash
module load conda
conda activate snakemake

base_cwd=/<USER_DEFINED_PATH>/PREPROCESSING
log_folder=${base_cwd}/Log
mkdir -p ${log_folder}
cd ${base_cwd}

snakefile=/<USER_DEFINED_PATH>/SeqPreproc-snakemake/Snakefile
configfile=/<USER_DEFINED_PATH>/PREPROCESSING/preprocessing_pipeline.yaml

log_name=preprocessing_pipeline.log
stderr_name=preprocessing_pipeline.err
cores=24
queue=thin
mem=750g

echo "cd ${base_cwd};module load conda;conda activate snakemake; snakemake -p -r -s ${snakefile} --configfile ${configfile} --cores ${cores} --use-envmodules --keep-going" | qsub -N snake_preprocessing -q ${queue} -V -k eod -o ${log_folder}/${log_name} -e ${log_folder}/${stderr_name} -l select=1:ncpus=${cores}:mem=${mem} -l walltime=96:00:00
done
```

In this example we selected an entire cluster node on the "thin" queue of the ORFEO cluster, defining the number of CPU (24) and the total amount of RAM required to run the pipeline (750g). We defined also the name for the two additional log files, to keep track of the pipeline execution.

