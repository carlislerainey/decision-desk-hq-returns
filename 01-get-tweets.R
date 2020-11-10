
# load packages
library(tidyverse)
library(rtweet)

# get raw tweets
raw_tw <- get_timeline(user = "DecisionDeskHQ", n = 3200) 

raw_tw %>%
  write_rds("raw/decision-desk-timeline.rds") %>%
  select(user_id, status_id, created_at, screen_name, text) %>%
  write_csv("raw/decision-desk-timeline.csv")

# once run, manually make a protected/, a protected 
# copy of raw/ directory so that the raw tweets 
# have a safe home