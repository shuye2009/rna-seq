process rsem {
    input:
    tuple val(sample_id), path(bam_file) from starAlignment.out.bam

    output:
    path "${sample_id}.results", emit: results

    script:
    """
    rsem-calculate-expression --bam \
      --no-bam-output \
      --paired-end \
      $bam_file \
      $params.rsemRef \
      ${sample_id}
    """

    rsem-calculate-expression $op \
			--alignments \
			--estimate-rspd \
			--append-names \
			--no-bam-output \
			--strandedness $stranded \
			Aligned.toTranscriptome.out.bam \
			$params.rsemRef \
			rsem_out/$prefix 
}