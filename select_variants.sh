#!/bin/bash


#Hard code file paths
PICARD_HOME='/data/amrita/DDP-work/GI_server_backup/amrita/tools'
GATK_HOME='/data/amrita/DDP-work/GI_server_backup/amrita/tools/gatk-4.2.5.0'
DIR='/data/amrita/DDP-work/10.22/variant_calling_13'

java -Xmx16g -jar $GATK_HOME/gatk-package-4.2.5.0-local.jar SelectVariants -R $DIR/hg38.fa -V $DIR/Homo_sapiens_assembly38.dbsnp138.vcf  -O $DIR/known_biallelic_sites.vcf.gz --restrict-alleles-to BIALLELIC

