# Pre-processing of data for NOT-CZ pilot.

# load libraries to be used
library(here) # for path listing
library(tidyverse) # for data wrangling
library(openxlsx) # for .xlsx reading

wd <- here(here(), "Pilot") # extract working directory
dd <- here(wd, "_data") # extract data directory

# list paths to data files
paths <-
  list.files(here(dd), recursive = T) %>% # looking for all files in the dd folder
  ifelse(grepl(".csv", . ), ., NA) %>% # keep only files whose names end with '.csv'
  ifelse(!grepl("data_joined.csv", . ), ., NA) %>% # if the pre-processed file is already here, ignore it
  na.omit() %>% # get rid of missing values
  c() # formatting shenanigans

# read each data set separately and then glue them one below the other
data0 <- lapply(
  
  # begib by extracting a list with each entry containing one participant's data
  X = paths, # loop through all paths
  FUN = function(a)

    read.csv(
      file= here(dd, a),
      sep = ifelse(grepl("Zdenda", a), ",", ";" ), # Zdenda's files are comma separated, Kaja's are separated by semi-colon
      dec = ifelse(grepl("Zdenda", a), ".", ",") # Zdenda's files have decimal dots, Kaja's 
    )

) %>%
  
  # glue particpants one below the other
  reduce(full_join)

# extract demography data
metadata <-
  read.xlsx(here(dd, "data Kája", "DATASET_CLANEK_FINAL.xlsx"), sheet = "List1") %>% # read .xlsx file
  rename("age" = "Věk", "edu" = "Vzdělání", "sex" = "Pohlaví") %>% # re-label variables
  select(ParticipantID, age, edu, sex) # keep only columns (i.e., variables) of interest

# add participant-specific outcomes to metadara
data <-
  full_join(metadata, data0, by = "ParticipantID") %>% # glue the tables by ID
  filter( (age >= 50 & age <= 60) | (age >= 70 & age <= 80)  ) %>% # keep only participants in age groups of interest to the pilot
  mutate(
    Age_group = case_when(
      age >= 50 & age <= 60 ~ 1, # age group 50-60 years of age
      age >= 70 & age <= 80 ~ 2  # age group 70-80 years of age
    ),
    .after = age
  )

# save pre-processed table as .csv
write.table(
  x = data, 
  file = here(dd, "data_joined.csv"), 
  sep = ";", 
  row.names = F, 
  quote = F
)
