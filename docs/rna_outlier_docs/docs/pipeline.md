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


Configure external counts and a compatible gtf file.
```
params {
    featurecounts {
        genes_gtf="resources/gtf/gencode.v29lift37.annotation.gtf"
    }
    extcounts {
        counts="counts/GTEX/Whole_Blood--hg19--gencode29"
        amount_outrider=100
        amount_fraser=100
    }
}
```

## Using the pipeline

For usage it is recommended to use a high performance computing cluster with at least 64gb of ram available on a node.

Run command example

```
nextflow run main.nf --output "path/to/output/folder" --samplesheet "path/to/samplesheet"
```
