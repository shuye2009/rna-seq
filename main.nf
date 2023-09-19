



/*
==========================
 BUILD CHANNELS
==========================
*/
if(params.SRAids){
  chRawReads   = Channel
              .fromSRA( params.SRAids, apiKey: params.ncbi_api_key, protocol: https )
              .map { row ->
                  def meta = [:]
                    meta.id = row[0]
                    if (params.singleEnd) {
                      meta.singleEnd = true
                      return [meta, [row[1]]]
                    }else{
                      meta.singleEnd = false
                      return [meta, [row[1][0], row[1][1]]]
                    }
              }
              .view()
} else if(params.reads){
  chRawReads  = Channel
              .fromFilePairs(params.reads, size: params.singleEnd ? 1 : 2)
              .ifEmpty { "Cannot find any reads matching: ${params.reads}\nNB: Path needs to be enclosed in quotes!\nNB: Path requires at least one * wildcard!\nIf this is single-end data, please specify --singleEnd on the command line." }
              .map { row ->
                  def meta = [:]
                    meta.id = row[0]
                    if (params.singleEnd) {
                      meta.singleEnd = true
                      return [meta, [row[1]]]
                    }else{
                      meta.singleEnd = false
                      return [meta, [row[1][0], row[1][1]]]
                    }
              }
              .view()
}

chStarIndex = Channel
              .value(params.genomeDir)
              .view()
chGtf       = Channel
              .value(params.gtf)
              .view()
  
/*          
==================================
           INCLUDE
==================================
*/
include { fastqc }          from './process/fastqc'
include { starAlign }       from './process/starAlign'
include { trimGalore }      from './process/trimGalore'
include { rsem }            from './process/rsem'

/*

// Workflows

// Processes
include { checkDesign } from './nf-modules/local/process/checkDesign'
include { fastqc }      from './nf-modules/common/process/fastqc'
include { trimBothEnds }  from './nf-modules/common/process/trimBothEnds'
include { bowtie }      from './nf-modules/common/process/bowtie'
include { readCounts }       from './nf-modules/common/process/readCounts'
include { readStats }       from './nf-modules/common/process/readStats'
include { alignStats }       from './nf-modules/common/process/alignStats'
include { cleanup }       from './nf-modules/common/process/cleanup'

include { getSoftwareVersions } from './nf-modules/common/process/utils/getSoftwareVersions'
include { outputDocumentation } from './nf-modules/common/process/utils/outputDocumentation'
//include { multiqc }             from './nf-modules/local/process/multiqc'


process starAlignment {
    input:
    tuple val(sample_id), path(read1), path(read2) from fastq_files

    output:
    path "${sample_id}.Aligned.toTranscriptome.out.bam", emit: bam

    script:
    """
    STAR --runThreadN 4 \
         --genomeDir $params.genomeDir \
         --readFilesIn $read1 $read2 \
         --readFilesCommand zcat \
         --outFileNamePrefix ${sample_id}. \
         --quantMode TranscriptomeSAM
    """
}

process rsemQuantification {
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
}

process deseq2Analysis {
    input:
    path rsem_results from rsemQuantification.out.results.collect()
    path conditions from params.conditions

    output:
    path "deseq2_results.txt", emit: results

    script:
    """
    Rscript --vanilla path/to/deseq2_script.R $rsem_results $conditions deseq2_results.txt
    """
}
*/
workflow {
  
    fastqc(chRawReads)
    trimGalore(chRawReads)
    chTrimmed = trimGalore.out.fastq 
    starAlign(chTrimmed, chStarIndex, chGtf)
    chTxBam = starAlign.out.transcriptsBam
    rsem(chTxBam)
   //deseq2Analysis(rsemQuantification.out.results, params.conditions)
   
}

