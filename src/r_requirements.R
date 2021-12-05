#! /usr/bin/env Rscript

# This should be run first, to make sure the required packages are installed

required_packages <- c("magrittr", "dplyr", "data.table", "tibble", 
                       "tidytree", "tidyr", "phangorn", "ggplot2", 
                       "beepr", "here")
y <- suppressWarnings(
  suppressMessages(
    lapply(required_packages, require, character.only = TRUE)
  )
)
y <- unlist(y)
names(y) <- required_packages

if (all(y)) {
  cat("All required packages installed.")
}else {
  cat("Run install.packages() in R with dependencies = TRUE for packages:", 
      paste("\n      - ", names(y[!y])), 
      paste("\n"))
}
# Otherwise, run install.packages() individually for the exceptions
# e.g. install.packages("magrittr", dependencies = TRUE)