process FORMAT_NPM1 {
	tag "${Sample}"
	label 'process_low'
	input:
		tuple val (Sample), file(varscan_multianno)
	output:
		tuple val (Sample), file("${Sample}.varscan.csv")
	script:
	"""
	if [ -s ${Sample}_varscan.out.hg19_multianno.csv ]; then
		format_varscan.py ${Sample}_varscan.out.hg19_multianno.csv ${Sample}.varscan.csv
	else
		touch ${Sample}.varscan.csv
	fi
	"""
}