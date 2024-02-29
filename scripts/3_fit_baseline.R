# Define and fit baseline models (null and naive bayes)

# Note: random process below. seed set below.

# load packages ----
library(tidyverse)
library(tidymodels)
library(here)

# handle common conflicts
tidymodels_prefer()

# load training data
load(here("data/spotify_train.rda"))

# load recipe, folds
load(here("data/spotify_folds.rda"))
load(here("recipes/spotify_recipe_naive_bayes.rda"))
### load(here("recipes/spotify_recipe_tree.rda"))

################################################################################
# Null Model ----
################################################################################

null_spec <-
  null_model() |>
  set_engine("parsnip") |>
  set_mode("classification")

null_workflow <-
  workflow() |>
  add_model(null_spec) |>
  add_recipe(titanic_recipe_tree)

null_tuned <-
  null_workflow |>
  fit_resamples(titanic_folds)

##########################################################################
# Basic baseline ----
##########################################################################

# baseline_spec <-
#   naive_Bayes() |>
#   set_engine("klaR") |>
#   set_mode("classification")
#
# baseline_workflow <-
#   workflow() |>
#   add_recipe(titanic_recipe_naive_bayes) |>
#   add_model(baseline_spec)
#
# baseline_tuned <-
#   baseline_workflow |>
#   fit_resamples(titanic_folds)

# write out results
save(null_tuned, file = here("results/null_tuned.rda"))
### save(baseline_tuned, file = here("results/baseline_tuned.rda"))
