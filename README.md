<h1>Systematic analysis of Indian pancreatic cancer genomes</h1>

This repository documents all the code for my Dual Degree project. This pipeline is designed to call SNPs and indels from a set of given tumour and normal samples.

<h2>Setting up the pipeline</h2>
The configs/config.yaml file should be updates with the location to the GATK and Picard .jar files. The <i>reference_files</i> folder should contain links to the reference genome (in this case, hg38) along with index files for the reference genome. Additionally, the files for the panel of normals and germline resources are present in the <i>reference_files</i> folder. The <i>samples.csv</i> file can be updated with a list of sample names. The tumour and normal samples should be named {sample-name}t and {sample-name}p respectively. 

<h2>Running the pipeline</h2>
Running the pipeline generates four folders with raw BAM files, BAM files after base quality score recalibration, VCF files with variant calls, and VCF files after filtering with GATK's FilterMutectCalls.

