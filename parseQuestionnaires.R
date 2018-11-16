## Extract data from docx questionnaires
## Ondrej Havlicek, Jul 2018

library(tidyverse)
library(stringr)
library(docxtractr)

questFolder <- file.path(getwd(), "Data", "questionnaires")

questFilesPaths <- list.files(questFolder, pattern="^BildAkt.*\\.docx$", full.names=TRUE)
questOutputPath <- file.path(getwd(), "Data", "questionnaires.csv")

readDoc <- function(docpath){
  subnum <- str_match(docpath, "(\\d{2})\\.docx")[2] %>% as.numeric()  # subject number from filename
  cat(subnum, "\n")
  doc <- read_docx(docpath)  # parse document
  tables <- docx_extract_all_tbls(doc, FALSE, TRUE)  # get all tables
  num_tables <- docx_tbl_count(doc)
  
  tables_merged <- bind_cols(tables)   # merge the tables as separate columns
  colnames(tables_merged) <- paste0("Q", c(1:num_tables))  # rename the columns
  tables_merged$Subject <- subnum  # add subject number
  tables_merged$QCount <- num_tables
  tables_merged %>% select(Subject, QCount, everything())  # reorder columns and return the data frame
}

## READ ALL FILES
questData <- questFilesPaths %>% map(readDoc) %>% reduce(bind_rows)  # by applying the reading function to a list of paths produce a list of data frames which then bind together

## There are two versions of the questionnaire, which differ in some ways
# Q1 tiny change in description
# Q3 in new = Q7 in old (press vs vibration)
# Q4 in new = Q3 in old (open q about diffs b/w 2D and 3D)
# Q5 in new = Q4 in old (explicit q about diffs b/w 2D and 3D)
# Q6 same in both (prefered 2D or 3D)
# Q7 in new = Q5 in old (any differences between 2D and 3D)
# Q8-12 the same, 9 bit more described in new
# Q13 Old: a) Jak často hrajete počítačové hry a b) jak často používáte virtuální realitu?; New: divided to Q13 and Q14
# Q14-16 in old -> Q15-17 in new

qdOld <- questData %>% filter(QCount==16)
qdNew <- questData %>% filter(QCount==17)

qdOld$Q17 <- NULL

colnamesOld <- c("Subject",
                 "QCount",
                 "PressVibr_Feel_Open",
                 "PressVibr_Feel_Expl",
                 "Scene2D3D_Feel_Open",
                 "Scene2D3D_Feel_Expl",
                 "Scene2D3D_Diff",
                 "Scene2D3D_Pref",
                 "PressVibr_Pref",
                 "Uncomfortable",
                 "ProblemsSeeingHearingFeeling",
                 "ObjectsCount_Difficulty",
                 "Intervals_Difficulty",
                 "Intervals_Certainty",
                 "Experience_VideogamesVR",
                 "Purpose",
                 "Scene2D3D_IntervalDiff",
                 "OtherComments"
                 )


colnamesNew <- c("Subject",
                 "QCount",
                 "PressVibr_Feel_Open",
                 "PressVibr_Feel_Expl",
                 "PressVibr_Pref",
                 "Scene2D3D_Feel_Open",
                 "Scene2D3D_Feel_Expl",
                 "Scene2D3D_Pref",
                 "Scene2D3D_Diff",
                 "Uncomfortable",
                 "ProblemsSeeingHearingFeeling",
                 "ObjectsCount_Difficulty",
                 "Intervals_Difficulty",
                 "Intervals_Certainty",
                 "Experience_Videogames",
                 "Experience_VR",
                 "Purpose",
                 "Scene2D3D_IntervalDiff",
                 "OtherComments"
)

colnames(qdOld) <- colnamesOld
colnames(qdNew) <- colnamesNew
QD <- bind_rows(qdOld, qdNew)

QD <- QD %>% mutate(Experience_VideogamesVR = case_when(
  is.na(Experience_VideogamesVR)==FALSE ~ Experience_VideogamesVR,
  TRUE ~ paste0("a) ", Experience_Videogames, " b) ", Experience_VR)
))
QD$Experience_Videogames <- NULL
QD$Experience_VR <- NULL


## Output again in some readable format
QD %>% write_excel_csv(questOutputPath)



