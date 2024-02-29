# Define and fit null/baseline model

# Note: random process below. seed set before.

# load packages ----
library(tidyverse)
library(tidymodels)
library(here)
library(discrim)
library(doMC)

# handle common conflicts
tidymodels_prefer()

# parallel processing ----
registerDoMC(cores = parallel::detectCores(logical = TRUE))

# load resamples/folds & controls ----
load(here("data/spotify_train.rda"))
load(here("data/spotify_folds.rda"))

# load pre-processing/feature engineering/recipe ----
load(here("recipes/spotify_recipe_naive_bayes.rda"))
# load(here("recipes/spotify_recipe_tree.rda"))

# ################################################################################
# # Null Model (the duh baseline) ----
# ################################################################################
#
# # model specifications ----
# null_spec <-
#   null_model() |>
#   set_engine("parsnip") |>
#   set_mode("classification")
#
# # define workflows ----
# null_workflow <-
#   workflow() |>
#   add_model(null_spec) |>
#   add_recipe(spotify_recipe_tree)
#
# # fit workflow/model ----
# set.seed(1104)
#
# null_tuned <-
#   null_workflow |>
#   fit_resamples(spotify_folds)

##########################################################################
# Basic baseline ----
##########################################################################

# model specifications ----
baseline_spec <-
  naive_Bayes() |>
  set_engine("klaR") |>
  set_mode("classification")

# define workflows ----
baseline_workflow <-
  workflow() |>
  add_recipe(spotify_recipe_naive_bayes) |>
  add_model(baseline_spec)

# fit workflow/model ----
set.seed(1104)

baseline_tuned <-
  baseline_workflow |>
  fit_resamples(spotify_folds)

# write out results
# save(null_tuned, file = here("results/null_tuned.rda"))
save(baseline_tuned, file = here("results/baseline_tuned.rda"))
