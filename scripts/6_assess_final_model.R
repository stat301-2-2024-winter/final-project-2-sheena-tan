# Assess final model

# load packages ----
library(tidyverse)
library(tidymodels)
library(here)

# handle common conflicts
tidymodels_prefer()

# load testing data
load(here("data/spotify_test.rda"))
spotify_test <- spotify_test |> mutate(skipped = as.factor(skipped))

# load final model
load(here("results/final_fit.rda"))


# function to create tibble of performance values
spotify_res <- function(fitted_model, .data, target_var){
  fitted_model |>
    predict(.data) |>
    bind_cols(.data |> select({{ target_var }}))
}

# create table to display results
accuracy_table <- final_fit |>
  spotify_res(spotify_test, "skipped") |>
  accuracy(truth = skipped, estimate = .pred_class) |>
  select(-.estimator) |>
  mutate(model_type = "nnet")

accuracy_table

# create confusion matrix ----
conf_matrix <- predict(final_fit, spotify_test) |>
  bind_cols(spotify_test) |>
  conf_mat(truth = skipped, estimate = .pred_class)

conf_matrix
