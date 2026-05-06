This repository accompanies the publication of a paper that generates a MS protein database containing microproteins to be used in routine MS analysis.

It contains the code used to identify active transcript initiation sites detected from Ribosome Profiling analyses and add them to the training data of the transformer based proteome annotator TIS Transformer.

This repository's main goal is to share the details of the pipeline.

# TIS Transformer script
the add_tis.py script is a script that takes a csv with columns transcript_id and TIS_pos containing a ensembl transcript ID and a tis position to be added to the TIS Transformer h5 database between the data and inference step

# Ribotie Pipeline

The ribosome profiling pipeline was built using Nextflow and uses Ribotie as an ORF caller. The pipeline is organized into several modules, including quality control (QC), alignment, and downstream analysis. Ribotie needs a gpu to fonction.

This pipeline was designed to run on Digital Research Alliance of Canada's High Performance Computing (HPC) environment.

**Note for reproductibility:** Some scripts (e.g., shell scripts for indexing or alignment) will require modifications to be run on your computing ressources. If you want to use the pipeline, don't forget to review and update paths, module loads, or command-line options as needed to match your environment.

# MS fastas

The original swissprot fasta and the fasta containing the predicted Microproteins merged with swissprot are also shared

Feels free to use them for you own analyses


## Directory Structure
Each subdirectories contains a .nf script file and a nextflow.config file for each steps of the pipeline

- the folder `QC/` contains the code used to do the Download of the files, the Quality Control and trimming of the Fastq files
- the folder `Align/`: contains
  - the pipeline script `filter_align.nf` that implements the filtering and transcriptome alignement of the reads,
  - the files `bowtiie_index.sh` and `star_index.sh` that were used to generate the contaminant and human genome alignement indexs
- the folder `Ribotie/`: Contains the ORF calling part of the pipeline though the usage of ribotie, the main pipeline script is `ribotie.nf`)
- the folder `Samplesheet_example/`: contains the sample sheet used as input for the pipeline with the column `Trim_arg` containing the Args needed to correctly trim the reads for each file determined manually from the QC reports
- `multiqc_custom_config.yaml` is a file splitting pre and post trim report inside MultiQC 
- `env.yml`: Conda environment specification
- `add_tis.py` is a python script used to add the called ORFs tis positions in the TIS Transformer H5 database

## For reproductibility

1. Clone this repository.
2. Prepare your sample sheet (see `Samplesheet_example/all_human.csv`).
3. **Edit the `nextflow.config` files** in each module directory (`QC/`, `Align/`, `Ribotie/`) to adapt paths and resource settings to your HPC environment.
4. Run the desired workflow with Nextflow, for example:
    ```sh
    nextflow run QC/Download_QC_trim.nf -profile <your_profile>
    ```


## Contact

For questions or issues related to this repo, don't hesitate to open an issue 

