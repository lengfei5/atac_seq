ml load bedtools/2.27.1-foss-2018b

tss='/groups/cochella/jiwang/annotations/ce11_tss.bed'
genome='/groups/cochella/jiwang/Genomes/C_elegans/ce11/ce11_sequence/ce11.chrom.sizes'
size=2000
bedtools flank -i $tss -g $genome -s -l $size -r 0 > ce11_promoter_2kb.bed

bedtools sort -i ce11_promoter_2kb.bed > ce11_promoter_2kb_sorted.bed

bedtools getfasta -fi /groups/cochella/jiwang/Genomes/C_elegans/ce11/ce11_sequence/genome.fa -bed ce11_promoter_2kb_sorted.bed -name > ce11_promoter_2kb.fa

#bedtools getfasta -fi /groups/cochella/jiwang/Genomes/C_elegans/ce11/ce11_sequence/genome.fa -bed ce11_promoter_2kb_sorted.bed -name
qlogin
ml load meme/5.1.1-foss-2018b-python-3.6.6
fimo --thresh 0.0001 --oc fimo_out /groups/cochella/jiwang/Databases/motifs_TFs/PWMs_C_elegans/All_PWMs_JASPAR_CORE_2016_TRANSFAC_2015_CIS_BP_2015.meme ce11_promoter_2kb.fa 
