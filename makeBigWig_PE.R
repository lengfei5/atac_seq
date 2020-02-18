#
# R script to make bigwig for pair ended bam files
#
bamfolder = commandArgs(trailingOnly=TRUE)

Normalized.coverage = TRUE
Logtransform.coverage = FALSE
Pairend = TRUE

if (length(bamfolder)==0){
  stop("the directory of bam file required", call.=FALSE)
}else{
  bamlist = list.files(path = bamfolder, pattern = "*.bam$", full.names = TRUE)
  if(length(bamlist) ==0 ){
    stop("- no bam file found -", call.=FALSE)
  }else{
     OutDir = "./bigWigs_PE/"
     if(!dir.exists(OutDir)) dir.create(OutDir)
     
     library(GenomicAlignments)
     library(rtracklayer)
     
     for(n in c(1:length(bamlist)))
     {
     
      #cat(bamlist[n], '\n')
      bam = bamlist[n]
      bw.name = basename(bam)
      bw.name = gsub(".bam", ".bw", bw.name)
      bw.name = gsub("_uniq_rmdup", '', bw.name)
      cat("bam file: ", bamlist[n], '-- ', "bw name: ", bw.name, "\n")
  
     if(! file.exists(paste0(OutDir, bw.name))){
      if(Pairend){
      ga = readGAlignmentPairs(bam)
      }else{
      ga = readGAlignments(bam)
     }
    
    if(Normalized.coverage){
      ss = length(ga)/2
      xx = coverage(granges(ga))/ss*10^6
    }else{
      xx = ga
    }
    
    if(Logtransform.coverage) xx = log2(xx+2^-6)
    export.bw(xx, con = paste0(OutDir, bw.name))
    
   }
   }
  }
}
