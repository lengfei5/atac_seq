####################
# Count reads of RNA-seq data using featureCounts
# Here teh gtf files used has all annotation including non-coding regions and miRNAs
# because we want to counts reads not only for gene features but also biotypes (e.g. protein coding genes and miRNAs)
####################
GTF="/groups/bell/jiwang/Genomes/C_elegans/WBcel235/Sequence_Annotation/Caenorhabditis_elegans.WBcel235.88.gtf"
# only protein coding genes
#GTF='/groups/cochella/jiwang/annotations/Caenorhabditis_elegans.WBcel235.88_proteinCodingGenes.gtf'

nb_cores=1
jobName='featurecounts'
format=bam
strandSpec=1;
cutoff_quality=10
#mode="intersection-nonempty"
#ID_feature="gene_id"

DIR=`pwd`
DIR_input="${DIR}/BAMs"
DIR_output="${DIR}/featurecounts_Q_${cutoff_quality}"
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
#SBATCH --time=120
#SBATCH --mem=6000
#SBATCH --ntasks=1
#SBATCH --nodes=1
#SBATCH -o ${dir_logs}/$(basename $file).out
#SBATCH -e ${dir_logs}/$(basename $file).err
#SBATCH --job-name $jobName

module load subread/1.5.0-p1-foss-2017a

featureCounts -t exon -a $GTF -Q $cutoff_quality -g gene_id \
-o ${DIR_output}/${file_output}_gene.featureCounts.txt \
-s $strandSpec $file; \
featureCounts -t exon -a $GTF -Q $cutoff_quality -g gene_biotype \
-o ${DIR_output}/${file_output}_biotype.featureCounts.txt \
-s $strandSpec $file; \
cut -f 1,7 ${DIR_output}/${file_output}_biotype.featureCounts.txt | tail -n +3 \
> ${DIR_output}/${file_output}_biotype.summary.txt;

EOF

    cat $script;  
    sbatch $script
    #break;
done
