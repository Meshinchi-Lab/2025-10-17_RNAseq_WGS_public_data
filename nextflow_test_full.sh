#!/bin/bash

set -eu
DATE=$(date +%F)
NXF_CONFIG=./azbatch.nextflow.config
NXF_PROFILE="test" 
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
