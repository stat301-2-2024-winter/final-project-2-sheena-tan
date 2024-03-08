# Define and fit random forest model

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
rf_spec <-
  rand_forest(
    mode = "classification",
    trees = 1000,
    min_n = tune(),
    mtry = tune()
  ) |>
  set_engine("ranger")

# define workflows ----
rf_workflow <-
  workflow() |>
  add_model(rf_spec) |>
  add_recipe(spotify_recipe_tree)


# hyperparameter tuning values ----
rf_params <- extract_parameter_set_dials(rf_spec) |>
  update(mtry = mtry(c(1, 47)))

rf_grid <- grid_regular(knn_params, levels = 5)

# fit workflow/model ----
set.seed(1104)

rf_tuned <-
  tune_grid(
    rf_workflow,
    spotify_folds,
    grid = rf_grid,
    control = control_grid(save_workflow = TRUE)
  )

# write out results (fitted/trained workflows) ----
save(rf_tuned, file = here("results/rf_tuned.rda"))
