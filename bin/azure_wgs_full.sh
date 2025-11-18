#!/bin/bash

set -eu 

ID='PAW79146'
PREFIX="HG001_${ID}_wf-human-variation"
BAMS='az://demo-azure-wgs/sup/sup/calls.sorted.bam'
OUTDIR='az://demo-azure-wgs/wgs_human_variation'
# FASTA="https://www.bcgsc.ca/downloads/genomes/9606/hg38_no_alt/bwa_0.7.6a_ind/genome/hg38_no_alt.fa"
FASTA="results/hg38_no_alt.fa"

NXF_CONFIG="configs/azbatch.nextflow.config"
export NXF_DEBUG=2


nextflow \
    -c $NXF_CONFIG \
    -log reports/${PREFIX}_nextflow.log \
    run epi2me-labs/wf-human-variation \
    --sample_name "sample_${ID}" \
    --bam $BAMS \
    --out_dir $OUTDIR \
    --ref $FASTA \
    --snp \
    --annotation FALSE \
    -profile standard \
    -with-report reports/${PREFIX}.nextflow_report.html \
    -with-dag reports/${PREFIX}.nextflow_dag.html \
    -with-trace reports/${PREFIX}.nextflow_trace.txt \
    -cache TRUE \
    -resume 

