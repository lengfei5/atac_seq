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

fimo --thresh 0.0001 --oc fimo_out /groups/cochella/jiwang/Databases/motifs_TFs/PWMs_C_elegans/All_PWMs_JASPAR_CORE_2016_TRANSFAC_2015_CIS_BP_2015.meme /groups/cochella/jiwang/Databases/motifs_TFs/background_cel_promoters/ce11_promoter_2kb.fa

