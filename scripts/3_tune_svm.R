# Define and fit linear support vector machine model

# Note: random process below. seed set before.

# load packages ----
library(tidyverse)
library(tidymodels)
library(here)
library(doMC)
library(ISLR2)

# handle common conflicts
tidymodels_prefer()

# parallel processing ----
registerDoMC(cores = parallel::detectCores(logical = TRUE))

# load resamples/folds & controls ----
load(here("data/spotify_train.rda"))
load(here("data/spotify_folds.rda"))

# load pre-processing/feature engineering/recipe ----
load(here("recipes/spotify_recipe_lm.rda"))

# model specifications ----
svm_spec <-
  svm_poly(
    mode = "classification",
    degree = tune(),
    cost = tune()
  ) |>
  set_engine("kernlab", scaled = FALSE)

# define workflows ----
svm_workflow <-
  workflow() |>
  add_model(svm_spec) |>
  add_recipe(spotify_recipe_lm)


# hyperparameter tuning values ----
svm_params <- extract_parameter_set_dials(svm_spec)

svm_grid <- grid_regular(svm_params, levels = 5)

# fit workflow/model ----
set.seed(1104)

svm_tuned <-
  tune_grid(
    svm_workflow,
    spotify_folds,
    grid = svm_grid,
    control = control_grid(save_workflow = TRUE)
  )

# write out results (fitted/trained workflows) ----
save(svm_tuned, file = here("results/svm_tuned.rda"))
