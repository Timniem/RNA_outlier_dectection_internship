# Nextflow pipeline

prerequisites:
- Nextflow (21.10.6 or higher) 
- Singularity(or Apptainer) 


## install guide
clone the repository
```
git clone https://github.com/Timniem/RNA_outlier_dectection_internship/
```

Get the singularity container using Singularity:
```
singularity pull --arch amd64 library://timniem/rna_outliers/test:sha256.8fe6ae8f47810ee49d5bc6c45ace48daec0f76e4a216faa199b9f7aeb9ace1e2
```

or alternatively using Apptainer:
```
# Add the Sylabscloud to the remotes on Apptainer
apptainer remote add --no-login SylabsCloud cloud.sylabs.io
apptainer remote use SylabsCloud

# if not already configured
export APPTAINER_CACHEDIR=/path/to/tmp

apptainer pull --dir 'path/to/cache/dir' container_name.sif library://timniem/rna_outliers/test:sha256.8fe6ae8f47810ee49d5bc6c45ace48daec0f76e4a216faa199b9f7aeb9ace1e2
```

Add the singularity container to the nextflow config:
```
singularity {
    enabled = true
    cacheDir = "/path/to/cache/"
    autoMounts = true
}
process {
    executor="slurm" # if slurm is used.
    container="path/to/container.sif"
}
```

make sure a Fasta file and folder is selected. 
```
params.fasta="phase1/human_g1k_v37_phiX.fasta.gz"
params.fastafolder="/apps/data/1000G/phase1/"
```

See the drop documentation for downloading the external count files:
https://github.com/gagneurlab/drop

The following files are expected in the external count folder:

sampleAnnotation.tsv
geneCounts.tsv.gz
k_j_counts.tsv.gz
k_theta_counts.tsv.gz
n_psi3_counts.tsv.gz
n_psi5_counts.tsv.gz
n_theta_counts.tsv.gz



Configure external counts and a compatible gtf file.
```
params {
    featurecounts {
        genes_gtf="resources/gtf/gencode.v29lift37.annotation.gtf"
    }
    extcounts {
        folder="counts/GTEX/Whole_Blood--hg19--gencode29"
        amount_outrider=100
        amount_fraser=100
    }
}
```

## Using the pipeline

For usage it is recommended to use a high performance computing cluster with at least 32gb of ram available on a node.

A samplesheet in which sample specific parameters can be specified must be included.



| parameter        | Type        | Description | Required    |
| -----------      | ----------- | ----------- | ----------- |
| sampleID         | character   | Name/id of the sample in the row, this name will be used to annotate the results. | TRUE |
| bamFile          | character   | File path to the RNA .bam file, on this location bam index files (.bai) files are expected as well | TRUE |
| pairedEnd        | bool        | TRUE if the RNA sequencing method was paired-end, FALSE if this is not the case | TRUE |
| strandSpecific   | numeric     | strandedness of the RNA seq method: 0 = unstranded, 1= Forward stranded, 2= Reverse stranded | TRUE |
| vcf              | character   | Path to a genomic vcf (WES/WGS), if this is not provided (or is "NA") the MAE module will not be executed for that sample | FALSE |
| excludeFit       | bool        | TRUE if this sample needs to be excluded from fit (OUTRIDER/FRASER), FALSE if this is not the case | FALSE |


An example of a samplesheet will be:

```
sampleID	bamFile	pairedEnd	strandSpecific	vcf	excludeFit
sample1	/path/to/bam1.bam	TRUE	1	/path/to/vcf1.vcf.gz	FALSE
sample2	/path/to/bam2.bam	TRUE	1	/path/to/vcf2.vcf.gz	FALSE
sample3	/path/to/bam3.bam	TRUE	1	/path/to/vcf3.vcf.gz	FALSE
sample4	/path/to/bam4.bam	TRUE	1	/path/to/vcf4.vcf.gz	FALSE
sample5	/path/to/bam5.bam	TRUE	1	/path/to/vcf5.vcf.gz	FALSE
sample6	/path/to/bam6.bam	TRUE	1	/path/to/vcf6.vcf.gz	FALSE

```


Run command example

```
nextflow run main.nf --output "path/to/output/folder" --samplesheet "path/to/samplesheet"
```
