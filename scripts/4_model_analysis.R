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
load(here("results/baseline_fit.rda"))
load(here("results/lm_fit.rda"))
load(here("results/knn_tuned.rda"))
load(here("results/rf_tuned.rda"))
load(here("results/bt_tuned.rda"))
load(here("results/nnet_tuned.rda"))


##########################################################################
# Hyperparameter analysis ----
##########################################################################

autoplot(knn_tuned)

rf_params_autoplot <- autoplot(rf_tuned)
ggsave(rf_params_autoplot, file = here("images/rf_params_autoplot.png"))

bt_params_autoplot <- autoplot(bt_tuned)
ggsave(bt_params_autoplot, file = here("images/bt_params_autoplot.png"))

nnet_params_autoplot <- autoplot(nnet_tuned)
ggsave(nnet_params_autoplot, file = here("images/nnet_params_autoplot.png"))

# function to show best performing parameter results
show_best_params <- function(model_tuned, metric_string) {
  show_best(model_tuned, metric = {{metric_string}}) |>
    slice(1) |>
    select(!c(.estimator, .config, .metric, n)) |>
    rename(accuracy = mean) |>
    pivot_longer(
      cols = !c("accuracy", "std_err"),
      names_to = "parameter",
      values_to = "value"
    )
}

# bind parameters into one table
table_best_params <- show_best_params(nnet_tuned, "accuracy") |>
  mutate(model = "nnet", .before = "accuracy") |>
  bind_rows(
    show_best_params(rf_tuned, "accuracy") |>
      mutate(model = "rf", .before = "accuracy")
  ) |>
  bind_rows(
    show_best(lm_fit, metric = "accuracy") |>
      select(mean, std_err) |>
      rename(accuracy = mean) |>
      mutate(model = "lm", .before = "accuracy")
  ) |>
  bind_rows(
    show_best(baseline_tuned, metric = "accuracy") |>
      select(mean, std_err) |>
      rename(accuracy = mean) |>
      mutate(model = "baseline", .before = "accuracy")
  ) |>
  bind_rows(
    show_best_params(bt_tuned, "accuracy") |>
      mutate(model = "bt", .before = "accuracy")
  ) |>
  bind_rows(
    show_best_params(knn_tuned, "accuracy") |>
      mutate(model = "knn", .before = "accuracy")
  ) |> arrange(desc(accuracy))

# write out parameter table
save(table_best_params, file = here("results/table_best_params.rda"))

##########################################################################
# Model analysis ----
##########################################################################

metrics1 <- collect_metrics(baseline_tuned) |>
  mutate(model = "baseline") |>
  select(model, .metric, mean, std_err)

metrics2 <- collect_metrics(lm_fit) |>
  mutate(model = "lm") |>
  select(model, .metric, mean, std_err)

metrics3 <- collect_metrics(nnet_tuned) |>
  mutate(model = "nnet") |>
  select(model, .metric, mean, std_err)

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
table_best_means <-
  bind_rows(metrics1, metrics2, metrics3, metrics4, metrics5, metrics6) |>
  filter(.metric == "accuracy") |>
  group_by(model) |>
  summarise(mean = mean(mean), std_err = mean(std_err)) |>
  arrange(desc(mean))

# write out means table
save(table_best_means, file = here("results/table_best_means.rda"))


##########################################################################
# Print and format tables ----
##########################################################################

library(gt)

table_best_params <- table_best_params |>
  gt(rowname_col = "model") |>
  fmt_number(columns = accuracy, decimals = 5) |>
  fmt_scientific(columns = std_err, decimals = 4) |>
  fmt_integer(columns = value, rows = c(1:5, 7:11)) |>
  tab_header(
    title = md("**Best performing model results**"),
    subtitle = md("**Neural network** and **boosted tree** models performed best.")
  ) |>
  tab_stubhead(label = "model") |>
  tab_footnote(
    footnote = "No parameters tuned",
    locations = cells_body(columns = c(parameter, value), rows = 9:10)
  )

table_best_means <- table_best_means |>
  gt(rowname_col = "model") |>
  fmt_number(columns = mean, decimals = 5) |>
  fmt_scientific(columns = std_err, decimals = 4) |>
  tab_header(
    title = md("**Mean model accuracy across parameters**"),
    subtitle = md("**Logistic** and **random forest** models performed best.")
  ) |>
  tab_stubhead(label = "model")

gtsave(table_best_params, here("images/table_best_params.png"))
gtsave(table_best_means, here("images/table_best_means.png"))
