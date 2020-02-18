###########
# Aim of script:
# map fastq (or fq) file from cellranger-atac mkfast output to the c. elegans genome
# to the selected gennome (mm9, mm10, ce11 or customized genomes already indexed) using bowtie2
# 
###########
while getopts ":ho:f:s:r:" opts; do
    case "$opts" in
        "h") 
	    echo "script to call cellranger-atac count to map fastq files"
	    echo "Usage: "
	    echo "$0 -o sample_scATAC -f /groups/cochella/jiwang/Projects/Aleks/R8898_scATAC/HWGWFBGXC_all (path to fastq files) -s sample_name -r reference_to_map" 

	    exit 0
	    ;;
	"o")
            id="$OPTARG"
            ;;
	"f")
	    fastqs="$OPTARG"
	    ;;
	"s")
	    sample="$OPTARG"
	    ;;
	"r")
            reference="$OPTARG"
            ;;
        "?")
            echo "Unknown option $opts"
            ;;
        ":")
            echo "No argument value for option $opts"
            ;;
        esac
done

jobName='scATAC'
DIR_logs=$PWD/logs

mkdir -p $DIR_logs


# creat the script for each sample
script=$DIR_logs/${jobName}_${id}.sh

################
# After testing, high memory 500G and 120G works both well
# 
################
ncpus=30

localmemory=`echo $memory * 0.9|bc`
cat <<EOF > $script
#!/usr/bin/bash

#SBATCH --export=ALL	
#SBATCH --qos=medium
#SBATCH --time=2-00:00:00
#SBATCH --partition=m
#SBATCH --mem=500G
#SBATCH --ntasks=1 --cpus-per-task=$ncpus

#SBATCH -o $DIR_logs/${id}.out
#SBATCH -e $DIR_logs/${id}.err
#SBATCH --job-name $jobName

module load cellranger-atac/1.2.0
cellranger-atac count --id=$id --fastqs=$fastqs --sample=$sample --reference=$reference --jobmode=local --localcores=$ncpus --localmem=450

EOF

cat $script

#sbatch $script
	    
