process MINIMAP {
	tag "${Sample}"
	label 'process_medium'
	publishDir "${params.outdir}/${Sample}/", mode: 'copy', pattern: '*_getitd'
	input:
		tuple val(Sample), file(read1), file(read2)
		file (minimap_getitd_reference)
	output:
		tuple val (Sample), path ("${Sample}.sam")
	script:
	"""
	minimap2 -ax sr -t ${task.cpus} ${minimap_getitd_reference} ${read1} ${read2} > ${Sample}.sam
	"""
}