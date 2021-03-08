#!/usr/bin/env bash
#SBATCH --job-name="heatmap"
#SBATCH --time=08:00:00
#SBATCH --mem=64GB
#SBATCH --qos=short
#SBATCH --cpus-per-task=16
#SBATCH --partition=c
#SBATCH --output=logs/%x_%j.out
#SBATCH --error=logs/%x_%j.err
#SBATCH --array=1-2

mkdir -p $PWD/logs
mkdir -p $PWD/heatmap_deeptools

bed='merge_peak_usedBams_pval.6_promoters.1000bpUp.200bpDown.bed merge_peak_usedBams_pval.6_nonPromoters.1000bpUp.200bpDown.bed'
Dir_bw='/groups/tanaka/People/current/jiwang/projects/positional_memory/Data/R10723_atac/bigwigs_used/embryo_mature'
bw='$(ls $Dir_bw/*.bw|grep Stage40) $(ls $Dir_bw/*.bw|grep Stage44_proximal) $(ls $Dir_bw/*.bw|grep Stage44_distal) $(ls $Dir_bw/*.bw|grep UA) $(ls $Dir_bw/*.bw|grep LA) $(ls $Dir_bw/*.bw|grep Hand)'

echo $bed
echo $bw
#singularity exec --no-home --home /tmp /groups/tanaka/People/current/jiwang/local/deeptools_master.sif 


