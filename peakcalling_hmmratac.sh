####################
# test new peak caller hmmratac
####################
jobName='hmmratac'
nb_cores=8

DIR_input="${PWD}/bams_used"
DIR_output="${PWD}/calledPeaks/hmmratac"
dir_logs=$PWD/logs
echo $DIR_input
echo $DIR_output

mkdir -p $DIR_output;
mkdir -p $dir_logs

for file in ${DIR_input}/*.bam;
do
    echo $file
    fname="$(basename $file)"
    file_output=${fname%.bam}
    
    script=${dir_logs}/${jobName}_${fname}.sh
    cat <<EOF > $script
#!/usr/bin/bash

#SBATCH --cpus-per-task=$nb_cores
#SBATCH --time=240
#SBATCH --mem=32G
#SBATCH --ntasks=1
#SBATCH --nodes=1
#SBATCH -o ${dir_logs}/$(basename $file).${jobName}.out
#SBATCH -e ${dir_logs}/$(basename $file).${jobName}.err
#SBATCH --job-name $jobName

ml load hmmratac/1.2.10-java-11.0.2
ml load samtools/1.10-foss-2018b
samtools view -H ${file}| perl -ne 'if(/^@SQ.*?SN:(\w+)\s+LN:(\d+)/){print \$1,"\t",\$2,"\n"}' > ${DIR_output}/${file_output}.genome.info
 
java -jar \$EBROOTHMMRATAC/HMMRATAC_V1.2.10_exe.jar -b ${file} -i ${file}.bai -g ${DIR_output}/${file_output}.genome.info -o ${DIR_output}/${file_output}_hmmratac

awk -v OFS="\t" '\$13>=10 {print}' ${DIR_output}/${file_output}_hmmratac_peaks.gappedPeak >  ${DIR_output}/${file_output}_hmmratac.filteredPeaks.gappedPeak

EOF
    
    cat $script;  
    sbatch $script
    
    break;
    
done
