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

### bulk RNA-seq

```
./bin/azure_custom_rnaseq.sh
```


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


# Configuration 

## Azure Batch

Install the CLI 
https://learn.microsoft.com/en-us/cli/azure/install-azure-cli-linux?view=azure-cli-latest&pivots=apt

```
az login
```

https://www.nextflow.io/docs/latest/azure.html#azure-batch

Azure Batch pool, which is a collection of virtual machines that can scale up or down based on an autoscale formula.


#### Run pipelines 

Use this to create a VM jump box 
Custom deployment
  * https://portal.azure.com/#create/Microsoft.Template
  * Build your own template in the editor
  * Use the exported template.json file from the current VM 
  * retain the disk image OS from prior jump box VMs (very lost cost to retain) in order keep installed deps and downloaded files


```
# on the VM jumping machine

sudo apt install openjdk-17-jre-headless 
sudo apt-get install gh
curl -s https://get.nextflow.io | bash
export PATH=$PATH:~/opt/bin


git clone https://github.com/Meshinchi-Lab/2025-10-17_RNAseq_WGS_public_data.git
cd 2025-10-17_RNAseq_WGS_public_data/


nextflow -c ./configs/azbatch.nextflow.config run nf-core/rnaseq -profile test -w az://demo-azure-rnaseq/work 
```

```
./bin/azure_test_full.sh
```

export PATH=$PATH:~/opt/bin

profiles {
    azbatch {
        process {
            executor = 'azurebatch'
            //queue = 'large'
            withLabel: 'high_mem' { 
                queue = 'large'
            }
            withLabel: '!high_mem' { 
                queue = 'small'
            }
        }
    }
}

### Data Transfer 

https://learn.microsoft.com/en-us/azure/storage/common/storage-use-azcopy-authorize-user-identity?toc=%2Fazure%2Fstorage%2Fblobs%2Ftoc.json&bc=%2Fazure%2Fstorage%2Fblobs%2Fbreadcrumb%2Ftoc.json&tabs=linux

```
https://github.com/Azure/azure-storage-azcopy/releases
azcopy -h

BLOB="https://cloudhpcstgaccount.blob.core.windows.net"
azcopy list --machine-readable $BLOB
```

```
# https://github.com/Azure/azure-storage-azcopy/issues/858#issuecomment-1079278951
# find top level contents
azcopy ls "$BLOB" | cut -d/ -f 1 | awk '!a[$0]++'

# find directories with depth N
N=3
azcopy ls "$BLOB" | cut -d/ -f 1-${N} | awk '!a[$0]++'

RNASEQ="/bioinformatics_resources/ngs_test_datasets/human/rnaseq/bulk/nf-core"
ls $RNASEQ/{SRX1603392,SRX2370469}*.gz
FILE1="$RNASEQ/SRX1603392_T1_1.fastq.gz"

azcopy copy --log-level DEBUG $FILE1 "$BLOB/demo-azure-rnaseq/rnaseq_data" 
```

```
FILES=$(ls -1 $RNASEQ/{SRX1603392,SRX2370469}*.gz)
for FILE in $(echo "$FILES")
do
    echo $(basename $FILE)
    cp $FILE ./data/rnaseq_data
    #azcopy copy $FILE "$BLOB/demo-azure-rnaseq/rnaseq_data" --log-level DEBUG
done

WGS_BAM="/bioinformatics_resources/ngs_test_datasets/human/wgs/sup"
WGS_POD5="/bioinformatics_resources/ngs_test_datasets/human/wgs/pod5"

azcopy copy $WGS_POD5 "$BLOB/demo-azure-wgs/wgs_data/pod5" --log-level DEBUG --recursive=true --put-md5 &

azcopy copy $WGS_BAM "$BLOB/demo-azure-wgs/wgs_data/sup" --log-level DEBUG --recursive=true --put-md5
```

N=2
azcopy ls "$BLOB" | cut -d/ -f 1-${N} | sort | uniq
>demo-azure-rnaseq/rnaseq_data; Content Length: 7.18 GiB
>demo-azure-rnaseq/work
>demo-azure-wgs/wgs_data
>INFO: Authenticating to source using Azure AD

az storage blob list -c "cloudhpcstgaccount" --auth-mode login

az storage blob list -c "demo-azure-wgs" --auth-mode login

## Google Cloud 

Upload data to google cloud storage
https://docs.cloud.google.com/sdk/docs/install#linux

```
tar -xf google-cloud-cli-linux-x86_64.tar.gz
./google-cloud-sdk/install.sh --help

./google-cloud-sdk/install.sh --bash-completion COMMAND_COMPLETION  --path-update PATH_UPDATE --rc-path RC_PATH

./google-cloud-sdk/bin/gcloud init
```

https://cloud.google.com/sdk/gcloud/reference/auth/login

```
gcloud auth login
```

* Commands will reference project `cloud-hpc-476411` by default
* Compute Engine commands will use region `europe-west4` by default
* Compute Engine commands will use zone `europe-west4-a` by default


### Data Transfer 

https://docs.cloud.google.com/storage/docs/copying-renaming-moving-objects#copy
https://docs.cloud.google.com/storage/docs/uploading-objects#uploading-an-object

```
GCLOUD="gs://demo-data-cloud-hpc-476411"
RNASEQ="/bioinformatics_resources/ngs_test_datasets/human/rnaseq/bulk/nf-core"
FILES=$(ls -1 $RNASEQ/{SRX1603392,SRX2370469}*.gz)
for FILE in $(echo "$FILES")
do
    OUT=$(basename $FILE)
    echo $OUT
    gcloud storage cp \
        -L rnaseq_manifest.txt \
        $FILE \
        $GCLOUD/rnaseq_data/$OUT
done
```

```
WGS_BAM="/bioinformatics_resources/ngs_test_datasets/human/wgs/sup"
WGS_POD5="/bioinformatics_resources/ngs_test_datasets/human/wgs/pod5"

gcloud storage cp --recursive -L wgs_pod5_manifest.txt $WGS_POD5 \
    "$GCLOUD/wgs_data/pod5" \
&& \    
gcloud storage cp --recursive -L wgs_bam_manifest.txt $WGS_BAM \
    "$GCLOUD/wgs_data/sup" 
```

### Run pipelines

Connect to the VM instance from command line 
`gcloud compute ssh hpc-toolkit --zone europe-west4-a`