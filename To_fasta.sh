
for i in $(ls ../mm9_fasta_seq/chr*) 
do
echo ${i##*/}
bedtools getfasta -fi $i -s -bed mm9_refSeq_3utr.bed -fo mm9_refSeq_3utr.${i##*/}
bedtools getfasta -fi $i -s -bed mm9_refSeq_5utr.bed -fo mm9_refSeq_5utr.${i##*/}
bedtools getfasta -fi $i -bed mm9_refSeq_promoter_-2000_0.bed -fo mm9_refSeq_promoter_-2000_0.${i##*/} 
bedtools getfasta -fi $i -s -bed mm9_refSeq_whole_gene.bed -fo mm9_refSeq_whole_gene_strand_sp.${i##*/}
bedtools getfasta -fi $i -bed mm9_refSeq_whole_gene.bed -fo mm9_refSeq_whole_gene.${i##*/}
done

for i in $(ls ./chr_files/mm9_refSeq_3utr*.fa)
do
echo $i
cat $i >> mm9_refSeq_3utr_all_chr.fasta
done

for i in $(ls ./chr_files/mm9_refSeq_5utr*.fa)
do
echo $i
cat $i >>  mm9_refSeq_5utr_all_chr.fasta
done

for i in $(ls ./chr_files/mm9_refSeq_promoter_-2000_0*.fa)
do
echo $i
cat $i >> mm9_refSeq_promoter_-2000_0_all_chr.fasta
done

for i in $(ls ./chr_files/mm9_refSeq_whole_gene.chr*.fa)
do
echo $i
cat $i >> mm9_refSeq_whole_gene_all_chr.fasta
done

for i in $(ls ./chr_files/mm9_refSeq_whole_gene_strand_sp*.fa)
do
echo $i
cat $i >> mm9_refSeq_whole_gene_all_chr.fasta
done
