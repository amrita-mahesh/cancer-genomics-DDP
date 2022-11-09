#!/bin/bash

#Hard code file paths
PICARD_HOME='/data/amrita/DDP-work/GI_server_backup/amrita/tools' 
GATK_HOME='/data/amrita/DDP-work/GI_server_backup/amrita/tools'
DIR='/data/amrita/DDP-work/10.22/variant_calling_13'


for R1 in $DIR/*R1*; 

do

 
#R1 and R2 are paths to the paired fastq files
R2=${R1//R1.fastq.gz/R2.fastq.gz};

#Filename gives the path to the directory with the sam and bam files.
FILENAME=${R1//_R1.fastq.gz/};

#Sample name is only the name of the sample - no paths.
SAMPLENAME=${FILENAME//$DIR\//};

#echo $R1, $R2, $FILENAME, $SAMPLENAME

mkdir $FILENAME


bwa mem -M -t 15 $DIR/hg38.fa ${R1} ${R2} > ${DIR}/${SAMPLENAME}.sam

mv ${DIR}/${SAMPLENAME}.sam ${FILENAME}/${SAMPLENAME}.sam 

java -Xmx8G -jar $PICARD_HOME/picard.jar AddOrReplaceReadGroups -INPUT ${FILENAME}/${SAMPLENAME}.sam -OUTPUT ${FILENAME}/${SAMPLENAME}.bam -SORT_ORDER coordinate -RGID ${SAMPLENAME}-id -RGLB ${SAMPLENAME}-lib -RGPL ILLUMINA -RGPU ${SAMPLENAME}-01 -RGSM ${SAMPLENAME}

java -Xmx16g -jar $PICARD_HOME/picard.jar BuildBamIndex -INPUT ${FILENAME}/${SAMPLENAME}.bam


java -Xmx16g -jar $PICARD_HOME/picard.jar MarkDuplicates -INPUT ${FILENAME}/${SAMPLENAME}.bam -OUTPUT ${FILENAME}/${SAMPLENAME}_marked.bam -METRICS_FILE ${FILENAME}/metrics_${SAMPLENAME}.txt


done

