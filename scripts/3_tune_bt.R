# Define and fit boosted tree model

# Note: random process below. seed set before.

# load packages ----
library(tidyverse)
library(tidymodels)
library(here)
library(doMC)

# handle common conflicts
tidymodels_prefer()

# parallel processing ----
registerDoMC(cores = parallel::detectCores(logical = TRUE))

# load resamples/folds & controls ----
load(here("data/spotify_train.rda"))
load(here("data/spotify_folds.rda"))

# load pre-processing/feature engineering/recipe ----
load(here("recipes/spotify_recipe_tree.rda"))

# model specifications ----
bt_spec <-
  boost_tree(
    mode = "classification",
    learn_rate = tune(),
    min_n = tune(),
    mtry = tune()
  ) |>
  set_engine("xgboost")

# define workflows ----
bt_workflow <-
  workflow() |>
  add_model(bt_spec) |>
  add_recipe(spotify_recipe_tree)


# hyperparameter tuning values ----
bt_params <- extract_parameter_set_dials(bt_spec) |>
  update(mtry = mtry(c(1, 47)))

bt_grid <- grid_regular(bt_params, levels = 5)

# fit workflow/model ----
set.seed(1104)

bt_tuned <-
  tune_grid(
    bt_workflow,
    spotify_folds,
    grid = bt_grid,
    control = control_grid(save_workflow = TRUE)
  )

# write out results (fitted/trained workflows) ----
save(bt_tuned, file = here("results/bt_tuned.rda"))
