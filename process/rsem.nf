process rsem {
    tag "$meta.id"
    label 'rsem'
    label 'medCpu'
    label 'extraMem'
    input:
    tuple val(meta), path(transcriptsBam)

    output:
    path "${meta.id}.results", emit: results

    script:
    """
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