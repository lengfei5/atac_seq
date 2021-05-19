#!/usr/bin/bash

#SBATCH --cpus-per-task=10
#SBATCH --time=480
#SBATCH --mem=32G

#SBATCH --ntasks=1
#SBATCH --nodes=1
#SBATCH -o fimo.out
#SBATCH -e fimo.err
#SBATCH --job-name fimo

ml load meme/5.1.1-foss-2018b-python-3.6.6
ml load bedtools/2.27.1-foss-2018b

mkdir -p FIMO

bedtools sort -i peaks/peaks_for_fimo.bed > FIMO/peaks_for_fimo_sorted.bed

bedtools getfasta -fi /groups/tanaka/People/current/jiwang/Genomes/axolotl/AmexG_v6.DD.corrected.round2.chr.fa \
	 -bed FIMO/peaks_for_fimo_sorted.bed > FIMO/peaks_for_fimo.fa 

fimo --thresh 0.0001 \
     --oc FIMO/fimo_out \
     /groups/tanaka/People/current/jiwang/Databases/motifs_TFs/SwissRegulon_PWMs/hg19_weight_matrices_v2.meme \
     FIMO/peaks_for_fimo.fa

