#!/usr/bin/env nextflow
nextflow.enable.dsl=2

log.info """
STARTING PIPELINE
=*=*=*=*=*=*=*=*=
Sample list: ${params.input}
BED file: ${params.bedfile}.bed
Sequences in:${params.sequences}
"""

bedfile = file("${params.bedfile}", checkIfExists: true)
illumina_adapters = file("${params.illumina_adapters}", checkIfExists: true )
nextera_adapters = file("${params.nextera_adapters}", checkIfExists: true )
genome_fasta = file("${params.genome}", checkIfExists: true)
ind_files = file("${params.genome_dir}/${params.ind_files}.*")
filt3r_reference = file("${params.filt3r_ref}", checkIfExists: true)
minimap_getitd_reference = file("${params.genome_minimap_getitd}", checkIfExists: true)
filt3r = params.filt3r
varscan = params.varscan

include { TRIM } from './modules/trimmomatic/trim/main.nf'
include { MAPBAM } from './modules/bwa/mapbam/main.nf'
include { FILT3R } from './modules/filt3r/flt3_itd/main.nf'
include { FLT3_ITD_EXT } from './modules/flt3_itd_ext/flt3_itd/main.nf'
include { MINIMAP } from './modules/minimap/align/main.nf'
include { MINIMAP_SORT } from './modules/samtools/minimap_sort/main.nf'
include { BAM_TO_FASTQ } from './modules/bedtools/bamtofastq/main.nf'
include { GETITD } from './modules/getitd/flt3_itd/main.nf'
include { COVERAGE } from './modules/bedtools/counts/main.nf'
include { ANNOVAR as ANNOVAR_VARSCAN; ANNOVAR as ANNOVAR_FILT3R } from './modules/annovar/annotate/main.nf'
include { VARSCAN } from './modules/varscan/variant_call/main.nf'
include { FORMAT_FLT3 } from './modules/python/format_flt3/main.nf'
include { FORMAT_NPM1 } from './modules/python/format_npm1/main.nf'
include { COMBINE_FLT3 } from './modules/python/combine_flt3/main.nf'
include { COMBINE_NPM1 } from './modules/python/combine_npm1/main.nf'


workflow NPM1_MRD {
	Channel.fromPath(params.input)
		.splitCsv(header:false)
		.map { row ->
			def sample = row[0].trim()
			def r1 = file("${params.sequences}/${sample}_S*_R1_*.fastq.gz", checkIfExists: false)
			def r2 = file("${params.sequences}/${sample}_S*_R2_*.fastq.gz", checkIfExists: false)

			if (!r1 && !r2) {
				r1 = file("${params.sequences}/${sample}*_R1.fastq.gz", checkIfExists: false)
				r2 = file("${params.sequences}/${sample}*_R2.fastq.gz", checkIfExists: false)
			}
			tuple(sample, r1, r2)
		}
		.set { fastq_ch }
	main:
	TRIM(fastq_ch, illumina_adapters, nextera_adapters)
	MAPBAM(TRIM.out, genome_fasta, ind_files)
	COVERAGE(MAPBAM.out, bedfile)
	VARSCAN(MAPBAM.out, genome_fasta, ind_files, bedfile)
	ANNOVAR_VARSCAN(VARSCAN.out, varscan)
	FORMAT_NPM1(ANNOVAR_VARSCAN.out)
	COMBINE_NPM1(FORMAT_NPM1.out.join(COVERAGE.out))
}

workflow FLT3_MRD {
	Channel.fromPath(params.input)
		.splitCsv(header:false)
		.map { row ->
			def sample = row[0].trim()
			def r1 = file("${params.sequences}/${sample}_S*_R1_*.fastq.gz", checkIfExists: false)
			def r2 = file("${params.sequences}/${sample}_S*_R2_*.fastq.gz", checkIfExists: false)

			if (!r1 && !r2) {
				r1 = file("${params.sequences}/${sample}*_R1.fastq.gz", checkIfExists: false)
				r2 = file("${params.sequences}/${sample}*_R2.fastq.gz", checkIfExists: false)
			}
			tuple(sample, r1, r2)
		}
		.set { fastq_ch }
	main:
	TRIM(fastq_ch, illumina_adapters, nextera_adapters)
	MAPBAM(TRIM.out, genome_fasta, ind_files)
	FILT3R(TRIM.out, filt3r_reference)
	ANNOVAR_FILT3R(FILT3R.out.filt3r_vcf, filt3r)
	MINIMAP(fastq_ch, minimap_getitd_reference)
	MINIMAP_SORT(MINIMAP.out)
	BAM_TO_FASTQ(MINIMAP_SORT.out)
	GETITD(BAM_TO_FASTQ.out )
	FLT3_ITD_EXT(TRIM.out)
	COVERAGE(MAPBAM.out, bedfile)
	VARSCAN(MAPBAM.out, genome_fasta, ind_files, bedfile)
	ANNOVAR_VARSCAN(VARSCAN.out, varscan)
	FORMAT_FLT3(ANNOVAR_VARSCAN.out.join(ANNOVAR_FILT3R.out.join(FILT3R.out.filt3r_json)))
	COMBINE_FLT3(FILT3R.out.filt3r_json.join(FORMAT_FLT3.out.varscan_csv.join(FORMAT_FLT3.out.filt3r_csv.join(GETITD.out.join(FLT3_ITD_EXT.out.join(COVERAGE.out))))))
}


workflow.onComplete {
	log.info ( workflow.success ? "\n\nDone! Output in the 'Final_Output' directory \n" : "Oops .. something went wrong" )
	def msg = """\
	Pipeline execution summary
	---------------------------
	Completed at : ${workflow.complete}
	Duration     : ${workflow.duration}
	""".stripIndent()

	println ""
	println msg
}
