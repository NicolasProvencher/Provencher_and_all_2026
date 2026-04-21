#!/bin/bash
#SBATCH --account=def-xroucou
#SBATCH --mem=30G
#SBATCH --time=23:00:00
#SBATCH --cpus-per-task=8
#SBATCH --mail-user=nicolas.provencher@usherbrooke.ca
#SBATCH --mail-type=ALL

#this script builds a bowtie2 index for the contaminant transcriptome, the path of the output index need to be set in the nextflow config file
module load bowtie2

bowtie2-build reference/HS/contaminant_transcriptome.fa reference/HS/contaminant_transcriptome_index
