# Define and fit neural network model

# Note: random process below. seed set before.

# load packages ----
library(tidyverse)
library(tidymodels)
library(here)
library(doMC)

# handle common conflicts
tidymodels_prefer()

# parallel processing ----
registerDoMC(cores = 6)

# load resamples/folds & controls ----
load(here("data/spotify_train.rda"))
load(here("data/spotify_folds.rda"))

# load pre-processing/feature engineering/recipe ----
load(here("recipes/spotify_recipe_lm.rda"))

# model specifications ----
nnet_spec <-
  mlp(
    hidden_units = tune(),
    penalty = tune(),
    epochs = tune()
  ) %>%
  set_mode("classification") %>%
  set_engine("nnet")

# define workflows ----
nnet_workflow <-
  workflow() |>
  add_model(nnet_spec) %>%
  add_recipe(spotify_recipe_lm)


# hyperparameter tuning values ----
nnet_params <- extract_parameter_set_dials(nnet_spec)

nnet_grid <- grid_regular(nnet_params, levels = 5)

# fit workflow/model ----
set.seed(1104)

nnet_tuned <-
  tune_grid(
    nnet_workflow,
    spotify_folds,
    grid = nnet_grid,
    control = control_grid(save_workflow = TRUE)
  )

# write out results ----
save(nnet_tuned, file = here("results/nnet_tuned.rda"))
