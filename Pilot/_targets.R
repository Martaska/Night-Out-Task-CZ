# This is a script running targets pipeline of the Pilot analysis for NOT-CZ.

# Load packages required to define the pipeline:
library(targets)

# Set target options:
tar_option_set( packages = c(
  
  "here", # for path listing
  "tidyverse", # for data wrangling (includes ggplot2 two)
  "openxlsx", # for .xlsx reading
  "jmv", # for data analyses
  "GGally" # for correlation matrixes
  
) )

# Load all in-house functions:
tar_source()

# List the targets:
list(
  
  # read & format the data ----
  tar_target( metadata, data_file("data Kája", "DATASET_CLANEK_FINAL.xlsx"), format = "file" ), # prepare meta-data file
  tar_target( paths, list_paths("_data") ), # get paths to outcome data
  tar_target( included, included() ), # extract IDs of included participants
  tar_target( data, read_data(metadata, paths, included) ), # read the data
  
  # do stats ----
  tar_target( DVs, list_dvs( c("T1TotalExecutionTime", "T1OverallTaskAccuracy", "T1CorrectSequencingTotal", "MoCA", "FAQ") ) ), # list outcomes
  tar_target( formula, get_formula(DVs, "Age_group") ), # prepare formula for statistical analyses
  tar_target( descriptives, compute_descriptives(data, formula) ), # compute descriptive statistics
  tar_target( statistics, compute_statistics(data, formula) ), # compute inferential statistics
  tar_target( correlations, compute_correlations(data, DVs) ), #

  # do plots ----
  tar_target( labels, prepare_labels(DVs, "Age_group", c("Age Group", "Total Execution Time", "Overall Task Accuracy Score", "Correct Sequencing Total", "MoCA", "FAQ") ) ), # prepare labels for plots
  tar_target( fig_box, plot_data(data, DVs, "Age_group", labels, 123) ), # prepare dot-/box-/violin-plot combo
  tar_target( fig_cor, plot_correlations(data, labels) ) # prepare a correlation plot
  
)
