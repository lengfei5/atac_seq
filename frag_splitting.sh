##############################
# this script is to downsample a bam file 
# make BigWig files using container-based deeptools 
#############################

dir_bam=${PWD}/alignments/BAMs_rmChrM

nb_cores=16
MAPQ_cutoff=30

OUT="${PWD}/alignments/bams_split_fragSize"

jobName='splitting_frag'
dir_logs=${PWD}/logs

mkdir -p $OUT
mkdir -p $dir_logs

for bam in ${dir_bam}/*.bam 
do
        
    fname="$(basename $bam)"
    fname="${fname%.bam}"
    fname=${fname/\#/\_}
    
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

samtools view -h $bam | awk '(\$9 <= 100 && \$9 >= -100) || \$1 ~ /^@/' | samtools view -bS > ${bam_out}.sized100.bam

samtools view -h $bam | awk '(\$9>= 180 && \$9<=240) || (\$9<=-180 && \$9>=-240) || \$1 ~ /^@/' | samtools view -bS > ${bam_out}.sized180.240.bam


samtools view -h $bam | awk '\$9>= 250 || \$9<=-250 || \$1 ~ /^@/' | samtools view -bS > ${bam_out}.sized250.bam

samtools index -c -m 14 ${bam_out}.sized180.240.bam
samtools index -c -m 14 ${bam_out}.sized100.bam
samtools index -c -m 14 ${bam_out}.sized250.bam


EOF

    cat $script;
    sbatch $script
    
    #break
   
done
