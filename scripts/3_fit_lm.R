# Define and fit logistic model

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
load(here("recipes/spotify_recipe_lm.rda"))

# model specifications ----
lm_spec <-
  logistic_reg() |>
  set_engine("glm") |>
  set_mode("classification")

# define workflows ----
lm_workflow <-
  workflow() |>
  add_model(lm_spec) |>
  add_recipe(spotify_recipe_lm)

# fit workflow/model ----
set.seed(1104)

lm_fit <-
  lm_workflow |>
  fit_resamples(spotify_folds)

# write out results (fitted/trained workflows) ----
save(lm_fit, file = here("results/lm_fit.rda"))
