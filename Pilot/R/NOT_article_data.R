# Data k pilotnímu článku NOT

library(here)
library(tidyverse)
library(openxlsx)

wd <- here( here(), "Pilot" ) #extrakce working directory
dd <- here(wd, "_data")

paths <- list.files(here(dd), recursive = T) %>%
  ifelse(grepl(".csv", . ), ., NA) %>%
  ifelse(!grepl("data_joined.csv", . ), ., NA) %>%
  na.omit()

data0 <- lapply(
  
  X = paths,
  FUN = function(a)
    read.csv(
      file= here (dd, a),
      sep = ifelse (grepl("Zdenda", a), ",", ";" ),
      dec = ifelse (grepl("Zdenda", a), ".", ",")
    )
) %>% 
  reduce(full_join)

metadata <- read.xlsx(here(dd, "data Kája", "DATASET_CLANEK_FINAL.xlsx"), sheet = "List1") %>%
  rename("age" = "Věk", "edu" = "Vzdělání", "sex" = "Pohlaví") %>%
  select(ParticipantID, age, edu, sex) 

data <-
  full_join(metadata, data0, by = "ParticipantID") %>%
  filter( (age >= 50 & age <= 60) | (age >= 70 & age <= 80)  )

write.table(
  x = data, 
  file = here(dd, "data_joined.csv"), 
  sep = ";", 
  row.names = F, 
  quote = F
)


