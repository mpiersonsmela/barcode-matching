#!/usr/bin/env bash
#known_barcode_batch.sh

#Note: requires BBtools to be installed.
#See: https://jgi.doe.gov/data-and-tools/bbtools/bb-tools-user-guide/installation-guide/

#arguments: $1: the target folder from the MiSeq data. $2: the file with known barcodes.

#Example command: ./known-barcode-align-parallel.sh test-data barcode_list_for_alignment.csv


pipeline () {
    local left_reads=${1}/*R1_001.fastq.gz
    local lr=$(echo ${left_reads})
    local right_reads=${1}/*R2_001.fastq.gz
    local rr=$(echo ${right_reads})
    
    local sample_name=$(echo "${lr}" | awk 'BEGIN { FS = "L001" } ; { print $1 }')
    
    echo "Running pipeline on ${sample_name}"
    
    bbmerge.sh in1=${lr} in2=${rr} out=${sample_name}merged.fq.gz outa=${sample_name}_adapters.fa 2> ${sample_name}bbmerge_out.txt

    python3 illumina_align_known_barcodes.py ${sample_name}merged.fq.gz ${2} 2> ${sample_name}unmatched.txt
    
    return 0
}

for folder in ${1}/*; do
    pipeline ${folder} ${2} &
done
wait
exit 0