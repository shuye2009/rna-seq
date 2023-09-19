/*
 * Count reads per gene and per isoform using RSEM
 */


process rsem {
    tag "$meta.id"
    label 'rsem'
    label 'medCpu'
    label 'highMem'

    input:
    tuple val(meta), path(txBam)

    output:
    tuple val(meta), path("*.genes.results"), emit: geneResults
    tuple val(meta), path("*.isoforms.results"), emit: isoformResults
    path ("versions.txt"), emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def op = meta.singleEnd ? "" : "--paired-end"

    """
    echo \$(rsem-calculate-expression --version 2>&1) > versions.txt

    rsem-calculate-expression -p ${task.cpus} \
			--alignments \
			--estimate-rspd \
			--append-names \
			--no-bam-output \
			--strandedness $params.stranded \
			$txBam \
			$params.rsemRef \
			$meta.id \
            $op \

    """
}