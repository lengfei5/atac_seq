###############
# this script is to calculate fragment size distribution by PICARD
# 
###############
nb_cores=6
cwd=`pwd`
Genome="/groups/bell/jiwang/Genomes/C_elegans/ce11/ce11_sequence/ce11.chrom.sizes"

DIR_Input="${cwd}/alignments/BAMs_All"
DIR_fragSize="${cwd}/QCs/fragSize_distribution"

DIR_shift="${cwd}/alignments/BAMs_unique_rmdup_shift"
DIR_logs="${DIR_fragSize}/logs"

mkdir -p "${cwd}/logs"
mkdir -p $DIR_fragSize
mkdir -p $DIR_shift
mkdir -p $DIR_logs

#cd $DIR_input;
for file in ${DIR_Input}/*.bam
do
    echo $file
    ff=`basename $file`
    ff=${ff%.bam}
    echo $ff;
    logName=${DIR_logs}/${ff}.log.sh
    echo "
if [ ! -e ${DIR_fragSize}/${ff}_fragSize.txt ]; then 
module load picard-tools/2.6.0; 
module load oracle-jdk/1.8.0_72;
java -jar /biosw/debian7-x86_64/picard-tools/2.6.0/picard.jar CollectInsertSizeMetrics HISTOGRAM_FILE=${DIR_fragSize}/${ff}_fragSize.pdf OUTPUT=${DIR_fragSize}/${ff}_fragSize.txt \\
METRIC_ACCUMULATION_LEVEL=ALL_READS INCLUDE_DUPLICATES=false INPUT=$file;
fi 

if [ ! -e ${DIR_shift}/${ff}_shifted.bam ]; then 
module load bedtools/2.27.1;
module load samtools/0.1.18;

bedtools bamtobed -i $file > ${DIR_shift}/${ff}.bed;
bedtools shift -i ${DIR_shift}/${ff}.bed -g $Genome -p 4 -m -5 > ${DIR_shift}/${ff}_shifted.bed;
bedtools bedtobam -i ${DIR_shift}/${ff}_shifted.bed -g $Genome > ${DIR_shift}/${ff}_shifted.temp.bam;
samtools sort ${DIR_shift}/${ff}_shifted.temp.bam ${DIR_shift}/${ff}_shifted;
samtools index ${DIR_shift}/${ff}_shifted.bam;

# remove intermediate files: bed and bam files
rm ${DIR_shift}/${ff}_shifted.temp.bam;
rm ${DIR_shift}/${ff}.bed;
rm ${DIR_shift}/${ff}_shifted.bed;
fi 
"  > "$logName"
    
    qsub -q public.q -o ${cwd}/logs -j yes -pe smp $nb_cores -cwd -b y -shell y -N fragSize "bash $logName; "
    
    #break;

done
#cd $cwd;