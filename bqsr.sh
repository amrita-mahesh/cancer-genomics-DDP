#!/bin/bash


#Hard code file paths
PICARD_HOME='/data/amrita/DDP-work/GI_server_backup/amrita/tools'
GATK_HOME='/data/amrita/DDP-work/GI_server_backup/amrita/tools/gatk-4.2.5.0'
DIR='/data/amrita/DDP-work/10.22/variant_calling_13'


for FILE in $DIR/*.bam;

do


#Sample name is only the name of the sample - no paths.
BAMFILENAME=${FILE//$DIR\//};
SAMPLENAME=${BAMFILENAME//_marked.bam/};

echo $BAMFILENAME, $SAMPLENAME
java -Xmx40g -jar $GATK_HOME/gatk-package-4.2.5.0-local.jar BaseRecalibrator -I $FILE -R $DIR/hg38.fa --known-sites $DIR/Homo_sapiens_assembly38.dbsnp138.vcf -O $DIR/${SAMPLENAME}_recal_data.table

java -Xmx40g -jar $GATK_HOME/gatk-package-4.2.5.0-local.jar ApplyBQSR --bqsr-recal-file $DIR/${SAMPLENAME}_recal_data.table -I $FILE -R $DIR/hg38.fa -O $DIR/${SAMPLENAME}_bqsr.bam


done

