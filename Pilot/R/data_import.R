# Pre-processing of data for NOT-CZ pilot.


# WRITE PATH TO META-DATA ----
data_file <- function(folder, file) here("_data", folder, file)


# EXTRACT ID OF INCLUDED PATIENTS ----
included <- function() {
  
  here("_data","included_participants.csv") %>%
    read.csv(sep = ";") %>%
    select(ParticipantID) %>%
    unlist(use.names = F)
  
}


# LIST PATHS TO DATA ----
list_paths <- function(folder) {
  
  list.files(path = folder, recursive = T) %>% # looking for all files in the 'folder'
    ifelse(grepl(".csv", . ), ., NA) %>% # keep only files whose names end with '.csv'
    ifelse(!grepl("data_joined.csv", . ), ., NA) %>% # if the pre-processed file is here, ignore it
    ifelse(!grepl("included_participants.csv", . ), ., NA) %>%
    na.omit() %>% # get rid of missing values
    c() # formatting shenanigans
  
}


# READ THE DATA ----
read_data <- function(metadata, paths, included) {
  
  # extract demography data
  metadata <-
    read.xlsx(metadata, sheet = "List1") %>% # read .xlsx file
    rename("age" = "Věk", "edu" = "Vzdělání", "sex" = "Pohlaví") # re-label variables
    
  # read each data set separately and then glue them one below the other
  data0 <- lapply(
    
    # begin by extracting a list with each entry containing one participant's data
    X = paths, # loop through all paths
    FUN = function(a)
      
      read.csv(
        file= here("_data",a),
        sep = ifelse(grepl("Zdenda", a), ",", ";" ), # Zdenda's files are comma separated, Kaja's are separated by semi-colon
        dec = ifelse(grepl("Zdenda", a), ".", ",") # Zdenda's files have decimal dots, Kaja's 
      )
    
  ) %>%
    
    # glue participants one below the other
    reduce(full_join)
  
  # add participant-specific outcomes to metadata
  data <-
    full_join(metadata, data0, by = "ParticipantID") %>% # glue the tables by ID
    filter(ParticipantID %in% included) %>% # keep only participants in age groups of interest to the pilot
    mutate(
      Age_group = factor(
        x = case_when(
          age >= 50 & age <= 60 ~ 1, # age group 50-60 years of age
          age >= 70 & age <= 80 ~ 2  # age group 70-80 years of age
        ),
        levels = 1:2,
        labels = c("50-60 years old", "70-80 years old"),
        ordered = T
      ),
      .after = age
    )
  
  # return resulting data set
  return(data)
  
}

