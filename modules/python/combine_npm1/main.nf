process COMBINE_NPM1 {
	tag "${Sample}"
	label 'process_low'
	publishDir "${params.outdir}/${Sample}/", mode: 'copy', pattern: '*.xlsx'
	input:
		tuple val (Sample), file(varscan_csv), file(coverage)
	output:
		tuple val (Sample), file("${Sample}.xlsx")	
	script:
	"""
	combine_npm1.py ${Sample}.xlsx ${varscan_csv} ${coverage}
	"""	
}
