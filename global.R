list_of_packages <- c("stringr", "RCurl", "R.utils")
nul <- lapply(list_of_packages, 
       function(x) if(!require(x,character.only = TRUE)) install.packages(x))
library(stringr)
library(RCurl)
library(R.utils)

gb.link <- "ftp://ftp.ncbi.nlm.nih.gov/genomes/genbank/bacteria/assembly_summary.txt"
rs.link <- "ftp://ftp.ncbi.nlm.nih.gov/genomes/refseq/bacteria/assembly_summary.txt"
# rs.link <- "~/Desktop/assembly_summary.txt"

columns <- c(24, 23, 25, 1, 5, 8,11, 12,14,15,16,21)
Get_phylo <- function(Assembly){
  Assembly$Species <- stringr::word(Assembly$organism_name, 2, 2, sep = " ")
  Assembly$Genera <- stringr::word(Assembly$organism_name, 1, 1, sep = " ")
  return(Assembly)
}


get_strain_name <- function(df){
  df$strain <- gsub("strain=", "", df$infraspecific_name) 
  no.strain.logic <- (df$strain == ""|df$strain == "n/a" |df$strain == "type strain: N")
  df$strain[no.strain.logic] <- df$isolate[no.strain.logic]
  no.strain.logic <- df$strain == ""
  df$strain[no.strain.logic]  <- df$X..assembly_accession[no.strain.logic]
  remove_sym <-function(s){
    s <- gsub(" ", "_",s)
    s <- gsub("#", "",s)
    s <- gsub("/", "_",s)
    s <- gsub(";.*", "",s)
    s <- gsub('\\)', "",s)
    s <- gsub('\\(', "_",s)
    s <- gsub(':', "_",s)
    
  }
  df$strain <- remove_sym(df$strain)
  return(df)
}

remove.dup <- function(df){
  dup.df <- df[df$strain %in% df$strain[duplicated(df$strain)],]
  dup.l <- lapply(unique(dup.df$Genera), function(g) dup.df[dup.df$Genera == g,])
  dup.df2 <- do.call(rbind, lapply(dup.l, function(d) d[d$strain %in% d$strain[duplicated(d$strain)],]))
  
  dup <- sapply(unique(dup.df2$strain), function(s) dup.df2[dup.df2$strain == s,],USE.NAMES = T, simplify = F)
  
  best.candidate <- sapply(dup, function(d){
    b.c <- d$X..assembly_accession[d$refseq_category != "na"]
    if(length(b.c)==0){
      b.c <- d$X..assembly_accession[d$assembly_level == "Complete Genome"]
    } 
    if(length(b.c) == 0){
      b.c <- d$X..assembly_accession[d$assembly_level == "Chromosome"]
    }
    if(length(b.c) == 0){
      b.c <- d$X..assembly_accession[d$assembly_level == "Scaffold"]
    }
    if(length(b.c) != 1){
      d <- d[order(d$seq_rel_date, decreasing = T),]
      b.c <- d$X..assembly_accession[1]
    }
    return(b.c)
  })
  
  dup.str <- dup.df2$X..assembly_accession
  str.to.remove <- dup.str[!dup.str %in% best.candidate]
  
  return(df[!df$X..assembly_accession %in% str.to.remove, ])
}

Get.length <- function(str.list){
  uniq.str <- unique(str.list)
  uniq.str <- uniq.str[order(sapply(uniq.str, function(g) sum(str.list == g)),decreasing = T)]
  count.str <- sapply(uniq.str, function(g) sum(str.list == g))
  return(paste0(uniq.str, "(", count.str,")"))
}

download_genomes <- function(df, type = "genome", outpath){

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
      download.file(url=url.genome[i], destfile = Genome.file[i])
      gunzip(Genome.file[i])
    }
  }
}
