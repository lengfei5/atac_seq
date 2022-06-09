#!/usr/bin/bash
#SBATCH --cpus-per-task=1
#SBATCH --time=0-16:00:00
#SBATCH --mem=16G
#SBATCH --qos=medium
#SBATCH --partition=c
#SBATCH --ntasks=1
#SBATCH --nodes=1
#SBATCH --output=%x_%j.out
#SBATCH --error=%x_%j.err
#SBATCH --job-name fimo

ml load meme/5.1.1-foss-2018b-python-3.6.6
ml load bedtools/2.27.1-foss-2018b

pwm='/groups/tanaka/People/current/jiwang/Databases/motifs_TFs/JASPAR2022/JASPAR2022_CORE_UNVALIDED_vertebrates_nonRedundant.meme'

bed='peaks/atacPeaks_2kbtss_for_fimo_v2.bed'
outDir='FIMO_atacPeak_tss_mediumQ_core.unvalided'

mkdir -p $outDir

echo 'sort bed file'
bedtools sort -i ${bed} > ${outDir}/peaks_for_fimo_sorted.bed

echo 'get fasta file '
bedtools getfasta -fi /groups/tanaka/People/current/jiwang/Genomes/axolotl/AmexG_v6.DD.corrected.round2.chr.fa \
	 -bed ${outDir}/peaks_for_fimo_sorted.bed > ${outDir}/peaks_for_fimo.fa 

echo 'start fimo '
fimo --thresh 0.0001 \
     --oc ${outDir}/fimo_out \
     $pwm ${outDir}/peaks_for_fimo.fa
