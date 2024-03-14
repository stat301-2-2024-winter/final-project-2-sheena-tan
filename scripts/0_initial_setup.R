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
    hist_user_behavior_reason_end = factor(hist_user_behavior_reason_end),
    skipped = ifelse(skip_2, "yes", "no")
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
  # group_initial_split(group = "session_id", prop = 0.8) |>
  initial_split(prop = 0.8, strata = skipped)

spotify_train <- spotify_split |> training()
spotify_test <- spotify_split |> testing()

# split for eda
spotify_split_eda <- spotify_train |>
  # group_initial_split(group = "session_id", prop = 0.2) |>
  initial_split(prop = 0.8, strata = skipped)

spotify_eda <- spotify_split_eda |> training()


## data fold ----
spotify_folds <- vfold_cv(spotify_train, v = 5, repeats = 3, strata = skipped)

## write out splits and fold ----
save(spotify_split, file = here("data/spotify_split.rda"))
save(spotify_train, file = here("data/spotify_train.rda"))
save(spotify_test, file = here("data/spotify_test.rda"))
save(spotify_split_eda, file = here("data/spotify_split_eda.rda"))
save(spotify_eda, file = here("data/spotify_eda.rda"))
save(spotify_folds, file = here("data/spotify_folds.rda"))
