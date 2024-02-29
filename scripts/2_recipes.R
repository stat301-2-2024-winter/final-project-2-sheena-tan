# Setup pre-processing/recipes/feature engineering

# load packages ----
library(tidyverse)
library(tidymodels)
library(here)

# handle common conflicts
tidymodels_prefer()

# load training data ----
load(here("data/spotify_train.rda"))

# build baseline recipe ----
spotify_recipe_naive_bayes <- recipe(survived ~ ., data = spotify_train) |>
  step_rm(passenger_id, name, cabin, embarked, ticket) |>
  step_zv(all_predictors()) |>
  step_impute_linear(age) |>
  step_normalize(all_numeric_predictors())

# check recipe
spotify_recipe_naive_bayes |>
  prep() |>
  bake(new_data = NULL) |>
  glimpse()

# build lm recipe ----
spotify_recipe_lm <- recipe(survived ~ ., data = spotify_train) |>
  step_rm(passenger_id, name, cabin, embarked, ticket) |>
  step_zv(all_predictors()) |>
  step_impute_linear(age) |>
  step_dummy(all_nominal_predictors()) |>
  step_interact(terms = ~ starts_with("sex_"):fare) |>
  step_interact(terms = ~ age:fare) |>
  step_zv(all_predictors()) |>
  step_normalize(all_numeric_predictors())

# check recipe
spotify_recipe_lm |>
  prep() |>
  bake(new_data = NULL) |>
  glimpse()

# build tree-based recipe ----
# spotify_recipe_tree <- recipe(survived ~ ., data = spotify_train) %>%
#   step_rm(passenger_id, name, cabin, embarked, ticket) |>
#   step_zv(all_predictors()) |>
#   step_impute_linear(age) |>
#   step_dummy(all_nominal_predictors(), one_hot = TRUE) |>
#   step_zv(all_predictors()) |>
#   step_normalize(all_numeric_predictors())


# check recipe
# spotify_recipe_tree |>
#   prep() |>
#   bake(new_data = NULL) |>
#   glimpse()


# write out recipe(s) ----
save(spotify_recipe_naive_bayes, file = here("exercise_2/recipes/spotify_recipe_naive_bayes.rda"))
save(spotify_recipe_lm, file = here("exercise_2/recipes/spotify_recipe_lm.rda"))
# save(spotify_recipe_tree, file = here("exercise_2/recipes/spotify_recipe_tree.rda"))
