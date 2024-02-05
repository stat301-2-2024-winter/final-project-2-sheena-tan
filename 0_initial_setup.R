# Initial Setup
# Data quality check + splitting data

# Note: random process in this script (seed set directly before)


## load packages ----
library(tidyverse)
library(tidymodels)
library(here)
library(patchwork)

# handle conflicts
tidymodels_prefer()


## load data ----
session_logs <- read_csv(here("data/session_logs.csv")) |>
  janitor::clean_names() |>
  mutate(
    context_type = factor(context_type),
    hist_user_behavior_reason_start = factor(hist_user_behavior_reason_start),
    hist_user_behavior_reason_end = factor(hist_user_behavior_reason_end)
  ) |>
  rename(track_id = track_id_clean)

track_features <- read_csv(here("data/track_features.csv")) |>
  janitor::clean_names() |>
  mutate(
    mode = factor(mode),
    time_signature = factor(time_signature, ordered = TRUE),
    key = factor(key, ordered = TRUE)
  ) |>
  select(!c("flatness", "mechanism", "organism"))


## join data ----
spotify_data <- inner_join(session_logs, track_features, by = "track_id")


## inspect data ----
session_logs |>
  skimr::skim()

track_features |>
  skimr::skim()

spotify_data |>
  skimr::skim()


## split data ----
set.seed(1104)

# initial split
spotify_split <- spotify_data |>
  group_initial_split(group = "session_id", prop = 0.8)

spotify_train <- spotify_split |> training()
spotify_test <- spotify_split |> testing()

# split for eda
spotify_split_eda <- spotify_train |>
  group_initial_split(group = "session_id", prop = 0.2)

spotify_eda <- spotify_split_eda |> training()


## write out data ----
write_rds(spotify_split, file = here("data/spotify_split.rds"))
write_rds(spotify_train, file = here("data/spotify_train.rds"))
write_rds(spotify_test, file = here("data/spotify_test.rds"))
write_rds(spotify_split_eda, file = here("data/spotify_split_eda.rds"))
write_rds(spotify_eda, file = here("data/spotify_eda.rds"))
