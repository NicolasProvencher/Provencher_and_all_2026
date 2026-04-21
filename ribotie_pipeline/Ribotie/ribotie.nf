// Tis is the ribotie running script
// Ive found using this large scale that the ribotie gpu step is generaly way quicker than expected (a few minute) as such 
// if i had to redo id group the files by study and run multiple in the same job instead of 1 per job preventing HPC conflict while building the env to fast too many times
process RIBOTIE_DATA {
    beforeScript 'module load python/3.11 cuda/12.2 cudnn/9.2 arrow/21.0'
    publishDir "${projectDir}/../output/${meta.sp}/${meta.GSE}_${meta.drug}_${meta.sample_type}/${meta.GSM}/ribotie", mode: 'link', overwrite: true
    cache 'lenient'
    tag "${meta.GSM}"

    input:
    tuple val(meta), file(Transcriptome_Bam)
    
    output:
    val(meta), emit: meta
    path("${meta.GSM}.h5"), emit: h5_db
    path(Transcriptome_Bam), emit: transcriptome_bam
    
    script:
    """
    # Prepare the environment
    virtualenv --no-download \$SLURM_TMPDIR/env
    source \$SLURM_TMPDIR/env/bin/activate
    pip install --no-index ${params.ribotie_package}
    mkdir -p \$SLURM_TMPDIR/${meta.GSM}
    cp ${params.reference_files_directory}/HS/Homo_sapiens.GRCh38.114.h5 \$SLURM_TMPDIR/${meta.GSM}/${meta.GSM}.h5

    ribotie --data \
        --cores 1 \
        --gtf_path ${params.annotation_GTF[meta.sp]} \
        --fa_path ${params.dna_assembly[meta.sp]} \
        --h5_path \$SLURM_TMPDIR/${meta.GSM}/${meta.GSM}.h5 \
        --out_prefix ${meta.GSM} \
        --ribo_paths '{"${meta.GSM}": "${Transcriptome_Bam}"}' \
        --samples ${meta.GSM} \

    ls \$SLURM_TMPDIR/${meta.GSM}
    cp \$SLURM_TMPDIR/${meta.GSM}/* \$PWD

    """
}


process RIBOTIE_ML {
    tag "${meta.GSM}"
    beforeScript 'module load python/3.11 cuda/12.2 cudnn/9.2 arrow/21.0'
    publishDir "${projectDir}/../output/${meta.sp}/${meta.GSE}_${meta.drug}_${meta.sample_type}/${meta.GSM}/ribotie/results", mode: 'link', overwrite: true
    cache 'lenient'

    input:
    val(meta)
    path(h5_db)
    path(Transcriptome_Bam)


    output:
    val(meta), emit: meta
    path("*")
    
    script:
    """
    # Prepare the environment
    virtualenv --no-download \$SLURM_TMPDIR/env
    source \$SLURM_TMPDIR/env/bin/activate
    pip install --no-index ${params.ribotie_package}
    mkdir -p \$SLURM_TMPDIR/${meta.GSM}
    cp ${h5_db} \$SLURM_TMPDIR/${meta.GSM}/${meta.GSM}.h5

    ribotie \
        --gtf_path ${params.annotation_GTF[meta.sp]} \
        --fa_path ${params.dna_assembly[meta.sp]} \
        --h5_path \$SLURM_TMPDIR/${meta.GSM}/${meta.GSM}.h5 \
        --out_prefix ${meta.GSM} \
        --ribo_paths '{"${meta.GSM}": "${Transcriptome_Bam}"}' \
        --samples ${meta.GSM} \


    ls \$SLURM_TMPDIR/${meta.GSM}
    cp \$SLURM_TMPDIR/${meta.GSM}/* \$PWD
    """
}
workflow {
    // creates a channel to track trimmed files
    trimmed_files_ch = Channel
        .fromPath("${projectDir}/../output/*/*/*/star/*_Aligned.toTranscriptome.out.bam")
        .map { file -> 
            def gsm = file.simpleName.split('_')[0]
            [gsm, file]  // Named tuple
        }
    // main metadata channel used to drive the workflow
    metadata_ch = Channel
        .fromPath(params.input_csv)
        .splitCsv(header: true)
        .flatMap { row -> 
            row.Sample_accession
                .split(';')
                .collect { it.trim() }
                .collect { gsm -> 
                    [gsm, [
                        GSE: row.Study_accession,
                        GSM: gsm,
                        drug: row.Drug,
                        sample_type: row.Biological_type,
                        trimming_args: row.Trim_arg,
                        paired_end: row.paired_end.toBoolean(),
                        sp: row.Species
                    ]]
                }
        }
    // filtering to exclude samples that do not have trimmed files
    joined_ch = metadata_ch.join(trimmed_files_ch, by: 0, remainder: true)

    matched_ch = joined_ch
        .filter { it[2] != null && it[1] != null }
        .map { [ it[1], it[2]] } // [META, FILE]

    missing_files_ch = joined_ch
        .filter { it[2] == null && it[1] != null }
        .map { [it[0], it[1]] } // [GSM, META]



    missing_files_ch.view { a, b -> "missing_files_ch: ${a} - ${b}" }
    RIBOTIE_DATA(matched_ch)
    RIBOTIE_ML(RIBOTIE_DATA.out)
}
