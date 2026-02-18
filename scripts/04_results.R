# Big Mart Sales Prediction — Results & Visual Comparison

source("scripts/00_libraries.R")

# Results Data

model_results = data.frame(
  Model = c("Lasso", "Ridge", "Random Forest", "XGBoost"),
  RMSE = c(1129.527, 1134.585, 1086.488, 1104.560),
  Submission = c(1185.455, 1195.369, 1158.289, 1164.868)
)

# Helper Functions

to_long = function(df) {
  df %>%
    pivot_longer(
      cols = c(RMSE, Submission),
      names_to = "Metric",
      values_to = "Value"
    )
}

plot_grouped_bars = function(df_long, title, subtitle) {
  ggplot(df_long, aes(x = Model, y = Value, fill = Metric)) +
    geom_bar(
      stat = "identity",
      position = position_dodge(width = 0.8),
      width = 0.6
    ) +
    labs(title = title, subtitle = subtitle, x = "Model", y = "Score") +
    theme_minimal(base_size = 14) +
    scale_fill_manual(values = c("RMSE" = "#1f77b4", "Submission" = "#ff7f0e")) +
    theme(
      plot.title = element_text(hjust = 0.5, face = "bold"),
      plot.subtitle = element_text(hjust = 0.5)
    )
}

plot_sorted_highlight = function(df, metric_col, title, subtitle, ylab) {
  df_plot = df %>%
    arrange(.data[[metric_col]]) %>%
    mutate(Highlight = ifelse(.data[[metric_col]] == min(.data[[metric_col]]), "Best", "Other"))
  
  ggplot(df_plot, aes(x = reorder(Model, -.data[[metric_col]]), y = .data[[metric_col]], fill = Highlight)) +
    geom_bar(stat = "identity", width = 0.6) +
    coord_flip() +
    scale_fill_manual(values = c("Best" = "#2ca02c", "Other" = "#d3d3d3")) +
    labs(title = title, subtitle = subtitle, x = "Model", y = ylab) +
    theme_minimal(base_size = 14) +
    theme(
      legend.position = "none",
      plot.title = element_text(hjust = 0.5, face = "bold"),
      plot.subtitle = element_text(hjust = 0.5)
    )
}

# 1) Grouped bar chart (RMSE vs Submission)

model_results_long = to_long(model_results)

plot_grouped_bars(
  df_long = model_results_long,
  title = "Model Performance Comparison",
  subtitle = "Lower values indicate better performance"
)

# 2) Horizontal bar chart sorted by RMSE (highlight best)

plot_sorted_highlight(
  df = model_results,
  metric_col = "RMSE",
  title = "Model RMSE Comparison",
  subtitle = "Lowest RMSE highlighted (Lower is Better)",
  ylab = "RMSE"
)

# 3) Horizontal bar chart sorted by Submission (highlight best)

plot_sorted_highlight(
  df = model_results,
  metric_col = "Submission",
  title = "Model Submission Score Comparison",
  subtitle = "Lowest Submission score highlighted (Lower is Better)",
  ylab = "Submission Score"
)
