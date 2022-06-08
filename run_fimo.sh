#!/usr/bin/bash

#SBATCH --cpus-per-task=1
#SBATCH --time=8:00:00
#SBATCH --mem=16G
#SABTCH --qos=short
#SBATCH --ntasks=1
#SBATCH --nodes=1
#SBATCH -o fimo.out
#SBATCH -e fimo.err
#SBATCH --job-name fimo

ml load meme/5.1.1-foss-2018b-python-3.6.6
ml load bedtools/2.27.1-foss-2018b

outDir='FIMO_atacPeak_tss'
mkdir -p $outDir

echo 'sort bed file'
bedtools sort -i peaks/atacPeaks_2kbtss_for_fimo.bed > ${outDir}/peaks_for_fimo_sorted.bed

echo 'get fasta file '
bedtools getfasta -fi /groups/tanaka/People/current/jiwang/Genomes/axolotl/AmexG_v6.DD.corrected.round2.chr.fa \
	 -bed ${outDir}/peaks_for_fimo_sorted.bed > ${outDir}/peaks_for_fimo.fa 

echo 'start fimo '
fimo --thresh 0.0001 \
     --oc ${outDir}/fimo_out \
     /groups/tanaka/People/current/jiwang/Databases/motifs_TFs/JASPAR2022/JASPAR2022_CORE_vertebrates_nonRedundant.meme \
     ${outDir}/peaks_for_fimo.fa
