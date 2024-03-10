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
load(here("results/lm_fit.rda"))

# finalize workflow ----
final_workflow <-
  workflow() |>
  add_model(lm_fit) |>
  add_recipe(spotify_recipe_lm)

# train final model
final_fit <- fit(final_workflow, spotify_train)

# write out final model
save(final_fit, file = here("results/final_fit.rda"))
