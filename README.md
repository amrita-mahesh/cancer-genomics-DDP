
<!-- ABOUT -->
## About The Project

This repository documents all the code for my dual degree project on the analysis of Indian pancreatic cancer data. This pipeline can be used to call somatic mutations from a set of paired tumour-normal samples. 

This Snakemake pipeline takes raw reads (FASTQ files) as input and generates BAM files, raw variant calls (VCF files) and a final filtered set of variants. 


<!-- Setting up -->
## Setting up

1. Clone this repository.

   ```sh
   git clone https://github.com/amrita-mahesh/cancer-genomics-DDP
   ```
2. Download all the reference files required - this pipeline uses the hg38 build of the human genome.

3. Create a conda environment 'fastp_env' to run fastp for quality control and read trimming.

```sh
conda create --name fastp_env

conda activate fastp_env

conda install -c bioconda fastp

conda deactivate
```

### Running the pipeline

* Navigate to the directory containing the Snakefile and create a 'samples' folder.

  ```sh
  mkdir samples
  
  ```
  
* Create a file configs/samples.csv that contains the names of the tumour samples. An example file is provided in the repository.

* Run the snakemake pipeline with the specified number of cores.

```sh
snakemake --cores <number of cores> 
```

