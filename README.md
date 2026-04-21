# Ribotie Pipeline

This repository contains a Nextflow-based pipeline for ribosome profiling data analysis using Ribotie as an ORF caller. The pipeline is organized into several modules, including quality control (QC), alignment, and downstream analysis. Ribotie needs a gpu to fonction.

This repository's goal is mainly to share the details used at each step of the pipeline used in the paper 

This pipeline was designed to run on Digital Research Alliance of Canada's High Performance Computing (HPC) environment.

**Note:** Some scripts (e.g., shell scripts for indexing or alignment) will require modifications to be run on your computing ressources. Please review and update paths, module loads, or command-line options as needed to match your environment.


## Structure

- `QC/`: Quality control and preprocessing scripts (e.g., `Download_QC_trim.nf`)
- `Align/`: Alignment scripts and configuration (e.g., `filter_align.nf`, `bowtiie_index.sh`, `star_index.sh`)
- `Ribotie/`: Main ribotie analysis scripts (e.g., `ribotie.nf`)
- `Samplesheet_example/`: sample sheet used for running the pipeline in the paper
- `multiqc_custom_config.yaml`: Custom configuration for MultiQC reports to split pre and post trimming fastqc
- `env.yml`: Conda environment specification


## Requirements

- [Nextflow](https://www.nextflow.io/)
- [Conda](https://docs.conda.io/)
- Java (required for Nextflow, see `env.yml` for version)
- Other bioinformatics tools as specified in `env.yml`

## For reproductibility

1. Clone this repository.
2. Prepare your sample sheet (see `Samplesheet_example/all_human.csv`).
3. **Edit the `nextflow.config` files** in each module directory (`QC/`, `Align/`, `Ribotie/`) to adapt paths and resource settings to your HPC environment.
4. Run the desired workflow with Nextflow, for example:
    ```sh
    nextflow run QC/Download_QC_trim.nf -profile <your_profile>
    ```


## Contact

For questions or issues related to this repo, please contact nicolas.provencher@usherbrooke.ca or open an issue in this repo

