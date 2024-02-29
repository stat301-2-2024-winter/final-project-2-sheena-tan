# Train final model

# load packages ----
library(tidyverse)
library(tidymodels)
library(here)
library(doMC)

# handle common conflicts
tidymodels_prefer()

# parallel processing
registerDoMC(cores = parallel::detectCores(logical = TRUE))

# load training data
load(here("data/spotify_train.rda"))

# load final model
load(here("results/null_tuned.rda"))

# finalize workflow ----
final_wflow <-
  workflow() |>
  add_model(null_spec) |>
  add_recipe(titanic_recipe_tree)

# train final model
final_fit <- fit(final_wflow, spotify_train)

# write out final model
save(final_fit, file = here("results/final_fit.rda"))
