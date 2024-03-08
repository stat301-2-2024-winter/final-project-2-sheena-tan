# Define and fit k-nearest neighbors model

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

# define workflows ----
knn_spec <-
  nearest_neighbor(
    mode = "classification",
    neighbors = tune()
  ) |>
  set_engine("kknn")

# define workflows ----
knn_workflow <-
  workflow() |>
  add_model(knn_spec) |>
  add_recipe(spotify_recipe_tree)


# hyperparameter tuning values ----
knn_params <- extract_parameter_set_dials(knn_spec)

knn_grid <- grid_regular(knn_params, levels = 5)

# fit workflow/model ----
set.seed(1104)

knn_tuned <-
  tune_grid(
    knn_workflow,
    spotify_folds,
    grid = knn_grid,
    control = control_grid(save_workflow = TRUE)
  )

# write out results (fitted/trained workflows) ----
save(knn_tuned, file = here("results/knn_tuned.rda"))
