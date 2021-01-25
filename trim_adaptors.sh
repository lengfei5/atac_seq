###############
# this script is to trim the adaptors for atac-seq (paired_end fastq files) in the same way as
# Daugherty et al. and Buenrostro et al. 
# because here we used the modified code from the original paper by Buenrostro JD
# 1st update: after asking Elin, we use the cutadapt using the adatpor sequence
# 2nd update: adapted for CBE
###############
trim_adaptor="~/scripts/atac_seq/pyadapter_trim.py"

## those are the adopters for atac-seq data (I guess it should be the same but double check)
params_a="CTGTCTCTTATACACATCTCCGAGCCCACGAGAC" # forward pair
params_A="CTGTCTCTTATACACATCTGACGCTGCCGACGA" # reverse pair
#params_A="GATCGGAAGAGCACACGTCTGAACTCCAGTCAC";
#params_a=$params_A;

# parameters
params_min_length=5 # should be at least 5bp left after trim
params_overlap=1 #1bp overlapping the adaptor is enough 

# folders
DIR=`pwd`
DIR_input="${DIR}/ngs_raw/FASTQs_toTrim"
DIR_trimmed="${DIR}/ngs_raw/FASTQs"

mkdir -p "${DIR}/logs"
mkdir -p $DIR_trimmed

# move to the input folder
cd $DIR_input;
jobName='trimming'

#for file in ${DIR_input}/*.fastq;
for file in `ls *.fastq| rev |cut -f2- -d "_"|rev|sort -u `
do
    echo $file
    fname=$file;
    
    # creat the script for each sample
    script=$PWD/${fname}_${jobName}.sh
    cat <<EOF > $script
#!/usr/bin/bash

#SBATCH --cpus-per-task=1
#SBATCH --time=180
#SBATCH --mem=2G
#SBATCH --ntasks=1
#SBATCH --nodes=1
#SBATCH -o $DIR/logs/$fname.out
#SBATCH -e $DIR/logs/$fname.err
#SBATCH --job-name $jobName

module load python/2.7.15-gcccore-7.3.0-bare;
module load cutadapt/1.18-foss-2018b-python-2.7.15;
cutadapt --minimum-length ${params_min_length} --overlap ${params_overlap} -a ${params_a} -A ${params_A} \
-o ${file}_R1.trim.fastq -p ${file}_R2.trim.fastq ${file}_R1.fastq ${file}_R2.fastq > ${DIR}/logs/${file}.cutadapt.log;

mv ${file}_R1.trim.fastq $DIR_trimmed;
mv ${file}_R2.trim.fastq $DIR_trimmed;

EOF

    cat $script;
    sbatch $script
    #break;
    
done

cd $DIR;
