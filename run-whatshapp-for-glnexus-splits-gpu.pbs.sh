#!/bin/bash
# Display usage guide
usage() {
    echo "Usage: $0 <start_sample> <end_sample>"
    echo "  <start_sample>   : Start line number in the file list to process."
    echo "  <end_sample>     : End line number in the file list to process."
    echo
    echo "Example:"
    echo "  Process samples listed on lines 1 through 10:"
    echo "  $0 1 10"
}

# Check for help flag
if [ "$1" == "-h" ] || [ "$1" == "--help" ]; then
    usage
    exit 0
fi

###################################################################
# Set the path to the file list and specify variables
FILE_LIST="/scratch/ox63/mn4616/list_files/merged_bam_file_list_indo.txt"
OUTPUT_DIR="/g/data/ox63/indo_genomes/glnexus_gvcf/split_by_sample/"
REF="/g/data/ox63/genome/chm13v2.0.fa"
###################################################################
# Assign script arguments to variables
START_LINE=$1
END_LINE=$2

# Main processing loop
sed -n "${START_LINE},${END_LINE}p" "$FILE_LIST" | while read -r line; do
    BAM_PATH=$(echo "$line" | sed 's/.bai$//')
    INPUT=$(basename "$(dirname "$BAM_PATH")")

	PHASED_VCF="${OUTPUT_DIR}/${INPUT}_phased_glnexus.vcf.gz"
	GENOTYPED_VCF="${OUTPUT_DIR}/${INPUT}_glnexus.vcf.gz"
        PBS_SCRIPT="whatshapp_glnexus_${INPUT}.pbs"
        cat > "${PBS_SCRIPT}" <<EOF
#!/bin/bash
#PBS -N whatshapp_glnexus_${INPUT}
#PBS -P ox63
#PBS -q normal
#PBS -l walltime=48:00:00
#PBS -l mem=64GB
#PBS -l jobfs=64GB
#PBS -l ncpus=1
#PBS -l wd
#PBS -l storage=gdata/if89+scratch/ox63+gdata/ox63+gdata/lj09+scratch/lj09

module load samtools
module load bcftools
module load python3/3.12.1

export PYTHONPATH=\$PYTHONPATH:~/.local/lib/python3.12/site-packages

# Phase with whatshap
~/.local/bin/whatshap phase -o ${PHASED_VCF} --mapping-quality 10  --ignore-read-groups --reference ${REF} ${GENOTYPED_VCF} ${BAM_PATH}

bcftools index -t -f ${PHASED_VCF}
EOF
      qsub "${PBS_SCRIPT}"
done
