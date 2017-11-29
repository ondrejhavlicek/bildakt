### BildAktVR data analysis
### Ondrej Havlicek ohavlicek@gmail.com 11/2017

library(tidyverse)


### Definitions ####
datapath <- file.path(getwd(), "..", "Data", "Main")
datafilepattern <- ""


### Read data ####
datafiles <- list.files(datapath, datafilepattern)
rawdata <- read_csv2()