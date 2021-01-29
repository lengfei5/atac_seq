##############################
# this script is to downsample a bam file 
# make BigWig files using container-based deeptools 
#############################

bam=${PWD}/alignments/BAMs_All/BL_UA_5days_136165_sorted.bam

nb_cores=16
MAPQ_cutoff=30

OUT="${PWD}/bam_downsampling"
jobName='downsampling'
dir_logs=${PWD}/logs

mkdir -p $OUT
mkdir -p $dir_logs

for frac in 0.05 0.1 0.2 0.3 0.5 0.75 
do
    echo $frac
    
    fname="$(basename $bam)"
    fname="${fname%.bam}"
    fname=${fname/\#/\_}_downsampled.${frac}
    
    bam_out=${OUT}/${fname}
    
    wig=${OUT}/${fname}_mq${MAPQ_cutoff}
    echo $bam_out
    echo $wig
    
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

#ml load deeptools/3.3.1-foss-2018b-python-3.6.6;
    
singularity exec --no-home --home /tmp /groups/tanaka/People/current/jiwang/local/deeptools_master.sif bamCoverage \
-b ${bam_out}.bam \
-o ${wig}.bw \
--outFileFormat=bigwig \
--normalizeUsing CPM \
--ignoreDuplicates \
--minMappingQuality $MAPQ_cutoff \
-p ${nb_cores} \
--binSize 100 

EOF

    cat $script;
    sbatch $script
    
    #break
   
done
