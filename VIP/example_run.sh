# Example run Sjogren samples VIP

vip_folder_latest=/groups/umcg-gdio/rsc01/vip/v6.0.2
#type of workflow, (g)vcf, cram, fastq
workflow=vcf
#input = .tsv samplesheet
input=/groups/umcg-gdio/tmp01/umcg-tniemeijer/vip/run_2/input/example_input.tsv
#output = output folder
output=/groups/umcg-gdio/tmp01/umcg-tniemeijer/vip/run_2/output
#config = config file
config=/groups/umcg-gdio/tmp01/umcg-tniemeijer/vip/run_2/config/hg19.cfg

cd $vip_folder_latest

bash vip.sh --workflow $workflow --input $input --output $output --config $config 

