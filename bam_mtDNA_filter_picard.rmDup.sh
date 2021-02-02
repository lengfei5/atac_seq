##########################################
# This script is to filter bam and find statistics for Bam files: 
# number of total, mapped, unique, after duplication removed reads
# Here the duplication removal is using picard that is taking really big memory 18-30G
# which is a little bit weird
# to adapt the script for axolotl genome, the duplication removal is done by 
# picard/2.20.6--0-biocontainers from bioinfo group; the early version does not work 
# 
#########################################
while getopts ":hp" opts; do
    case "$opts" in
        "h")
	    echo "script to filter low quality mapped reads, remove duplicates for bams files for atac-seq"
            echo "old version used samtools to remove duplicates; and the current version is using PICARD"
	    echo 'lastest version employed samtools again, becasue PICARD does not work for axolotl genome'
	    echo "Usage:"
	    echo "$0 (single_end bam)"
            echo "$0 -p (paired_end bam)"
	    exit 0
	    ;;
	"p")
	    PAIRED="TRUE"
	    ;;
	"?")
            echo "Unknown option $opts"
            ;;
        ":")
            echo "No argument value for option $opts"
            ;;
    esac
done

nb_cores=16
MAPQ_cutoff=30

DIR_input="${PWD}/alignments/BAMs_All"

DIR_rmChrM=${PWD}/alignments/BAMs_rmChrM
DIR_rmdup="${PWD}/alignments/BAMs_uniq"
DIR_rmdup_uniq="${PWD}/alignments/BAMs_uniq_rmdup"
DIR_stat="${PWD}/QCs/BamStat"
DIR_frag=${PWD}/QCs/frag_sizes
DIR_logs=${PWD}/logs

mkdir -p $DIR_logs
mkdir -p $DIR_rmChrM
mkdir -p $DIR_rmdup
mkdir -p $DIR_rmdup_uniq
mkdir -p $DIR_stat
mkdir -p $DIR_frag

jobName='bam.filtering'
#picardPath=$EBROOTPICARD
#echo $picardPath

#for file in ${DIR_input}/*.bam
for file in ${DIR_input}/Embryo_Stage44_distal_93323.bam
do
    echo $file
    ff="$(basename $file)"
    ff="${ff%.bam}"
    fname=$ff;
    
    #echo $newb
    bm=${DIR_rmChrM}/${ff}_rmChrM
    newb=$DIR_rmdup/${ff}_uniq
    newbb=$DIR_rmdup_uniq/${ff}_uniq_rmdup
    
    stat=${DIR_stat}/${ff}_stat.txt
    frag_size=${DIR_frag}/${ff}_picard.frag.size
    
    #echo $newb 
    #echo $newbb 
    #echo $stat
    #picardDup_QC=${DIR_stat}/${ff}_picardDup.qc.txt
    
    # creat the script for each sample
    script=$DIR_logs/${fname}_${jobName}.sh
    cat <<EOF > $script
#!/usr/bin/bash

#SBATCH --cpus-per-task=$nb_cores
#SBATCH --time=300
#SBATCH --mem=64G

#SBATCH --ntasks=1
#SBATCH --nodes=1
#SBATCH -o $DIR_logs/${fname}.out
#SBATCH -e $DIR_logs/${fname}.err
#SBATCH --job-name $jobName

module load samtools/1.10-foss-2018b
ml load picard/2.20.6--0-biocontainers

# filter reads from mtDNA
samtools view -@ $nb_cores -h ${file} | grep -v chrM | samtools sort -@ $nb_cores -O bam -o ${bm}.bam

# filter low quality reads 
samtools view -@ $nb_cores -h -q 30 $file > ${newb}.unsorted.bam
samtools sort -@ $nb_cores -o ${newb}.bam ${newb}.unsorted.bam
samtools index -c -m 14 ${newb}.bam 
rm ${newb}.unsorted.bam

# remove duplicates
if [ ! -e $newbb.bam ]; then
   picard MarkDuplicates INPUT=$newb.bam OUTPUT=${newbb}.unsorted.bam METRICS_FILE=${newbb}_picard.rmDup.txt \
ASSUME_SORTED=true REMOVE_DUPLICATES=true SORTING_COLLECTION_SIZE_RATIO=0.2
fi;

if [ ! -e $newbb.bam.bai ]; then
   samtools sort -@ $nb_cores -o ${newbb}.bam ${newbb}.unsorted.bam
   samtools index -c -m 14 $newbb.bam;
fi;

echo 'done duplication removal...'

# save statistical number for intermediate and final bam files
echo 'sample total mapped rmChrM uniq rmdup_uniq' |tr ' ' '\t' > $stat 

total=\$(samtools view -@ $nb_cores -c $file); 
mapped=\$(samtools view -@ $nb_cores -c -F 4 $file);
rmChrM=\$(samtools view -@ $nb_cores -c -F 4 $bm.bam); 
uniq=\$(samtools view -@ $nb_cores -c $newb.bam); 
uniq_rmdup=\$(samtools view -@ $nb_cores -c $newbb.bam); 
echo $ff \$total \$mapped \$rmChrM \$uniq \$uniq_rmdup |tr ' ' '\t' >> $stat 

# fragment size distribution by picard
picard CollectInsertSizeMetrics HISTOGRAM_FILE=${frag_size}.pdf OUTPUT=${frag_size}.txt \\
METRIC_ACCUMULATION_LEVEL=ALL_READS INCLUDE_DUPLICATES=false INPUT=$newbb.bam

# frgment size by samtools 
#samtools stat -@ $nb_cores ${file} | grep ^IS | cut -f 2- > ${insertion_size}.txt
#samtools stat -@ $nb_cores ${newbb}.bam | grep ^IS | cut -f 2- > ${insertion_size}_uniq.rmdup.txt

EOF
    
    cat $script
    sbatch $script
    #break;
    
done
