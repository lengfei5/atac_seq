####################
# Count reads of RNA-seq data using featureCounts
# Here teh gtf files used has all annotation including non-coding regions and miRNAs
# because we want to counts reads not only for gene features but also biotypes (e.g. protein coding genes and miRNAs)
####################
# only protein coding genes
#GTF='/groups/cochella/jiwang/annotations/Caenorhabditis_elegans.WBcel235.88_proteinCodingGenes.gtf'

nb_cores=8
jobName='featurecounts'
format=bam
strandSpec=0;
cutoff_quality=30
SAF='/groups/tanaka/People/current/jiwang/projects/positional_memory/Data/R10723_atac/calledPeaks_replicates/merge_peak.saf'

#mode="intersection-nonempty"
#ID_feature="gene_id"

DIR=`pwd`
DIR_input="${PWD}/alignments/BAMs_uniq_rmdup"
DIR_output="${DIR}/featurecounts.Q${cutoff_quality}"
dir_logs=$PWD/logs
echo $DIR_input
echo $DIR_output

mkdir -p $DIR_output;
mkdir -p $dir_logs

for file in ${DIR_input}/*.bam;
do
    echo $file
    fname="$(basename $file)"
    #echo $fname
    file_output=${fname%.bam}
    #echo $file_output

    script=${dir_logs}/$(basename $file)_${jobName}.sh
    cat <<EOF > $script
#!/usr/bin/bash

#SBATCH --cpus-per-task=$nb_cores
#SBATCH --time=240
#SBATCH --mem=16G
#SBATCH --ntasks=1
#SBATCH --nodes=1
#SBATCH -o ${dir_logs}/$(basename $file).featureCounts.out
#SBATCH -e ${dir_logs}/$(basename $file).featureCounts.err
#SBATCH --job-name $jobName

ml load subread/2.0.1-gcc-7.3.0-2.30

featureCounts -F SAF -a ${SAF} -p -Q $cutoff_quality -T $nb_cores \
-o ${DIR_output}/${file_output}_featureCounts.txt \
-s $strandSpec $file; \

EOF

    cat $script;  
    sbatch $script
    #break;
    
done
