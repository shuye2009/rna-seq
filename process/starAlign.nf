/*
 * STAR reads alignment
 */

process starAlign {
  tag "$meta.id"
  label 'star'
  label 'medCpu'
  label 'extraMem'

  input:
  tuple val(meta), path(reads)
  val index
  val gtf

  output:
  tuple val(meta), path('*Aligned.out.bam'), emit: bam
  path ("*out"), emit: logs
  path ("versions.txt"), emit: versions
  tuple val(meta), path("*ReadsPerGene.out.tab"), optional: true, emit: counts
  path("*out.tab"), optional: true, emit: countsLogs
  tuple val(meta), path("*Aligned.toTranscriptome.out.bam"), optional: false, emit: transcriptsBam

  when:
  task.ext.when == null || task.ext.when

  script:
  def args = task.ext.args ?: ''
  def prefix = task.ext.prefix ?: "${meta.id}_"
  

  """
  if [ -e ${params.tmpDir}/star_\$(date +%d%s%S%N) ]; then
    rm -rf "${params.tmpDir}/star_\$(date +%d%s%S%N)"
  fi
  
  echo "STAR "\$(STAR --version 2>&1) > versions.txt
  
  STAR	--runThreadN ${task.cpus} \
	--runMode alignReads \
	--genomeDir $index \
	--sjdbGTFfile $gtf \
	--sjdbOverhang 100 \
	--sjdbGTFfeatureExon exon \
	--sjdbGTFtagExonParentTranscript transcript_id \
	--sjdbGTFtagExonParentGene gene_id \
	--readFilesIn $reads \
	--readFilesCommand zcat \
	--outFileNamePrefix $prefix \
	--outSAMtype BAM Unsorted\
	--outFilterMismatchNmax 2 \
	--quantMode GeneCounts TranscriptomeSAM \
	--twopassMode Basic \
  --limitOutSJoneRead 2000 \
  --limitOutSJcollapsed 3000000 \
	--limitIObufferSize 30000000, 50000000 \
  --limitSjdbInsertNsj 3000000 \
	--limitBAMsortRAM 10000000000 \
  --outTmpDir "${params.tmpDir}/star_\$(date +%d%s%S%N)"  \
  ${args}

  """
}
