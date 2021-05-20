##############################
# this script is to downsample a bam file 
# make BigWig files using container-based deeptools 
#############################
nb_cores=16

jobName='downsampling'
dir_logs=${PWD}/logs

OUT="${PWD}/raw_downsampled_picard"
dir_bam="$PWD/ngs_raw/BAMs"

mkdir -p $OUT
mkdir -p $dir_logs

for bam in ${dir_bam}/*.bam
do
    
    for frac in `seq 0.1 0.05 1.0`
    #for frac in 0.004 0.01 0.02 0.04
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

ml load samtools/1.10-foss-2018b;
ml load picard/2.20.6--0-biocontainers
	
if [ ${frac} == 1.0 ]; then
   cp $bam ${bam_out}_unsorted.bam	
else 
   #samtools view -s $frac -@ $nb_cores -b $bam > ${bam_out}_unsorted.bam
   picard DownsampleSam I=${bam} Oq=${bam_out}_unsorted.bam P=${frac}
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
