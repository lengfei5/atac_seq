###############
## this script is to trim the adaptors for atac-seq (paired_end fastq files) in the same way as Daugherty et al. and Buenrostro et al. 
## because here we used the modified code from the original paper by Buenrostro JD
###############
nb_cores=6
cwd=`pwd`
trim_adaptor="/home/imp/jingkui.wang/scripts/atac_seq/pyadapter_trim.py"

DIR_input="${cwd}/ngs_raw/FASTQs_toTrimmed"
DIR_trimmed="${cwd}/ngs_raw/FASTQs"
#echo $DIR_input
#echo $DIR_trimmed

mkdir -p "${cwd}/logs"
mkdir -p $DIR_trimmed

#for file in ${DIR_input}/*.fastq;
cd $DIR_input;
for file in `ls *.fastq| rev |cut -f2- -d "_"|rev|sort -u `
do
    echo $file
    #trimmed="${file%.fastq}_trimmed.fastq"
    #echo $trimmed
    qsub -q public.q -o ${cwd}/logs -j yes -pe smp $nb_cores -cwd -b y -shell y -N trimming "module load python; python ${trim_adaptor} -a ${file}_R1.fastq -b ${file}_R2.fastq; mv ${file}_R1.trim.fastq $DIR_trimmed; mv ${file}_R2.trim.fastq $DIR_trimmed; "

done
cd $cwd;