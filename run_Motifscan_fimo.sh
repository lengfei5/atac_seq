########
##### this script is to scan motifs using fimo
########
cwd="/groups/cochella/jiwang/Projects/Paula/motif_analysis_miRpromoter";
nb_cores=2;
pval=0.001;
OUT=${cwd}/fimo_out/mir_1/FIMO_OUT_bg_m2_p_3
sequence="${cwd}/seqFasta/mir1_promoter_blocks.fa"

#mkdir -p ${OUT}
#mkdir -p 

bg="${cwd}/seqFasta/backgrounds/background_ce_m2.bg"
pwms="/groups/cochella/jiwang/Databases/motifs_TFs/PWMs_C_elegans/All_PWMs_JASPAR_CORE_2016_TRANSFAC_2015_CIS_BP_2015.meme"

mkdir -p $OUT;
mkdir -p ${cwd}/logs
qsub -q public.q -o $cwd/logs -j yes -pe smp $nb_cores -cwd -b y -shell y -N fimo_scan "module load meme/4.9.1; fimo --bgfile $bg --oc $OUT --thresh $pval $pwms $sequence"