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

# load recipe
load(here("recipes/spotify_recipe_lm.rda"))

# load final model
load(here("results/nnet_tuned.rda"))


##########################################################################
# Finalize workflow ----
##########################################################################

nnet_spec <- mlp(
    hidden_units = tune(),
    penalty = tune(),
    epochs = tune()
  ) %>%
  set_mode("classification") %>%
  set_engine("nnet")

final_model <-
  finalize_model(nnet_spec, select_best(nnet_tuned, metric = "accuracy"))

final_workflow <-
  workflow() %>%
  add_model(final_model) %>%
  add_recipe(spotify_recipe_lm)


##########################################################################
# Train final model ----
##########################################################################

final_fit <- fit(final_workflow, spotify_train)

# write out final model
save(final_fit, file = here("results/final_fit.rda"))
