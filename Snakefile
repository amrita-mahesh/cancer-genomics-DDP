configfile: "configs/config.yaml"

import snakemake as snakemake
import pandas as pd 

input_samples = pd.read_csv("configs/samples.csv")
samples_list = input_samples['sample'].tolist()


rule all:
  input:
    expand("filtered_files/filtered_somatic_{sample}.vcf.gz", sample=samples_list)

rule fastp:
  input:
    "samples/{sample_any}_R1.fastq.gz",
    "samples/{sample_any}_R2.fastq.gz"
  output:
    "trimmed_samples/{sample_any}_trimmed_R1.fastq.gz",
    "trimmed_samples/{sample_any}_trimmed_R2.fastq.gz",
    "trimmed_samples/html/{sample_any}_fastp.html",
    "trimmed_samples/json/{sample_any}_fastp.json"
  conda:
    "fastp_env"
  shell:
    "fastp -i {input[0]} -I {input[1]} -o {output[0]} -O {output[1]} -h {output[2]} -j {output[3]}"    


rule make_sam_file:
  input:
    "trimmed_samples/{sample}_trimmed_R1.fastq.gz",
    "trimmed_samples/{sample}_trimmed_R2.fastq.gz"
  output:
    "bamfiles/{sample}.sam"
  params:
    reference_genome="reference_files/hg38.fa"
  shell:
    "bwa mem -M -t 15 {params.reference_genome} {input[0]} {input[1]} > {output}" 


rule make_bam_file:
  input:
    "bamfiles/{sample}.sam"
  output:
    "bamfiles/{sample}.bam",
    "bamfiles/{sample}.bai"
  params:
    picard_home=config["picard_home"]    
  run:
    shell("java -Xmx8G -jar {params.picard_home}/picard.jar AddOrReplaceReadGroups -INPUT {input} -OUTPUT {output[0]} -SORT_ORDER coordinate -RGID {wildcards.sample}-id -RGLB {wildcards.sample}-lib -RGPL ILLUMINA -RGPU {wildcards.sample}-01 -RGSM {wildcards.sample}"),
    shell("java -Xmx16g -jar {params.picard_home}/picard.jar BuildBamIndex -I {output[0]} -O {output[1]}")


rule mark_duplicates:
  input:
    "bamfiles/{sample}.bam"
  output:
    "bamfiles/{sample}_marked.bam",
    "bamfiles/metrics/metrics_{sample}.txt"
  params:
    picard_home=config["picard_home"]
  shell:
    "java -Xmx16g -jar {params.picard_home}/picard.jar MarkDuplicates -INPUT {input} -OUTPUT {output[0]} -METRICS_FILE {output[1]}"


rule bqsr:
  input:
    "bamfiles/{sample}_marked.bam"
  output:
    "bqsrfiles/{sample}_bqsr.bam",
    "bqsrfiles/{sample}_recal_data.table"
  params:
    known_sites="reference_files/Homo_sapiens_assembly38.dbsnp138.vcf.gz",
    gatk_home=config["gatk_home"],
    reference_genome="reference_files/hg38.fa"
  run:
    shell("java -Xmx40g -jar {params.gatk_home}/gatk-package-4.2.5.0-local.jar BaseRecalibrator -I {input} -R {params.reference_genome} --known-sites {params.known_sites} -O {output[1]}")
    shell("java -Xmx40g -jar {params.gatk_home}/gatk-package-4.2.5.0-local.jar ApplyBQSR --bqsr-recal-file {output[1]} -I {input} -R {params.reference_genome} -O {output[0]}")


rule variant_calling:
  input:
    "bqsrfiles/{sample}t_bqsr.bam",
    "bqsrfiles/{sample}p_bqsr.bam"
  output:
    "vcf_files/somatic_{sample}t.vcf.gz"
  params:
    gatk_home=config["gatk_home"],
    reference_genome="reference_files/hg38.fa",
    germline_resource="reference_files/somatic-hg38_af-only-gnomad.hg38.vcf.gz",
    panel_of_normals="reference_files/somatic-hg38_1000g_pon.hg38.vcf.gz"
  shell:
    "java -Xmx16g -jar {params.gatk_home}/gatk-package-4.2.5.0-local.jar Mutect2 -R {params.reference_genome} -I {input[0]} -I {input[1]} -normal {wildcards.sample}p -O {output} --germline-resource {params.germline_resource} --panel-of-normals {params.panel_of_normals}"


rule get_pileup_summaries:
  input:
    "bqsrfiles/{sample}_bqsr.bam"
  output:
    "filtered_files/{sample}_getpileupsummaries.table"
  params:
    gatk_home=config["gatk_home"],
    reference_sites="reference_files/small_exac_common_3.hg38.vcf.gz"
  shell:
    "java -Xmx16g -jar {params.gatk_home}/gatk-package-4.2.5.0-local.jar GetPileupSummaries -I {input} -V {params.reference_sites} -L {params.reference_sites} -O {output}"

rule calculate_contamination:
  input:
    "filtered_files/{sample}t_getpileupsummaries.table"
  output:
    "filtered_files/{sample}t_calculatecontamination.table"
  params:
    gatk_home=config["gatk_home"]
  shell:
    "java -Xmx16g -jar {params.gatk_home}/gatk-package-4.2.5.0-local.jar CalculateContamination -I {input} -O {output}"

rule filter_mutect_calls:
  input:
    "filtered_files/{sample}_calculatecontamination.table",
    "vcf_files/somatic_{sample}.vcf.gz"
  output:
    "filtered_files/filtered_somatic_{sample}.vcf.gz"
  params:
    gatk_home=config["gatk_home"],
    reference_genome="reference_files/hg38.fa"
  shell:
    "java -Xmx16g -jar {params.gatk_home}/gatk-package-4.2.5.0-local.jar FilterMutectCalls -R {params.reference_genome} --contamination-table {input[0]} -V {input[1]}  -O {output}"



