#!/bin/bash

set -eu
DATE=$(date +%F)
NXF_CONFIG=./configs/azbatch.nextflow.config
NXF_PROFILE="docker" 
NXF_ENTRY='rnaseq_count'
REPORT=${1:-"custom_rnaseq"}

# Set Debug > 0 to increase verbosity in nextflow logs
export NXF_DEBUG=2

# Nextflow run to execute the workflow
PREFIX="${REPORT}_${DATE}"
nextflow -c ${NXF_CONFIG} \
    -log reports/${PREFIX}_nextflow.log \
    run Meshinchi-Lab/rnaseq_count_nf \
    -profile ${NXF_PROFILE} \
    -entry ${NXF_ENTRY} \
    -with-report reports/${PREFIX}.html \
    -with-dag dag/${PREFIX}_dag.dot \
    -with-trace reports/${PREFIX}_trace.txt