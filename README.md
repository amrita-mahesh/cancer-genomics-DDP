<h1>Systematic analysis of Indian pancreatic cancer genomes</h1>

This repository documents all the code for my Dual Degree project.

<h2>Running the pipeline</h2>
Given a set of input folders with gzipped fastq files, these scripts can be run one after the other on a HPC to produce analysis-ready somatic variant VCF files. Mutect2 is used to call variants for paired tumour-normal samples.

The pipeline is run as follows:
create_bam_files.sh -> bqsr.sh -> variant_calling.sh -> somatic_variant_filtering.sh
