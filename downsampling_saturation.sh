##############################
# this script is to downsample a bam file 
# make BigWig files using container-based deeptools 
#############################

bam=${PWD}/alignments/BAMs_uniq_rmdup/Mature_Hand_74940_uniq_rmdup.bam

nb_cores=16

jobName='downsampling'
dir_logs=${PWD}/logs

OUT="${PWD}/saturation"

mkdir -p $OUT
mkdir -p $dir_logs

for frac in 0.05 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 
do
    echo $frac
    fname="$(basename $bam)"
    fname="${fname%.bam}"
    fname=${fname/\#/\_}_downsampled.${frac}
    bam_out=${OUT}/${fname}

    echo $bam_out
    
    script=${dir_logs}/${fname}_${jobName}.sh	
    
    cat <<EOF > $script
#!/usr/bin/bash

#SBATCH --cpus-per-task=$nb_cores
#SBATCH --time=360
#SBATCH --mem=64G

#SBATCH --ntasks=1
#SBATCH --nodes=1
#SBATCH -o ${dir_logs}/${fname}.${jobName}.out
#SBATCH -e ${dir_logs}/${fname}.${jobName}.err
#SBATCH --job-name $jobName

module load samtools/1.10-foss-2018b;

samtools view -s $frac -@ $nb_cores -b $bam > ${bam_out}_unsorted.bam 
samtools sort -@ $nb_cores -o ${bam_out}.bam ${bam_out}_unsorted.bam
samtools index -c -m 14 ${bam_out}.bam;
rm ${bam_out}_unsorted.bam

samtools view -c ${bam_out}.bam > ${bam_out}.bam.counts.txt

EOF

    cat $script;
    sbatch $script
    
    #break
   
done
