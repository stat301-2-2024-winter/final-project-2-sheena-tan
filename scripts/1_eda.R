# Exploratory Data Analysis
# inspect target variable + other questions of interest

# load packages
library(tidyverse)
library(patchwork)
library(here)
library(ggthemes)


# factor variables eda ----
plot_stacked_bar <- function(data, x_variable, fill_variable) {
  ggplot(data, aes({{x_variable}}, fill = {{fill_variable}})) +
    geom_bar(position = "fill") +
    scale_x_discrete(labels = c("Not Skipped", "Skipped")) +
    theme_fivethirtyeight() +
    theme(
      axis.title.y = element_blank(),
      axis.title.x = element_blank(),
      legend.title = element_blank(),
      legend.background = element_blank(),
      legend.position = "bottom",
      plot.title = element_text(size = 12, hjust = 0.5),
      plot.subtitle = element_text(size = 10, hjust = 0.5),
      panel.background = element_blank(),
      plot.background = element_blank(),
    )
}

stacked_context <- spotify_eda |> plot_stacked_bar(skip_2, context_type) +
  labs(
    title = "Playlist context does not seem to affect skip behavior.",
    subtitle = "e.g., personalized playlists, radio, editorial playlists"
  )


stacked_start <- spotify_eda |> plot_stacked_bar(skip_2, hist_user_behavior_reason_start) +
  labs(
    title = "The way the song starts affects skip behavior.",
    subtitle = "e.g., previous song finishing, skipping previous song"
  ) +
  annotate(
    "text", x = 2, y = 0.5,
    label = "Songs are more\nlikely to be skipped\nif they were\nskipped to!",
    color = "white",
    fontface = "bold"
  ) +
  annotate(
    "text", x = 1, y = 0.3,
    label = "Songs are less\nlikely to be skipped\nif the song before\nthem wasn't!",
    color = "white",
    fontface = "bold"
  )

stacked_key <- spotify_eda |> plot_stacked_bar(skip_2, key) +
  labs(title = "Key")

stacked_mode <- spotify_eda |> plot_stacked_bar(skip_2, mode) +
  labs(title = "Mode")

stacked_time_signature <- spotify_eda |> plot_stacked_bar(skip_2, time_signature) +
  labs(title = "Time Signature")


# hour of day ----
hour_data <- spotify_eda |> count(hour_of_day, skip_2) |>
  group_by(hour_of_day) |>
  mutate(percent_skip = n / sum(n)) |>
  filter(skip_2 == TRUE)

plot_hour <- ggplot(hour_data, aes(hour_of_day, percent_skip)) +
  geom_line() +
  geom_point(aes(color = "red")) +
  ylim(0, 1) +
  theme_fivethirtyeight() +
  theme(
    legend.title = element_blank(),
    legend.background = element_blank(),
    legend.position = "none",
    plot.title = element_text(size = 12, hjust = 0.5),
    plot.subtitle = element_text(size = 10, hjust = 0.5),
    panel.background = element_blank(),
    plot.background = element_blank(),
    axis.title.x = element_text(size = 10, vjust = 0),
    axis.title.y = element_text(size = 10),
  ) +
  labs(
    title = "When do people skip the most?",
    subtitle = "Skipping rate is lowest when people are asleep.",
    x = "Hour of Day",
    y = "Percentage of Songs Skipped"
  )

# hour of day AND amount of plays
play_data <- spotify_eda |> count(hour_of_day) |>
  arrange(desc(n)) |>
  mutate(percent_plays = n / n[1])

plot_plays <- ggplot(hour_data, aes(hour_of_day, percent_skip)) +
  geom_line() +
  geom_point(aes(color = "red")) +
  geom_line(data = play_data, aes(hour_of_day, percent_plays)) +
  geom_point(data = play_data, aes(hour_of_day, percent_plays, color = "skyblue")) +
  theme_fivethirtyeight() +
  ylim(0, 1) +
  theme(
    legend.title = element_blank(),
    legend.background = element_blank(),
    legend.position = "none",
    plot.title = element_text(size = 12, hjust = 0.5),
    plot.subtitle = element_text(size = 10, hjust = 0.5),
    panel.background = element_blank(),
    plot.background = element_blank(),
    axis.title.x = element_text(size = 10, vjust = 0),
    axis.title.y = element_text(size = 10),
  ) +
  labs(
    title = "How does skip rate relate to play rate?",
    subtitle = "At night, people play less and skip less. During the day, it's different.",
    x = "Hour of Day",
    y = "Percentage"
  )

# day of week
spotify_eda |> mutate(wday = wday(date, label = TRUE)) |>
  count(wday, skip_2)

# date/season
spotify_eda |> mutate(month = month(date)) |>
  count(month, skip_2)


ggsave(here("images/stacked_context.png"), stacked_context)
ggsave(here("images/stacked_start.png"), stacked_start)
ggsave(here("images/stacked_key.png"), stacked_key)
ggsave(here("images/stacked_mode.png"), stacked_mode)
ggsave(here("images/stacked_time_signature.png"), stacked_time_signature)
ggsave(here("images/plot_hour.png"), plot_hour)
ggsave(here("images/plot_plays.png"), plot_plays)
