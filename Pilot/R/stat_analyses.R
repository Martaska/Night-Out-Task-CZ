# Data analysis for the Pilot NOT-CZ project


# LIST DEPENDENT VARIABLES ----
list_dvs <- function( DVs = c("T1TotalExecutionTime", "T1OverallTaskAccuracy", "T1CorrectSequencingTotal") ) DVs


# PREPARE FORMULA FOR ANALYSES ----
get_formula <- function(DVs, IV) as.formula( paste0(paste(DVs, collapse = " + ")," ~ ",IV) )


# PRINT DESCRIPTIVE STATISTICS ----
compute_descriptives <- function(data, formula) jmv::descriptives(
  
  formula = formula, # list all DVs and one IV
  data = data, # input data
  desc = "rows", # put IV|DV pairs on rows
  missing = T, # show number of missing values
  median = T # show median
  
)


# INFERENCE STATISTICS (MANN-WHITNEY U) ----
compute_statistics <- function(data, formula) jmv::ttestIS(
  
  formula = formula, # list all DVs and one IV
  data = data, # input data
  students = T, # do a t-test
  welchs = T, # use Welch's degrees of freedom adjustment
  qq = T, # show residual QQ-plot
  norm = T, # perform Shapiro-Wilk test
  eqv = T, # perform Levene's tests for homogeneity of variances,
  meanDiff = T, # show differences of means
  ci = T, # calculate confidence intervals
  mann = T, # do a Mann-Whitney test
  effectSize = T # compute effect sizes
  
)


