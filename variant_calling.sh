#!/bin/bash


#Hard code file paths
PICARD_HOME='/data/amrita/DDP-work/GI_server_backup/amrita/tools'
GATK_HOME='/data/amrita/DDP-work/GI_server_backup/amrita/tools/gatk-4.2.5.0'
DIR='/data/amrita/DDP-work/10.22/variant_calling_13'



for TUMOUR in $DIR/*T*_bqsr.bam;

do

#Get normal and tumour file paths
NORMAL=${TUMOUR//AT/AN};

#Sample name is only the name of the sample - no paths.
TUMOUR_SAMPLENAME=${TUMOUR//$DIR\//};
NORMAL_SAMPLENAME=${NORMAL//$DIR\//};
TUMOUR_SAMPLENAME=${TUMOUR_SAMPLENAME//_bqsr.bam/};
NORMAL_SAMPLENAME=${NORMAL_SAMPLENAME//_bqsr.bam/};


echo $TUMOUR, $NORMAL, $NORMAL_SAMPLENAME

java -Xmx16g -jar $GATK_HOME/gatk-package-4.2.5.0-local.jar Mutect2 -R $DIR/hg38.fa -I $TUMOUR -I $NORMAL -normal $NORMAL_SAMPLENAME -O $DIR/somatic_${TUMOUR_SAMPLENAME}.vcf.gz --germline-resource $DIR/somatic-hg38_af-only-gnomad.hg38.vcf.gz --panel-of-normals $DIR/somatic-hg38_1000g_pon.hg38.vcf.gz 

done

