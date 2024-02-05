# Exploratory Data Analysis
# inspect target variable + other questions of interest

# load packages
library(tidyverse)
library(patchwork)
library(here)

# load data
spotify_eda <- readRDS(here("data/spotify_eda.rds"))

# inspect target variable ----

# factor variables
plot_stacked_bar <- function(data, x_variable, fill_variable) {
  ggplot(data, aes({{x_variable}}, fill = {{fill_variable}})) +
    geom_bar(position = "stack") +
    theme(legend.position = "bottom", legend.title = element_blank())
}

plot1 <- spotify_eda |> plot_stacked_bar(skip_2, context_type)
plot2 <- spotify_eda |> plot_stacked_bar(skip_2, hist_user_behavior_reason_start)
plot3 <- spotify_eda |> plot_stacked_bar(skip_2, hist_user_behavior_reason_end)
plot4 <- spotify_eda |> plot_stacked_bar(skip_2, key)
plot5 <- spotify_eda |> plot_stacked_bar(skip_2, mode)
plot6 <- spotify_eda |> plot_stacked_bar(skip_2, time_signature)

plot1 + plot2
plot3 + plot4
plot5 + plot6

# skips but goes back?

# how often skip?
#### % listeners vs % song listened to
#### skip rate(%) within in the first 60 seconds of a song

# who skips?
#### premium or not?
#### user playlist, editorial, radio, personal playlist...?

# when skip?
#### hour of the day?
#### day of week?
#### date/season?

# album art?
