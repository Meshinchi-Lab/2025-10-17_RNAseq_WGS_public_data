#!/bin/bash

set -eu
DATE=$(date +%F)
NXF_CONFIG="configs/azbatch.nextflow.config"
NXF_PROFILE="test_full" 
REPORT=${1:-"nfcore_rnaseq"}

# Set Debug > 0 to increase verbosity in nextflow logs
export NXF_DEBUG=2

# Nextflow run to execute the workflow
PREFIX="${REPORT}_${DATE}"
nextflow -c ${NXF_CONFIG} \
    -log reports/${PREFIX}_nextflow.log \
    run nf-core/rnaseq \
    -profile ${NXF_PROFILE} \
    -with-report reports/${PREFIX}.html \
    -with-dag dag/${PREFIX}_dag.dot \
    -with-trace reports/${PREFIX}_trace.txt 


# Unable to download path: https://cloudhpcstgaccount.blob.core.windows.net/demo-azure-rnaseq/work/stage-60597a61-24fe-4815-b248-606150f1f6a4/49/a234fa3bdfe397cf27144e50f81d9f/SRX1603629_T1_1.fastq.gz
# azcopy cp "https://cloudhpcstgaccount.blob.core.windows.net/demo-azure-rnaseq/work/stage-60597a61-24fe-4815-b248-606150f1f6a4/49/a234fa3bdfe397cf27144e50f81d9f/SRX1603629_T1_1.fastq.gz"

