# COMPARE RESULTS
# Data
model_results <- data.frame(
  Model = c("Lasso", "Ridge", "Random Forest", "XGBoost"),
  RMSE = c(1129.527, 1134.585, 1086.488, 1104.560),
  Submission = c(1185.455, 1195.369, 1158.289, 1164.868)
)

# Long format for plotting
model_results_long <- model_results %>%
  pivot_longer(cols = c(RMSE, Submission),
               names_to = "Metric",
               values_to = "Value")

# Grouped Bar Chart
ggplot(model_results_long, 
       aes(x = Model, y = Value, fill = Metric)) +
  geom_bar(
    stat = "identity",
    position = position_dodge(width = 0.8),
    width = 0.6
  ) +
  labs(
    title = "Model Performance Comparison",
    subtitle = "Lower values indicate better performance",
    x = "Model",
    y = "Score"
  ) +
  theme_minimal(base_size = 14) +
  scale_fill_manual(values = c("#1f77b4", "#ff7f0e")) +
  theme(
    plot.title = element_text(hjust = 0.5, face = "bold"),
    plot.subtitle = element_text(hjust = 0.5)
  )


# Horizontal Bar Chart Sorted by RMSE
# Sort by RMSE
rmse_sorted <- model_results %>%
  arrange(RMSE) %>%
  mutate(Highlight = ifelse(RMSE == min(RMSE), "Best", "Other"))

ggplot(rmse_sorted,
       aes(x = reorder(Model, -RMSE), 
           y = RMSE, 
           fill = Highlight)) +
  geom_bar(stat = "identity", width = 0.6) +
  coord_flip() +
  scale_fill_manual(values = c("Best" = "#2ca02c", "Other" = "#d3d3d3")) +
  labs(
    title = "Model RMSE Comparison",
    subtitle = "Lowest RMSE highlighted (Lower is Better)",
    x = "Model",
    y = "RMSE"
  ) +
  theme_minimal(base_size = 14) +
  theme(
    legend.position = "none",
    plot.title = element_text(hjust = 0.5, face = "bold"),
    plot.subtitle = element_text(hjust = 0.5)
  )


# Horizontal Bar Chart Sorted by Submission
sub_sorted <- model_results %>%
  arrange(Submission) %>%
  mutate(Highlight = ifelse(Submission == min(Submission), "Best", "Other"))

ggplot(sub_sorted,
       aes(x = reorder(Model, -Submission), 
           y = Submission, 
           fill = Highlight)) +
  geom_bar(stat = "identity", width = 0.6) +
  coord_flip() +
  scale_fill_manual(values = c("Best" = "#2ca02c", "Other" = "#d3d3d3")) +
  labs(
    title = "Model Submission Score Comparison",
    subtitle = "Lowest Submission Score Highlighted (Lower is Better)",
    x = "Model",
    y = "Submission Score"
  ) +
  theme_minimal(base_size = 14) +
  theme(
    legend.position = "none",
    plot.title = element_text(hjust = 0.5, face = "bold"),
    plot.subtitle = element_text(hjust = 0.5)
  )

