Assemblies.gb <- read.delim(file = "ftp://ftp.ncbi.nlm.nih.gov/genomes/ASSEMBLY_REPORTS/assembly_summary_genbank.txt", sep = "\t",skip = 1, header = T, comment.char = "", stringsAsFactors = F)

Assemblies.rs <- read.delim(file = "ftp://ftp.ncbi.nlm.nih.gov/genomes/ASSEMBLY_REPORTS/assembly_summary_refseq.txt", sep = "\t",skip = 1, header = T, comment.char = "", stringsAsFactors = F)

download_genomes <- function(df, type = "genome", outpath){
  library(stringr)
  library(RCurl)
  library(R.utils)
  dir.create(outpath, showWarnings = F, recursive = T)
  url.base <- df$ftp_path
  url.file <- strsplit(as.character(url.base), "/")
  url.file <- sapply(url.file, '[[', 10)
  if(type=="genome"){
    Genome.file <- paste0(outpath,"/", df$strain, "_genomic.fna.gz")
    url.genome <- paste0(url.base, "/", url.file, "_genomic.fna.gz")
  }else if(type =="protein"){
    Genome.file <- paste0(outpath, "/", df$strain, "_protein.faa.gz")
    url.genome <- paste0(url.base, "/", url.file, "_protein.faa.gz")
  }else if(type == "rna"){
    Genome.file <-paste0(outpath, "/", df$strain, "_rna_from_genomic.fna.gz")
    url.genome <-paste0(url.base, "/", url.file, "_rna_from_genomic.fna.gz")
  }
  for (i in seq_along(url.file)){
    if(!file.exists(gsub(".gz", "",Genome.file[i]))){
      tryCatch({
        download.file(url=url.genome[i], destfile = Genome.file[i])
        gunzip(Genome.file[i])
      },
      error = function(e) try({
        download.file(url=gsub("GCA", "GCF", url.genome[i]), destfile = Genome.file[i])
        gunzip(Genome.file[i])
      })
      )
      
    }
  }
}

remove_sym <-function(s){
  s <- gsub("-", "_",s)
  s <- gsub(" ", "_",s)
  s <- gsub("#", "_",s)
  s <- gsub("/", "_",s)
  s <- gsub('\\)', "",s)
  s <- gsub('\\(', "_",s)
}