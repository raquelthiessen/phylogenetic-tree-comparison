
# General processing functions --------------------------------------------------------------
# Read in the files
collectFiles <- function(method_type, file_type, gt) {
  files <- file.path("results", method_type, "data_sets/gene-trees", gt) %>% 
    list.files(., all.files = TRUE, recursive = TRUE, full.names = TRUE, pattern = file_type)
  if (grepl("log", file_type)) {
    lapply(files, function(x) readLines(x, warn = FALSE)) %>% set_names(files)
  }else {
    lapply(files, function(x) read.tree(x)) %>% set_names(files)
  }
}

splitString <- function(x, pattern, element = NULL) {
  y <- strsplit(x, split = pattern) %>% unlist()
  if (is.null(element)) {y}else {y[element]}
}

grepLines <- function(xlines, pattern) {
  xlines %>% grep(pattern, ., value = TRUE) %>% splitString(., " ")
}

fileNameElement <- function(file, element) {
  names(file) %>% splitString(., "/", element)
}


# More focused processing functions ---------------------------------------------------------

# Given a list split_by = c("gene-trees/", "/out.log", "model."), 
# a list of the full filenames, and a list of taxa-related parameters, 
# pre-process the wQFM filenames to extract as much information as we can from 
# them: taxa, the number of genes, and the type of gene tree
processWQFMFiles <- function(split_by, fullnames, params) {
  lapply(fullnames, function(x) {
    x2 <- x %>% splitString(., split_by[1], 2) %>% splitString(., split_by[2], 1)
    y <- x2 %>% splitString(., split_by[3], 2) %>% splitString(.,"/") %>% 
      splitString(., params$split)
    c(x2, y[params$select])
    
  }) %>% as.data.frame() %>% t() %>% as.data.table() %>% 
    set_colnames(c("filename", "taxa", "num_genes", "gt_type")) %>% 
    
    mutate(taxa = gsub("taxon", "", taxa) %>% as.double(), 
           num_genes = gsub(params$gene_rm, "", num_genes)) %>% 
    mutate(across(c(num_genes, gt_type), as.factor))
}


# Given a named list of logfiles (named with filename), the dataset (e.g. "model.11taxon"), 
# and a list split_by = c("gene-trees/", "/out.log", "model."), return a data.table 
# with metrics taken from the filenames and the logs 
logFiles <- function(all_logs, dir_x, split_by) {
  lapply(1:length(all_logs), function(i) {
    method <- fileNameElement(all_logs[i], 2)
    
    filename <- names(all_logs[i]) %>% splitString(.,split_by[1],2) %>% 
      splitString(.,split_by[2],1)
    
    if (length(all_logs[[i]]) > 10) {
      if (grepl("a", tolower(method))) {
        # Number of seconds total (seconds)
        y <- grep("sec", all_logs[[i]], value = TRUE) %>% grepLines(., "finished")  
        seconds = as.double(y[length(y)-1])
        
        # # Number of input gene trees (gt) - not provided with wqfm results
        num_gt <- grepLines(all_logs[[i]], "Number of gene trees") %>% last() %>% as.double()
        taxa <- grepLines(all_logs[[i]], "Number of taxa") %>% extract2(4) %>% as.double()
        
        # Normalized score (portion of input quartet trees satisfied) (nqs)
        nqs <- grepLines(all_logs[[i]], "Final normalized quartet score") %>% last() %>% as.double()
        
      }else {
        y <- grep("sec", all_logs[[i]], value = TRUE)
        part1 <- splitString(y[1], " ", 6) %>% as.double()
        part2 <- splitString(y[2], " ", 4) %>% as.double() %>% `/`(1000)
        seconds <- part1 + part2
        num_gt <- NA # see input files to get this value
        taxa <- grepLines(all_logs[[i]], "Total Num-Taxa")[4] %>% as.double()
        nqs <- all_logs[[i]][length(all_logs[[i]])-1] %>% splitString(., "\t", 3) %>% as.double()
      }
      
      data.table(method, seconds, taxa, nqs, num_gt, 
                       mem_pk = grepLines(all_logs[[i]], "Memory Peak") %>% last() %>% as.double(), 
                       filename, dataset = dir_x)
    }
  }) %>% bind_rows()
}


# Collects all the log files (for all replicates) and merges into a data.table
# Example input: method_names = "A-pro", filenames = c("model.11taxon", "model.15taxon")
allLogs <- function(method_names, filenames, split_by) {
  logs <- vector(mode = "list", length = length(method_names)) %>% 
    set_names(names(method_names))
  
  lapply(filenames, function(x) {
    bind_rows(collectFiles(method_names[["apro"]], "log", x) %>% logFiles(., x, split_by), 
              collectFiles(method_names[["amp"]], "log", x) %>% logFiles(., x, split_by), 
              collectFiles(method_names[["wqfm"]], "log", x) %>% logFiles(., x, split_by))
  }) %>% bind_rows()
}


# Returns a data.table of the species tree accuracy (using NRF)
# Example: spTreeAcc("A-pro", model_true, full_file_name)
spTreeAcc <- function(method_name, true_tree, result_dir) {
  
  sp_file <- file.path("results", method_name, result_dir) %>% 
    list.files(., full.names = TRUE, recursive = TRUE, pattern = "speciestree")
  
  allfiles <- lapply(sp_file, function(x) {
    splitString(x,"gene-trees/",2) %>% splitString(.,"/species",1)
  }) %>% data.table(method_name, sp_file, filename = .)
  
  result_trees <- lapply(1:nrow(allfiles), function(i) {
    x <- read.tree(allfiles$sp_file[i])
    # for the cases where the tips have been labeled with floats instead of the 
    # actual integer labels
    if (length(intersect(x$tip.label, true_tree$tip.label)) == 0) {
      x$tip.label <- x$tip.label %>% as.double() %>% floor()
    }
    x
  }) %>% set_names(allfiles$filename)
  
  lapply(1:length(result_trees), function(i) {
    # for one of the dataset types, there is a "true tree" for each file, 
    # instead of one for all the replicates
    if (class(true_tree) == "list") {
      RF.dist(result_trees[[i]], true_tree[[i]], normalize = TRUE)  
    }else {
      RF.dist(result_trees[[i]], true_tree, normalize = TRUE)
    }
  }) %>% unlist() %>% data.table() %>% set_colnames("NRF") %>% 
    add_column(filename = names(result_trees)) %>% 
    add_column(method = method_name)  
}


