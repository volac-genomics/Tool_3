#!/usr/bin/env nextflow

ch_inputs = Channel.fromPath( "$baseDir/input_tool_3/*.gff" )


//////////////////////////////////
//      SETUP PARAMETERS        //
//////////////////////////////////

// unique run identifier
name = "${params.runID}"

// minimum percentage identity for blastp [95]
perIdentity = "${params.identity}"

// percentage of isolates a gene must be in to be core [99]
perCore = "${params.core}"


//////////////////////////////////
//        HELP MESSAGE          //
//////////////////////////////////

def helpMessage() {
    log.info """
        Execute the genome comparison pipeline with tools roary and fast tree. 
        Usage: 
        The typical command for running the pipeline is as follows
        
        nextflow run tool_3.nf --runID '<txt here>' [options]

        Mandatory arguments:
	--runID 'xxx'	    name chosen by user [default: 'not_specified']

        Optional arguments:            
	--identity 'yy'     minimum percentage identity for blastp [default: 99].
	--core 'zz'	    percentage of isolates a gene must be in to be core [default: 95].

	Example:
	nextflow run tool_3.nf --runID 'N1A' --identity '90' --core '75'
        
        """
}

// Show help message
if (params.help) {
    helpMessage()
    exit 0
}


 process roary {

        tag "$params.runID"

        cpus 4

        publishDir "$baseDir/output_tool_3/output_${name}-i${perIdentity}-core${perCore}", mode: 'copy'

        input:
       	file('*') from ch_inputs.toList()

        output:
        file ("*") optional true
        file ("core_gene_alignment.aln") into ch_roary_out

        script:
        """

	roary -e --mafft -p 8 -f ${name}-i${perIdentity}-core${perCore} -i '${perIdentity}' -cd '${perCore}' *

        mv ${name}-i${perIdentity}-core${perCore}/* .
        rm -r ${name}-i${perIdentity}-core${perCore}
        """
}


process fasttree {

	tag "tree_drawing"

        cpus 4

        publishDir "$baseDir/output_tool_3/output_${name}-i${perIdentity}-core${perCore}", mode: 'copy'

        input:
	file('*') from ch_roary_out

	output:
	file "${name}-i${perIdentity}-core${perCore}.newick"

        script:
        """
	FastTree -nt -gtr * > ${name}-i${perIdentity}-core${perCore}.newick
	"""
    }


