##############################
# this script is to downsample a bam file 
# make BigWig files using container-based deeptools 
#############################
nb_cores=16

jobName='downsampling'
dir_logs=${PWD}/logs

OUT="${PWD}/saturation/bams_downsampled"
dir_bam="$PWD/bams_merged"

mkdir -p $OUT
mkdir -p $dir_logs

for bam in ${dir_bam}/*.bam
do
    
    for frac in `seq 0.1 0.05 1.0`
    do
	fname="$(basename $bam)"
	fname="${fname%.bam}"
	fname=${fname/\#/\_}_downsampled.${frac}
	bam_out=${OUT}/${fname}
	
	echo $bam_out
	echo $frac
	
	script=${dir_logs}/${fname}_${jobName}.sh	
cat <<EOF > $script
#!/usr/bin/bash

#SBATCH --cpus-per-task=$nb_cores
#SBATCH --time=360
#SBATCH --mem=32G
#SBATCH --ntasks=1
#SBATCH --nodes=1
#SBATCH -o ${dir_logs}/${fname}.${jobName}.out
#SBATCH -e ${dir_logs}/${fname}.${jobName}.err
#SBATCH --job-name $jobName

module load samtools/1.10-foss-2018b;
	
if [ ${frac} == 1.0 ]; then
   
   cp $bam ${bam_out}_unsorted.bam	
else 
   samtools view -s $frac -@ $nb_cores -b $bam > ${bam_out}_unsorted.bam 
fi
	 
samtools sort -@ $nb_cores -o ${bam_out}.bam ${bam_out}_unsorted.bam
samtools index -c -m 14 ${bam_out}.bam;
rm ${bam_out}_unsorted.bam

samtools view -c ${bam_out}.bam > ${bam_out}.bam.counts.txt

EOF
	
	
	#cat $script;
	sbatch $script
	
	#break
   
    done
    #break;
    
done
