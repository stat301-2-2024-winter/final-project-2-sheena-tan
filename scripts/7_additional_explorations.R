# Exploring additional questions
# How does model performance change if only song properties or session info?

# load packages ----
library(tidyverse)
library(tidymodels)
library(here)

# handle common conflicts
tidymodels_prefer()

# load training data
load(here("data/spotify_train.rda"))

# load testing data
load(here("data/spotify_test.rda"))
spotify_test <- spotify_test |> mutate(skipped = as.factor(skipped))

# load final tuning
load(here("results/nnet_tuned.rda"))


##########################################################################
# Modify recipe ----
##########################################################################

# only session info ----
spotify_recipe_alt_lm_session <- recipe(skipped ~ ., data = spotify_train) |>
  step_rm(skip_1, skip_2, skip_3, not_skipped, session_id, track_id, date,
          duration, release_year, us_popularity_estimate, acousticness,
          beat_strength, bounciness, danceability, dyn_range_mean, energy,
          instrumentalness, key, liveness, loudness, mode, speechiness,
          tempo, time_signature, valence, starts_with("acoustic_vector")) |>
  step_zv(all_predictors()) |>
  step_dummy(all_nominal_predictors()) |>
  step_integer(all_logical_predictors()) |>
  step_normalize(all_numeric_predictors())

# check recipe
spotify_recipe_alt_lm_session |>
  prep() |>
  bake(new_data = NULL) |>
  glimpse()

# only song properties ----
spotify_recipe_alt_lm_properties <- recipe(skipped ~ ., data = spotify_train) |>
  step_rm(skip_1, skip_2, skip_3, not_skipped, session_id, track_id, date,
          session_position, session_length, context_switch, no_pause_before_play,
          short_pause_before_play, long_pause_before_play, hist_user_behavior_n_seekfwd,
          hist_user_behavior_n_seekback, hist_user_behavior_is_shuffle, hour_of_day,
          date, premium, context_type, hist_user_behavior_reason_start,
          hist_user_behavior_reason_end) |>
  step_zv(all_predictors()) |>
  step_dummy(all_nominal_predictors()) |>
  step_integer(all_logical_predictors()) |>
  step_normalize(all_numeric_predictors())

# check recipe
spotify_recipe_alt_lm_properties |>
  prep() |>
  bake(new_data = NULL) |>
  glimpse()

##########################################################################
# Finalize workflow ----
##########################################################################

# workflow for session info only ----
nnet_spec_alt_session <- mlp(
  hidden_units = tune(),
  penalty = tune(),
  epochs = tune()
) %>%
  set_mode("classification") %>%
  set_engine("nnet")

final_model_alt_session <-
  finalize_model(nnet_spec_alt_session, select_best(nnet_tuned, metric = "accuracy"))

final_workflow_alt_session <-
  workflow() %>%
  add_model(final_model_alt_session) %>%
  add_recipe(spotify_recipe_alt_lm_session)

# workflow for song properties only ----
nnet_spec_alt_properties <- mlp(
  hidden_units = tune(),
  penalty = tune(),
  epochs = tune()
) %>%
  set_mode("classification") %>%
  set_engine("nnet")

final_model_alt_properties <-
  finalize_model(nnet_spec_alt_properties, select_best(nnet_tuned, metric = "accuracy"))

final_workflow_alt_properties <-
  workflow() %>%
  add_model(final_model_alt_properties) %>%
  add_recipe(spotify_recipe_alt_lm_properties)


##########################################################################
# Train and assess model ----
##########################################################################

final_fit_alt_session <- fit(final_workflow_alt_session, spotify_train)
final_fit_alt_properties <- fit(final_workflow_alt_properties, spotify_train)

# function to create tibble of performance values
spotify_res <- function(fitted_model, .data, target_var){
  fitted_model |>
    predict(.data) |>
    bind_cols(.data |> select({{ target_var }}))
}

# create table to display results
accuracy_table_alt_session <- final_fit_alt_session |>
  spotify_res(spotify_test, "skipped") |>
  accuracy(truth = skipped, estimate = .pred_class) |>
  select(-.estimator) |>
  mutate(model_type = "nnet_alt_session")

accuracy_table_alt_properties <- final_fit_alt_properties |>
  spotify_res(spotify_test, "skipped") |>
  accuracy(truth = skipped, estimate = .pred_class) |>
  select(-.estimator) |>
  mutate(model_type = "nnet_alt_properties")

accuracy_table_alt_session
accuracy_table_alt_properties

# create confusion matrix ----
conf_matrix_alt_session <- predict(final_fit_alt_session, spotify_test) |>
  bind_cols(spotify_test) |>
  conf_mat(truth = skipped, estimate = .pred_class)

conf_matrix_alt_properties <- predict(final_fit_alt_properties, spotify_test) |>
  bind_cols(spotify_test) |>
  conf_mat(truth = skipped, estimate = .pred_class)

conf_matrix_alt_session
conf_matrix_alt_properties
