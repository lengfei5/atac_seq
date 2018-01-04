###############
# this script is to calculate fragment size distribution by PICARD
# 
###############
nb_cores=5
cwd=`pwd`
Genome="/groups/bell/jiwang/Genomes/C_elegans/ce11/ce11_sequence/"

DIR_Input="${cwd}/alignments/BAMs_unique_rmdup"
DIR_fragSize="${cwd}/QCs/fragSize_distribution"
DIR_shift="${cwd}/alignments/BAMs_unique_rmdup_shift"

mkdir -p "${cwd}/logs"
mkdir -p $DIR_fragSize
mkdir -p $DIR_shift

#for file in ${DIR_input}/*.fastq;
#cd $DIR_input;
for file in ${DIR_Input}/*.bam
do
    echo $file
    ff=`basename $file`
    ff=${ff%.bam}
    echo $ff;
    echo qsub -q public.q -o ${cwd}/logs -j yes -pe smp $nb_cores -cwd -b y -shell y -N fragSize "module load picard-tools/2.6.0; module load oracle-jdk/1.8.0_72;\
java -jar /biosw/debian7-x86_64/picard-tools/2.6.0/picard.jar CollectInsertSizeMetrics HISTOGRAM_FILE=${DIR_fragSize}/${ff}_fragSize.pdf OUTPUT=${DIR_fragSize}/${ff}_fragSize.txt \
METRIC_ACCUMULATION_LEVEL=ALL_READS INCLUDE_DUPLICATES=false INPUT=$file;\
module load bedtools/2.27.1;\
module load samtools/0.1.18;\ 
bedtools bamtobed -i $file > ${DIR_shift}/${ff}.bed;\
bedtools shift -i ${DIR_shift}/${ff}.bed -g $Genome -p 4 -m -5 > ${DIR_shift}/${ff}_shifted.bed;\
bedtools bedtobam -i ${DIR_shift}/${ff}_shifted.bed -g $Genome > ${DIR_shift}/${ff}_shifted.temp.bam;\
samtools sort ${DIR_shift}/${ff}_shifted.temp.bam ${DIR_shift}/${ff}_shifted.bam;\
samtools index ${DIR_shift}/${ff}_shifted.bam;\ 
"

done
cd $cwd;