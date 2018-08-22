###############
# this script is to trim the adaptors for atac-seq (paired_end fastq files) in the same way as Daugherty et al. and Buenrostro et al. 
# because here we used the modified code from the original paper by Buenrostro JD
# updated new version : after asking Elin, we use the cutadapt using the adatpor sequence
###############
nb_cores=8
cwd=`pwd`
trim_adaptor="/home/imp/jingkui.wang/scripts/atac_seq/pyadapter_trim.py"

DIR_input="${cwd}/ngs_raw/FASTQs_toTrim"
DIR_trimmed="${cwd}/ngs_raw/FASTQs"

## those are the adopters for atac-seq data (I guess it should be the same but double check)
params_a="CTGTCTCTTATACACATCTCCGAGCCCACGAGAC" # forward pair
params_A="CTGTCTCTTATACACATCTGACGCTGCCGACGA" # reverse pair
#params_A="GATCGGAAGAGCACACGTCTGAACTCCAGTCAC";
#params_a=$params_A;

params_min_length=5 # should be at least 5bp left after trim
params_overlap=1 #1bp overlapping the adaptor is enough 

mkdir -p "${cwd}/logs"
mkdir -p $DIR_trimmed

#for file in ${DIR_input}/*.fastq;
cd $DIR_input;
for file in `ls *.fastq| rev |cut -f2- -d "_"|rev|sort -u `
do
    echo $file
    #trimmed="${file%.fastq}_trimmed.fastq"
    #echo $trimmed
    #qsub -q public.q -o ${cwd}/logs -j yes -pe smp $nb_cores -cwd -b y -shell y -N trimming "module load python; \
    #python ${trim_adaptor} -a ${file}_R1.fastq -b ${file}_R2.fastq; mv ${file}_R1.trim.fastq $DIR_trimmed; mv ${file}_R2.trim.fastq $DIR_trimmed; "
    qsub -q public.q -o ${cwd}/logs -j yes -pe smp $nb_cores -cwd -b y -shell y -N trimming "\
module load python; \
module load cutadapt/1.12.0; \
cutadapt --minimum-length ${params_min_length} --overlap ${params_overlap} -a ${params_a} -A ${params_A} \
-o ${file}_R1.trim.fastq -p ${file}_R2.trim.fastq ${file}_R1.fastq ${file}_R2.fastq > ${cwd}/logs/${file}.cutadapt.log; \
mv ${file}_R1.trim.fastq $DIR_trimmed; mv ${file}_R2.trim.fastq $DIR_trimmed; "

done
cd $cwd;
