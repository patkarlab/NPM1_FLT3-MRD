process MINIMAP_SORT { 
	tag "${Sample}"
	label 'process_medium'
	input:
		tuple val(Sample), file(sam)
	output:
		tuple val (Sample), file ("${Sample}.chr13.bam")
	script:
	"""
	samtools view -@ ${task.cpus} -b -h ${Sample}.sam -o ${Sample}.bam
	samtools sort -@ ${task.cpus} ${Sample}.bam -o ${Sample}.sorted.bam
	samtools index -@ ${task.cpus} ${Sample}.sorted.bam
	samtools view -@ ${task.cpus} ${Sample}.sorted.bam -b -h chr13 > ${Sample}.chr13.bam
	"""
}
