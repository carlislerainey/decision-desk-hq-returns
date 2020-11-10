
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
  select(text, time, state, candidate = A, party = B, percent = D, votes = E) %>%
  mutate(percent = str_trim(percent),
         percent = str_remove(percent, "\\.%"),  # 3 tweets have .%--a typo
         percent = str_remove(percent, "%"),
         percent = as.numeric(percent),
         share = percent/100) %>%
  select(-percent) %>%
  mutate(votes = str_remove(votes, " votes"),
         votes = str_remove_all(votes, ","),
         votes = as.numeric(votes)) %>%
  mutate(candidate = str_trim(candidate)) %>%
  mutate(time = lubridate::ymd_hms(time)) %>%
  select(state, time, candidate, votes, share, text) %>%
  glimpse()

r %>%
  write_rds("returns.rds") %>%
  write_csv("returns.csv")

ggplot(r, aes(x = time, y = share, color = candidate)) + 
  geom_line() + 
  facet_wrap(vars(state), scales = "free") + 
  scale_y_log10()
