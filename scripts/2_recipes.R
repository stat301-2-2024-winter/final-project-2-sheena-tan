# Setup pre-processing/recipes/feature engineering

# load packages ----
library(tidyverse)
library(tidymodels)
library(here)

# handle common conflicts
tidymodels_prefer()

# load training data ----
load(here("data/spotify_train.rda"))


##########################################################################
# Baseline recipe ----
##########################################################################

spotify_recipe_naive_bayes <- recipe(skipped ~ ., data = spotify_train) |>
  step_rm(skip_1, skip_2, skip_3, not_skipped, session_id, track_id, date) |>
  step_zv(all_predictors()) |>
  step_normalize(all_numeric_predictors())

# check recipe
spotify_recipe_naive_bayes |>
  prep() |>
  bake(new_data = NULL) |>
  glimpse()


##########################################################################
# Logistic recipe ----
##########################################################################

spotify_recipe_lm <- recipe(skipped ~ ., data = spotify_train) |>
  step_rm(skip_1, skip_2, skip_3, not_skipped, session_id, track_id, date) |>
  step_zv(all_predictors()) |>
  step_dummy(all_nominal_predictors()) |>
  step_integer(all_logical_predictors()) |>
  step_normalize(all_numeric_predictors())

# check recipe
spotify_recipe_lm |>
  prep() |>
  bake(new_data = NULL) |>
  glimpse()


##########################################################################
# Tree-based recipe ----
##########################################################################

spotify_recipe_tree <- recipe(skipped ~ ., data = spotify_train) |>
  step_rm(skip_1, skip_2, skip_3, not_skipped, session_id, track_id, date) |>
  step_zv(all_predictors()) |>
  step_dummy(all_nominal_predictors(), one_hot = TRUE) |>
  step_integer(all_logical_predictors()) |>
  step_zv(all_predictors()) |>
  step_normalize(all_numeric_predictors())

# check recipe
spotify_recipe_tree |>
  prep() |>
  bake(new_data = NULL) |>
  glimpse()


# write out recipe(s) ----
save(spotify_recipe_naive_bayes, file = here("recipes/spotify_recipe_naive_bayes.rda"))
save(spotify_recipe_lm, file = here("recipes/spotify_recipe_lm.rda"))
save(spotify_recipe_tree, file = here("recipes/spotify_recipe_tree.rda"))
