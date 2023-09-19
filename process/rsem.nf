process rsem {
    tag "$meta.id"
    label 'rsem'
    label 'medCpu'
    label 'highMem'
    input:
    tuple val(meta), path(transcriptsBam)

    output:
    path "${meta.id}.genes.results", emit: geneResults
    path "${meta.id}.isoforms.results", emit: isoformResults
    path ("versions.txt"), emit: versions

    script:
    """
    echo \$(rsem-calculate-expression --version 2>&1) > versions.txt
    
    if [ $meta.singleEnd ]; then 
        op="-p 10"
    else 
        op="-p 10 --paired-end" 
    fi

    rsem-calculate-expression \$op \
			--alignments \
			--estimate-rspd \
			--append-names \
			--no-bam-output \
			--strandedness $params.stranded \
			$transcriptsBam\
			$params.rsemRef \
			$meta.id 

    """
}