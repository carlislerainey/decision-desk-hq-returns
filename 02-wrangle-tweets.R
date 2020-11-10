
# load packages
library(tidyverse)
library(rtweet)

# get raw tweets
raw_tw <- read_rds("protected/decision-desk-timeline.rds") 

# separate tweets into data
r <- raw_tw %>%
  select(text, time = created_at) %>%
  mutate(pres_results = str_detect(text, "Presidential Election Results")) %>%
  filter(pres_results) %>%
  mutate(state = str_sub(text, start = 1L, end = 2L)) %>%
  separate(text, sep = "\n", into = LETTERS, remove = FALSE, fill = "right") %>%
  select(text, time, state, C, D) %>%
  pivot_longer(cols = C:D) %>%
  select(-name) %>%
  separate(value, sep = ":|\\(|\\)", into = LETTERS, remove = FALSE, fill = "right") %>%
  select(text, time, state, candidate = A, party = B, votes = E) %>%
  mutate(votes = str_remove(votes, " votes"),
         votes = str_remove_all(votes, ","),
         votes = as.numeric(votes)) %>%
  mutate(candidate = str_trim(candidate)) %>%
  mutate(time = lubridate::ymd_hms(time)) %>%
  select(state, time, candidate, votes, text) %>%
  glimpse()

r %>%
  write_rds("returns.rds") %>%
  write_csv("returns.csv")
