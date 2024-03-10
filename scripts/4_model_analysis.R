# Model selection/comparison & analysis

# load packages ----
library(tidyverse)
library(tidymodels)
library(here)

# handle common conflicts
tidymodels_prefer()

# load training data
load(here("data/spotify_train.rda"))

# load models ----
load(here("results/baseline_tuned.rda"))
load(here("results/lm_fit.rda"))
load(here("results/svm_tuned.rda"))
load(here("results/knn_tuned.rda"))
load(here("results/rf_tuned.rda"))
load(here("results/bt_tuned.rda"))


# hyperparameter analysis
autoplot(svm_tuned)
select_best(svm_tuned, metric = "accuracy")

autoplot(knn_tuned)
select_best(knn_tuned, metric = "accuracy")

autoplot(rf_tuned)
select_best(rf_tuned, metric = "accuracy")

autoplot(bt_tuned)
select_best(bt_tuned, metric = "accuracy")


## collect metrics across all folds for each model ----
metrics1 <- collect_metrics(baseline_tuned) |>
  mutate(model = "baseline") |>
  select(model, .metric, mean, std_err)

metrics2 <- collect_metrics(lm_fit) |>
  mutate(model = "lm") |>
  select(model, .metric, mean, std_err)

# metrics3 <- collect_metrics(bt_tuned) |>
#   mutate(model = "svm") |>
#   select(model, .metric, mean, std_err)

metrics4 <- collect_metrics(knn_tuned) |>
  mutate(model = "knn") |>
  select(model, .metric, mean, std_err)

metrics5 <- collect_metrics(rf_tuned) |>
  mutate(model = "rf") |>
  select(model, .metric, mean, std_err)

metrics6 <- collect_metrics(bt_tuned) |>
  mutate(model = "bt") |>
  select(model, .metric, mean, std_err)

# bind metrics into one table
train_metrics <-
  bind_rows(metrics1, metrics2, metrics4, metrics5, metrics6) |>
  filter(.metric == "accuracy") |>
  group_by(model) |>
  summarize(mean = mean(mean), std_err = mean(std_err)) |>
  arrange(desc(mean))

# write out metrics table
save(train_metrics, file = here("results/train_metrics.rda"))

