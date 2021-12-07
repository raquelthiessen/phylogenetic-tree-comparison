#! /usr/bin/env Rscript

# Reading in the required packages and functions for processing data -------------------------
libs <- c("magrittr", "dplyr", "data.table", "tibble", "tidytree", "tidyr", "phangorn")
y <- lapply(libs, require, character.only = TRUE); rm(y); rm(libs)

source("src/functions_for_proc.R")

# Folders to read from and general parameters ------------------------------------------------
method_names <- c("A-pro", "ASTRAL-MP", "wQFM") %>% set_names(c("apro", "amp", "wqfm"))
filenames <- c("model.11taxon", "model.15taxon", "model.37taxon", "model.10.2000000.0.000001")

split_by <- c("gene-trees/", "/out.log", "model.")

# all ILS is strong for this data set
dir11 <- "results/A-pro/data_sets/gene-trees/model.11taxon"
fullnames11 <- list.files(dir11, full.names = TRUE, recursive = TRUE) %>% 
  grep("estimated", ., invert = TRUE, value = TRUE)
params11 <- list("_", c(1,3,2), "genes") %>% set_names(c("split", "select", "gene_rm"))

# all ILS is strong for this data set
dir15 <- "results/A-pro/data_sets/gene-trees/model.15taxon"
fullnames15 <- list.files(dir15, full.names = TRUE, recursive = TRUE)
params15 <- list("-", 1:3, "gene") %>% set_names(c("split", "select", "gene_rm"))

# all ILS is moderate for this data set
dir37 <- "results/A-pro/data_sets/gene-trees/model.37taxon"
fullnames37 <- list.files(dir37, full.names = TRUE, recursive = TRUE)
params37 <- list("[.]", c(1,3,4), "g") %>% set_names(c("split", "select", "gene_rm"))


mod_folders <- data.table(
  mod = c("11", "15", "37", "model10"),
  mod_dirs = file.path("data_sets/gene-trees", filenames),
  true_trees = c(file.path("data_sets/species-trees", filenames[1:3], "true_tree_trimmed"), 
                 file.path("data_sets/species-trees", filenames[4]))
)


modelD_inp <- "data_sets/species-trees/model.10.2000000.0.000001"
modelD_out <- "data_sets/gene-trees/model.10.2000000.0.000001"


# Base metrics (from the logs and file names) ------------------------------------------------
xtaxon_files <- processWQFMFiles(split_by, fullnames37, params37) %>% 
  mutate(gt_type = gsub("b", "bp", gt_type)) %>% 
  bind_rows(processWQFMFiles(split_by, fullnames11, params11)) %>% 
  bind_rows(processWQFMFiles(split_by, fullnames15, params15))

logs_base <- allLogs(method_names, filenames, split_by) %>% 
  left_join(., xtaxon_files, by = c("filename", "taxa"))

# wQFM does not report number of gene trees, so we can get this from the A-pro logs
wqfm_logs <- logs_base[method == "wQFM"] %>% select(-num_gt) %>% 
  left_join(logs_base[method == "A-pro", c("num_gt", "filename")], by = c("filename")) %>% 
  select(colnames(logs_base))

metrics <- logs_base[method != "wQFM"] %>% bind_rows(wqfm_logs) %>% 
  mutate(across(taxa, as.factor))


# wQFM data, species tree accuracy -----------------------------------------------------------
models <- lapply(1:nrow(mod_folders), function(i) {
  if (mod_folders$mod[i] == "model10") {
    model_true <- list.files(mod_folders$true_trees[i], full.names = TRUE, recursive = TRUE) %>% 
      lapply(., function(j) read.tree(j))  
  }else {
    model_true <- read.tree(mod_folders$true_trees[i])  
  }
  
  f1 <- speciesTrees("A-pro", mod_folders$mod_dirs[i]) %>% 
    spTreeAcc("A-pro", model_true, .)
  
  f2 <- speciesTrees("ASTRAL-MP", mod_folders$mod_dirs[i]) %>% 
    spTreeAcc("ASTRAL-MP", model_true, .)
  
  f3 <- speciesTrees("wQFM", mod_folders$mod_dirs[i]) %>% 
    spTreeAcc("wQFM", model_true, .)

  bind_rows(f1, f2, f3)
}) %>% bind_rows()


# model_true <- read.tree(mod_folders$true_trees[i])
# f <- mod_folders$mod_dirs[i]
# spTreeAcc("A-pro", model_true, f) %>% 
#   bind_rows(spTreeAcc("ASTRAL-MP", model_true, f)) %>% 
#   bind_rows(spTreeAcc("wQFM", model_true, f))


# ASTRAL data --------------------------------------------------------------------------------
# modelD_files <- file.path(modelD_inp, list.files(modelD_inp, recursive = TRUE))
# modelD_true <-  lapply(modelD_files, function(file_x) read.tree(file_x)) %>%
#   set_names(modelD_files)
# 
# sptr_acc <- spTreeAcc("A-pro", modelD_true, modelD_out) %>%
#   bind_rows(spTreeAcc("ASTRAL-MP", modelD_true, modelD_out)) %>%
#   bind_rows(spTreeAcc("wQFM", modelD_true, modelD_out)) %>%
#   bind_rows(models, .)


# Combining all metrics ----------------------------------------------------------------------
# metrics <- left_join(metrics, sptr_acc, by = c("method", "filename")) %>% 
metrics <- left_join(metrics, models, by = c("method", "filename")) %>% 
  mutate(across(num_genes, as.character)) %>% 
  mutate(across(num_genes, as.double))

write.table(metrics, "results/metrics.txt", sep = "\t", row.names = FALSE)

if (file.exists("results/metrics.txt")) {
  cat("\nMetrics file generated, saved to results/.\n")
}else {
  cat("Something went wrong. Open up src/processing.R and check the steps.\n")
}
