#!/usr/bin/env nextflow

process SPLITLETTERS {
    debug true

    publishDir path:'results'

    input:
    tuple val(block_size), val(input_str), val(out_name)
    
    output:
    path '*_chunk_*'

    script:
    """
    printf ${input_str} | split -b ${block_size} - ${out_name}_chunk_
    """
} 

process CONVERTTOUPPER {
    debug true

    input: 
    path chunk_file

    output:
    stdout

    script:
    """
    cat ${chunk_file} | tr '[a-z]' '[A-Z]'
    """
} 

workflow { 
    // 1. Read in the samplesheet (samplesheet_2.csv)  into a channel. The block_size will be the meta-map
    // 2. Create a process that splits the "in_str" into sizes with size block_size. The output will be a file for each block, named with the prefix as seen in the samplesheet_2
    // 4. Feed these files into a process that converts the strings to uppercase. The resulting strings should be written to stdout

    // read in samplesheet}
    in_ch = channel.fromPath('samplesheet_2.csv').splitCsv(header:true)

    // split the input string into chunks
    split_ch = SPLITLETTERS(in_ch)

    // lets remove the metamap to make it easier for us, as we won't need it anymore

    // convert the chunks to uppercase and save the files to the results directory

    split_upper_ch = CONVERTTOUPPER(split_ch.flatten())

    // attempt to get info
    split_ch.view()
}