process COMBINE_FLT3 {
	tag "${Sample}"
	publishDir "${params.outdir}/${Sample}/", mode: 'copy', pattern: '*.xlsx'
	input:
		tuple val (Sample),  file(filt3r_json_csv), file(varscan_csv), file(filt3r_csv), path (getitd_dir), file(ext_vcf), file (coverage)
	output:
		tuple val (Sample), file("${Sample}_ext.tsv"), file("${Sample}.xlsx")
	script:
	"""
	flt3_ext_format.py -v ${ext_vcf} -o ${Sample}_ext.tsv

	if [ -s ${getitd_dir}/itds_collapsed-is-same_is-similar_is-close_is-same_trailing.tsv ]; then
			GETITD_OUT="${getitd_dir}/itds_collapsed-is-same_is-similar_is-close_is-same_trailing.tsv"
	else
			touch itds_collapsed-is-same_is-similar_is-close_is-same_trailing.tsv
			GETITD_OUT="itds_collapsed-is-same_is-similar_is-close_is-same_trailing.tsv"
	fi
	combine_flt3.py -s ${Sample} -j ${filt3r_json_csv} -f ${filt3r_csv} -v ${varscan_csv} -g \$GETITD_OUT -x ${Sample}_ext.tsv -c ${coverage} -o ${Sample}.xlsx
	"""
}
