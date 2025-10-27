# Standardized Test Data and Nextflow Workflows


Standardized test tata and nextflow workflows for comparison of cloud compute resources. 


## Network Speed Test

On-prem datasets

### RNAseq

Bulk public paired-end illumina RNA-seq
* 124 Gb total
* /bioinformatics_resources/ngs_test_datasets/human/rnaseq/bulk/nf-core
* Selected
    * ~14 Gb SRX1603392_T1_1.fastq.gz, SRX1603392_T1_2.fastq.gz
    * ~13 Gb SRX2370469_T1_1.fastq.gz, SRX2370469_T1_2.fastq.gz

Single-cell public paired-end Illumina scRNA-seq
* 16 Gb total
* /bioinformatics_resources/ngs_test_datasets/human/rnaseq/single-cell/sratools/

### WGS

Bulk Nanopore long-read Whole Genome Sequenceing 

* Raw data
    * 1.1 Tb
    * /bioinformatics_resources/ngs_test_datasets/human/wgs/pod5/

* Aligned data
    * 108 Gb
    * /bioinformatics_resources/ngs_test_datasets/human/wgs/sup/

## Cloud Compute Costs

./nextflow run -c nextflow.config nf-core/rnaseq -profile test -w az://data/workingdir --outdir az://data/outuput

### bulk RNA-seq

#### Test Dataset

```{bash}
set -eu
DATE=$(date +%F)
NXF_CONFIG=./hyperqueue.nextflow.config
NXF_PROFILE="test,hyperqueue" 
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
```

#### Test Full Dataset

```{bash}
set -eu
DATE=$(date +%F)
NXF_CONFIG=hyperqueue.nextflow.config
NXF_PROFILE="test_full,hyperqueue" 
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
```

#### SRA Download 

```{bash}
set -eu
DATE=$(date +%F)
NXF_CONFIG=hyperqueue.nextflow.config
NXF_PROFILE="hyperqueue" 
REPORT=${1:-"nfcore_fetchings"}

# Set Debug > 0 to increase verbosity in nextflow logs
export NXF_DEBUG=2

# Nextflow run to execute the workflow
PREFIX="${REPORT}_${DATE}"
nextflow -c ${NXF_CONFIG} \
    -log reports/${PREFIX}_nextflow.log \
    run nf-core/fetchngs \
    -profile ${NXF_PROFILE} \
    -with-report reports/${PREFIX}.html \
    -with-dag dag/${PREFIX}_dag.dot \
    -with-trace reports/${PREFIX}_trace.txt
```

docker run \
    -i --cpu-shares 3072 --memory 18432m \
    -v /home/jennysmith/.nextflow/assets/nf-core/fetchngs/bin:/home/jennysmith/.nextflow/assets/nf-core/fetchngs/bin \
    -v /mnt/bioinformatics/nextflow_tmp/5f/efaa7560a1abdc6c5cd8aad7615c04:/mnt/bioinformatics/nextflow_tmp/5f/efaa7560a1abdc6c5cd8aad7615c04 \
    -w "$PWD" -u $(id -u):$(id -g) \
    quay.io/biocontainers/python:3.9--1 /bin/bash
    

```

```

## Long Read WGS


```
PREFIX='giab_2025.01/basecalling/sup/HG001/PAW79146/'
aws s3 ls --human-readable --no-sign-request s3://ont-open-data/$PREFIX
aws s3 sync --no-sign-request s3://ont-open-data/$PREFIX  data/giab_2025.01
```

```
PREFIX='giab_2025.01/flowcells/HG001/PAW79146'
aws s3 ls --no-sign-request s3://ont-open-data/$PREFIX/
aws s3 sync --no-sign-request s3://ont-open-data/$PREFIX  data/giab_2025.01
```

```
# Define Inputs
ID='PAW79146'
PREFIX="HG001_${ID}_wf-human-variation"
BAMS='/bioinformatics_resources/ngs_test_datasets/human/wgs/sup/calls.sorted.bam'
OUTDIR='/bioinformatics_resources/ngs_test_datasets/human/wgs/wf-human-variation'
FASTA='/bioinformatics_resources/genome_references/human/GRCh38/cicero_1.9.6/Homo_sapiens/GRCh38_no_alt/FASTA/GRCh38_no_alt.fa'

#--override_basecaller_cfg dna_r10.4.1_e8.2_400bps_sup@v4.3.0 \

nextflow \
    -log reports/${PREFIX}_nextflow.log \
    run epi2me-labs/wf-human-variation \
    --sample_name "sample_${ID}" \
    --bam $BAMS \
    --out_dir $OUTDIR \
    --ref $FASTA \
    --snp \
    --sv \
    --mod \
    --phased \
    --cnv \
    -profile standard \
    -with-report reports/${PREFIX}.nextflow_report.html \
    -with-dag reports/${PREFIX}.nextflow_dag.pdf \
    -with-trace reports/${PREFIX}.nextflow_trace.txt \
    -cache TRUE 

```