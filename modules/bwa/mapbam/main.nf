process MAPBAM {
	publishDir "${params.outdir}/${Sample}/", mode: 'copy', pattern : '*bam*'
	tag "${Sample}"
	label 'process_medium'
	input:
		tuple val (Sample), file (trim1), file (trim2)
		path (GenFile)
		path (GenDir)
	output:
		tuple val (Sample), file ("${Sample}.bam"), file ("${Sample}.bam.bai")
	script:
	"""
	bwa mem -R "@RG\\tID:AML\\tPL:ILLUMINA\\tLB:LIB-MIPS\\tSM:${Sample}\\tPI:300" \
		-t ${task.cpus} ${GenFile} ${trim1} ${trim2} | \
	samtools sort -@ ${task.cpus} -o ${Sample}.bam -

	samtools index  ${Sample}.bam > ${Sample}.bam.bai
	"""
}
