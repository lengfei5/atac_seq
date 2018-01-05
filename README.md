Here is a piple to process, align and peak calling atac-seq data
In addition, this folder includes only ATAC-seq specific steps:
1) trim adaptor sequences using atac-seq specific method by comparing paired_end fastq files
2) shift read 4bp for postive strand and 5bp for negative strand
3) plot distribution of fragment size

Other steps are found in either ../ngs_tools if they are general steps for common NGS data
or in ../ChiPseq if they are shared with chipseq data