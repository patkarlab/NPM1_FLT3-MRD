process BAM_TO_FASTQ { 
	tag "${Sample}"
	label 'process_medium'
	input:
		tuple val(Sample), file(bam)
	output:
		tuple val (Sample), path("${Sample}_chr13.fastq")
	script:
	"""
	bedtools bamtofastq -i ${Sample}.chr13.bam -fq ${Sample}_chr13.fastq
	"""
}