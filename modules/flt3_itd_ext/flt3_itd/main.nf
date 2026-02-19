process FLT3_ITD_EXT {
	errorStrategy 'ignore'
	tag "${Sample}"
	label 'process_medium'
		publishDir "${params.outdir}/${Sample}/", mode: 'copy', pattern: '*.vcf'
	input:
		tuple val (Sample), file(trim1), file(trim2)
	output:
		tuple val (Sample), file("${Sample}*.vcf")
	script:
	"""
	perl /biosoft/FLT3_ITD_ext/FLT3_ITD_ext.pl -a 0 -f1 ${trim1} -f2 ${trim2} -o ./ -g hg19 -n amplicon
	"""
}
