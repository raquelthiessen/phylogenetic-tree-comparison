#! /usr/bin/env Rscript

# Reading in the required packages and functions for plotting data -------------------------
libs <- c("magrittr", "dplyr", "data.table", "tibble", "ggplot2", "tidyr", 
          "RColorBrewer")
y <- lapply(libs, require, character.only = TRUE); rm(y); rm(libs)
dir.create("figs", showWarnings = FALSE)

# Run source("processing.R") first if "metrics.txt" is not found
if (file.exists("results/metrics.txt")) {
  metrics <- read.table("results/metrics.txt", header = TRUE) %>% as.data.table()
}else {
  source("src/processing.R")
  metrics <- read.table("results/metrics.txt", header = TRUE) %>% as.data.table()  
}


# # Plot 1
# taxon11 <- metrics[taxa == 11 & !is.na(gt_type)] %>% mutate(num_genes = paste0(num_genes, " genes"))
# ggplot(taxon11, aes(x = gt_type, y = seconds, fill = method)) + 
#   geom_bar(stat = "summary", fun = "mean", position = "dodge") +  
#   facet_wrap(~ num_genes) + 
#   scale_fill_brewer(palette = "Set2") + 
#   labs(fill = "Method", x = "Type of input gene tree", y = "Runtime (seconds)", 
#        title = "wQFM dataset - model with 11 taxa")
# # ggsave("figs/plot1.png",width = 7.3,height = 7)


# # Plot 2
# taxon15 <- metrics[taxa == 15] %>% mutate(num_genes = paste0(num_genes, " genes"))
# ggplot(taxon15, aes(x = gt_type, y = seconds, fill = method)) + 
#   geom_bar(stat = "summary", fun = "mean", position = "dodge") +  
#   facet_wrap(~ num_genes) + 
#   scale_fill_brewer(palette = "Set2") + 
#   labs(fill = "Method", x = "Type of input gene tree", y = "Runtime (seconds)", 
#        title = "wQFM dataset - model with 15 taxa")
# # ggsave("figs/plot2.png",width = 7.3,height = 7)


# # Plot 3
# taxon37 <- metrics[taxa == 37] %>% mutate(num_genes = paste0(num_genes, " genes"))
# ggplot(taxon37, aes(x = gt_type, y = seconds, fill = method)) + 
#   geom_bar(stat = "summary", fun = "mean", position = "dodge") +  
#   facet_wrap(~ num_genes) + 
#   scale_fill_brewer(palette = "Set2") + 
#   labs(fill = "Method", x = "Type of input gene tree", y = "Runtime (seconds)", 
#        title = "wQFM dataset - model with 37 taxa")
# # ggsave("figs/plot3.png",width = 7.3,height = 7)


# Plot 4
ggplot(metrics, aes(x = dataset, y = seconds, fill = method)) + 
  geom_bar(stat = "identity", position = "dodge") + 
  scale_fill_brewer(palette = "Set2") + 
  labs(fill = "Method", x = "Dataset", y = "Runtime (seconds)", 
       title = "Runtime for tested datasets")
ggsave("figs/plot4.png",width = 7.3,height = 7)


# Plot 5
ggplot(metrics, aes(x = method, y = num_gt, fill = method)) + 
  geom_bar(stat = "summary", fun = "mean", position = "dodge") + 
  facet_wrap(~ dataset) +  
  scale_fill_brewer(palette = "Set2") + 
  labs(fill = "Method", x = "Method", y = "Number of gene trees used", 
       title = "Number of input gene trees actually used/sampled by each method")
ggsave("figs/plot5.png",width = 7.3,height = 7)


# Plot 6
ggplot(metrics, aes(x = method, y = mem_pk, color = method, group = dataset)) + 
  geom_point() + stat_summary() + 
  facet_wrap(~ dataset) + 
  scale_color_brewer(palette = "Dark2") + 
  labs(fill = "Method", x = "Method", y = "Memory Peak", 
       title = "Peak memory usage for each dataset, by method")
ggsave("figs/plot6.png",width = 7.3,height = 7)


# # Plot 7
# ggplot(metrics, aes(x = method, y = nqs, color = method, group = dataset)) + 
#   geom_point() + stat_summary() + 
#   facet_wrap(~ dataset) + 
#   scale_color_brewer(palette = "Dark2") + 
#   labs(fill = "Method", x = "Methods", y = "Normalized Quartet Score", 
#        title = "Normalized quartet scores for each method")
# # ggsave("figs/plot7.png",width = 7.3,height = 7)


# For one of the datasets, not sure of the number of genes
# known_gene_num <- metrics[!is.na(num_genes)]
# ggplot(known_gene_num, aes(x = num_genes, y = seconds, fill = method)) +
#   geom_bar(stat = "summary", fun = "mean", position = "dodge") +
#   scale_fill_brewer(palette = "Set2")

# For one of the datasets, not sure of the number of genes
# ggplot(known_gene_num, aes(x = num_genes, y = NRF, fill = method)) +
#   geom_bar(stat = "summary", fun = "mean", position = "dodge") +
#   scale_fill_brewer(palette = "Set2")

# Plot 8
ggplot(metrics, aes(x = method, y = NRF, color = method, fill = method)) + 
  geom_boxplot() + 
  facet_wrap(~ dataset) +  
  scale_color_brewer(palette = "Set2") + 
  scale_fill_brewer(palette = "Set2") + 
  labs(fill = "Method", x = "Methods", y = "Species tree error (NRF)", 
       title = "Normalized Robinson-Foulds' distances for each method and dataset")
ggsave("figs/plot8.png",width = 7.3,height = 7)


if (file.exists("figs/plot4.png")) {
  cat("\nFigures generated, saved to figs/.\n")
}else {
  cat("Something went wrong. Open up src/plotting.R and check the steps.\n")
}