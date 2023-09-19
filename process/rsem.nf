process rsem {
    tag "$meta.id"
    label 'rsem'
    label 'medCpu'
    label 'highMem'
    input:
    tuple val(meta), path(txBam)

    output:
    path "${meta.id}.genes.results", emit: geneResults
    path "${meta.id}.isoforms.results", emit: isoformResults
    path ("versions.txt"), emit: versions

    script:

    def op = meta.singleEnd? : "--paired-end"
    """
    
    echo \$(rsem-calculate-expression --version 2>&1) > versions.txt

    rsem-calculate-expression $op \
			--alignments \
			--estimate-rspd \
			--append-names \
			--no-bam-output \
			--strandedness $params.stranded \
			$txBam\
			$params.rsemRef \
			$meta.id 

    """
}