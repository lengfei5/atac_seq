####################
# Count reads of RNA-seq data using featureCounts
# Here teh gtf files used has all annotation including non-coding regions and miRNAs
# because we want to counts reads not only for gene features but also biotypes (e.g. protein coding genes and miRNAs)
####################
while getopts ":hD:p:" opts; do
    case "$opts" in
        "h")
            echo "script to quantify read count from aligned bam files)"
            echo "Two arguments required"
            echo "-D the directory of bam files "
            echo "-p the peak file of format saf for feature count "
            echo "Usage:"
            echo "$0 -D alignments/BAMs_All -p peaks_macs2_merged.saf"
            exit 0
            ;;
        "D")
            DIR_input="$OPTARG";
            ;;
        "p")
            SAF="$OPTARG";
            ;;
        "?")
            echo "Unknown option $opts"
            ;;
        ":")
            echo "No argument value for option $opts"
            ;;
        esac
done

nb_cores=4
jobName='featurecounts'
format=bam
strandSpec=0;
cutoff_quality=30

#SAF="/groups/tanaka/People/current/jiwang/projects/positional_memory/Data/R10723_atac/calledPeaks_pval.0.001/merge_peak.saf"

#DIR=`pwd`
#DIR_input="${PWD}/bams_used"

DIR_output="${PWD}/featurecounts_peaks.Q${cutoff_quality}"
dir_logs=$PWD/logs

echo $DIR_input
echo $DIR_output

mkdir -p $DIR_output;
mkdir -p $dir_logs

for file in ${DIR_input}/*.bam;
do
    echo $file
    fname="$(basename $file)"
    #echo $fname
    file_output=${fname%.bam}
    #echo $file_output

    script=${dir_logs}/$(basename $file)_${jobName}.sh
    cat <<EOF > $script
#!/usr/bin/bash

#SBATCH --cpus-per-task=$nb_cores
#SBATCH --time=30
#SBATCH --mem=2G
#SBATCH --ntasks=1
#SBATCH --nodes=1
#SBATCH -o ${dir_logs}/$(basename $file).featureCounts.out
#SBATCH -e ${dir_logs}/$(basename $file).featureCounts.err
#SBATCH --job-name $jobName

ml load subread/2.0.1-gcc-7.3.0-2.30

featureCounts -F SAF -a ${SAF} -p -Q $cutoff_quality -T $nb_cores \
-o ${DIR_output}/${file_output}_featureCounts.txt \
-s $strandSpec $file; \
-O 

EOF

    cat $script;  
    sbatch $script
    #break;    
done
