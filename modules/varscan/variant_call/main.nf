process VARSCAN {
	tag "${Sample}"
	label 'process_medium'
	input:
		tuple val (Sample), file(bam), file (bamBai)
		path (GenFile)
		path (GenDir)
		file (bedfile)
	output:
		tuple val(Sample), file("${Sample}.varscan.vcf")
	script:
	"""
	samtools mpileup -d 1000000 -B -A -l ${bedfile} -f ${GenFile} ${bam} > ${Sample}.mpileup
	java -Xmx${task.memory.toGiga()}g -jar /usr/local/bin/VarScan.v2.3.9.jar  mpileup2indel ${Sample}.mpileup --min-reads2 1 --min-avg-qual 5 --min-var-freq 0.000001 --p-value 1e-1 --output-vcf 1 > ${Sample}.varscan_indel.vcf
	bgzip -c ${Sample}.varscan_indel.vcf > ${Sample}.varscan_indel.vcf.gz
	bcftools index -t ${Sample}.varscan_indel.vcf.gz
	bcftools concat -a ${Sample}.varscan_indel.vcf.gz -o ${Sample}.varscan.vcf
	"""
}