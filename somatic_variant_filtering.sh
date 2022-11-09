#!/bin/bash


#Hard code file paths
PICARD_HOME='/data/amrita/DDP-work/GI_server_backup/amrita/tools'
GATK_HOME='/data/amrita/DDP-work/GI_server_backup/amrita/tools/gatk-4.2.5.0'
DIR='/data/amrita/DDP-work/10.22/variant_calling_13'



for SAMPLE in $DIR/somatic_*.vcf.gz;

do

SAMPLENAME=${SAMPLE//$DIR\//};
TUMOURNAME=${SAMPLENAME//.vcf.gz/};
TUMOURNAME=${TUMOURNAME//somatic_/};

echo $SAMPLENAME, $TUMOURNAME

java -Xmx16g -jar $GATK_HOME/gatk-package-4.2.5.0-local.jar GetPileupSummaries -I $DIR/${TUMOURNAME}_bqsr.bam -V $DIR/known_biallelic_sites.vcf.gz -L $DIR/known_biallelic_sites.vcf.gz -O $DIR/${TUMOURNAME}_getpileupsummaries.table

java -Xmx16g -jar $GATK_HOME/gatk-package-4.2.5.0-local.jar CalculateContamination -I $DIR/${SAMPLENAME}_getpileupsummaries.table -O $DIR/${TUMOURNAME}_calculatecontamination.table

java -Xmx16g -jar $GATK_HOME/gatk-package-4.2.5.0-local.jar FilterMutectCalls -R $DIR/hg38.fa --contamination-table $DIR/${TUMOURNAME}_calculatecontamination.table -V $SAMPLE  -O $DIR/filtered_${SAMPLENAME}


done

