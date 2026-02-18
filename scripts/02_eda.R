# Big Mart Sales Prediction — EDA + Preprocessing

# Load required libraries
source("scripts/00_libraries.R")

# UNIVARIATE ANALYSIS

# Target variable distribution
ggplot(train) +
  geom_histogram(aes(Item_Outlet_Sales), binwidth = 100, fill = "darkgreen") +
  labs(x = "Item_Outlet_Sales", y = "Count", title = "Target Distribution: Item_Outlet_Sales") +
  theme_minimal()

# Numerical variables
p1 = ggplot(combi) + geom_histogram(aes(Item_Weight), binwidth = 0.5, fill = "blue") +
  labs(title = "Item_Weight", x = "Item_Weight", y = "Count") + theme_minimal()
p2 = ggplot(combi) + geom_histogram(aes(Item_Visibility), binwidth = 0.005, fill = "blue") +
  labs(title = "Item_Visibility", x = "Item_Visibility", y = "Count") + theme_minimal()
p3 = ggplot(combi) + geom_histogram(aes(Item_MRP), binwidth = 1, fill = "blue") +
  labs(title = "Item_MRP", x = "Item_MRP", y = "Count") + theme_minimal()

plot_grid(p1, p2, p3, nrow = 1)

# Categorical variables: Item_Fat_Content (before cleaning)
fat_counts_before = combi %>%
  group_by(Item_Fat_Content) %>%
  summarise(Count = n(), .groups = "drop")

ggplot(fat_counts_before) +
  geom_bar(aes(Item_Fat_Content, Count), stat = "identity", fill = "coral1") +
  labs(title = "Item_Fat_Content (Before Cleaning)", x = "Item_Fat_Content", y = "Count") +
  theme_minimal()

# Clean Item_Fat_Content categories
combi$Item_Fat_Content[combi$Item_Fat_Content %in% c("LF", "low fat")] = "Low Fat"
combi$Item_Fat_Content[combi$Item_Fat_Content == "reg"] = "Regular"

# Item_Fat_Content (after cleaning)
fat_counts_after = combi %>%
  group_by(Item_Fat_Content) %>%
  summarise(Count = n(), .groups = "drop")

ggplot(fat_counts_after) +
  geom_bar(aes(Item_Fat_Content, Count), stat = "identity", fill = "coral1") +
  labs(title = "Item_Fat_Content (After Cleaning)", x = "Item_Fat_Content", y = "Count") +
  theme_minimal()

# Other categorical variables (counts)
item_type_counts = combi %>% group_by(Item_Type) %>% summarise(Count = n(), .groups = "drop")
outlet_id_counts = combi %>% group_by(Outlet_Identifier) %>% summarise(Count = n(), .groups = "drop")
outlet_size_counts = combi %>% group_by(Outlet_Size) %>% summarise(Count = n(), .groups = "drop")

p4 = ggplot(item_type_counts) +
  geom_bar(aes(Item_Type, Count), stat = "identity", fill = "coral1") +
  geom_label(aes(Item_Type, Count, label = Count), vjust = 0.5) +
  labs(title = "Item_Type", x = "", y = "Count") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

p5 = ggplot(outlet_id_counts) +
  geom_bar(aes(Outlet_Identifier, Count), stat = "identity", fill = "coral1") +
  geom_label(aes(Outlet_Identifier, Count, label = Count), vjust = 0.5) +
  labs(title = "Outlet_Identifier", x = "", y = "Count") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

p6 = ggplot(outlet_size_counts) +
  geom_bar(aes(Outlet_Size, Count), stat = "identity", fill = "coral1") +
  geom_label(aes(Outlet_Size, Count, label = Count), vjust = 0.5) +
  labs(title = "Outlet_Size", x = "", y = "Count") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

second_row = plot_grid(p5, p6, nrow = 1)
plot_grid(p4, second_row, ncol = 1)

# Remaining categorical variables
year_counts = combi %>% group_by(Outlet_Establishment_Year) %>% summarise(Count = n(), .groups = "drop")
outlet_type_counts = combi %>% group_by(Outlet_Type) %>% summarise(Count = n(), .groups = "drop")

p7 = ggplot(year_counts) +
  geom_bar(aes(factor(Outlet_Establishment_Year), Count), stat = "identity", fill = "coral1") +
  geom_label(aes(factor(Outlet_Establishment_Year), Count, label = Count), vjust = 0.5) +
  labs(title = "Outlet_Establishment_Year", x = "Outlet_Establishment_Year", y = "Count") +
  theme_minimal() +
  theme(axis.text.x = element_text(size = 8.5))

p8 = ggplot(outlet_type_counts) +
  geom_bar(aes(Outlet_Type, Count), stat = "identity", fill = "coral1") +
  geom_label(aes(Outlet_Type, Count, label = Count), vjust = 0.5) +
  labs(title = "Outlet_Type", x = "Outlet_Type", y = "Count") +
  theme_minimal() +
  theme(axis.text.x = element_text(size = 8.5))

plot_grid(p7, p8, ncol = 2)

# BIVARIATE ANALYSIS

# Extract train portion from combined dataset
train = combi[1:nrow(train)]

# Target vs numerical variables
p9 = ggplot(train) + geom_point(aes(Item_Weight, Item_Outlet_Sales), colour = "violet", alpha = 0.3) +
  labs(title = "Item_Weight vs Item_Outlet_Sales", x = "Item_Weight", y = "Item_Outlet_Sales") +
  theme_minimal() + theme(axis.title = element_text(size = 8.5))

p10 = ggplot(train) + geom_point(aes(Item_Visibility, Item_Outlet_Sales), colour = "violet", alpha = 0.3) +
  labs(title = "Item_Visibility vs Item_Outlet_Sales", x = "Item_Visibility", y = "Item_Outlet_Sales") +
  theme_minimal() + theme(axis.title = element_text(size = 8.5))

p11 = ggplot(train) + geom_point(aes(Item_MRP, Item_Outlet_Sales), colour = "violet", alpha = 0.3) +
  labs(title = "Item_MRP vs Item_Outlet_Sales", x = "Item_MRP", y = "Item_Outlet_Sales") +
  theme_minimal() + theme(axis.title = element_text(size = 8.5))

second_row_2 = plot_grid(p10, p11, ncol = 2)
plot_grid(p9, second_row_2, nrow = 2)

# Target vs categorical variables
p12 = ggplot(train) + geom_violin(aes(Item_Type, Item_Outlet_Sales), fill = "magenta") +
  labs(title = "Item_Type vs Item_Outlet_Sales", x = "Item_Type", y = "Item_Outlet_Sales") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1),
        axis.text = element_text(size = 6),
        axis.title = element_text(size = 8.5))

p13 = ggplot(train) + geom_violin(aes(Item_Fat_Content, Item_Outlet_Sales), fill = "magenta") +
  labs(title = "Item_Fat_Content vs Item_Outlet_Sales", x = "Item_Fat_Content", y = "Item_Outlet_Sales") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1),
        axis.text = element_text(size = 8),
        axis.title = element_text(size = 8.5))

p14 = ggplot(train) + geom_violin(aes(Outlet_Identifier, Item_Outlet_Sales), fill = "magenta") +
  labs(title = "Outlet_Identifier vs Item_Outlet_Sales", x = "Outlet_Identifier", y = "Item_Outlet_Sales") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1),
        axis.text = element_text(size = 8),
        axis.title = element_text(size = 8.5))

second_row_3 = plot_grid(p13, p14, ncol = 2)
plot_grid(p12, second_row_3, nrow = 2)

ggplot(train) +
  geom_violin(aes(Outlet_Size, Item_Outlet_Sales), fill = "magenta") +
  labs(title = "Outlet_Size vs Item_Outlet_Sales", x = "Outlet_Size", y = "Item_Outlet_Sales") +
  theme_minimal()

p15 = ggplot(train) + geom_violin(aes(Outlet_Location_Type, Item_Outlet_Sales), fill = "magenta") +
  labs(title = "Outlet_Location_Type vs Item_Outlet_Sales", x = "Outlet_Location_Type", y = "Item_Outlet_Sales") +
  theme_minimal()

p16 = ggplot(train) + geom_violin(aes(Outlet_Type, Item_Outlet_Sales), fill = "magenta") +
  labs(title = "Outlet_Type vs Item_Outlet_Sales", x = "Outlet_Type", y = "Item_Outlet_Sales") +
  theme_minimal()

plot_grid(p15, p16, nrow = 2)

# MISSING VALUES TREATMENT

sum(is.na(combi$Item_Weight))

missing_index = which(is.na(combi$Item_Weight))
for (i in missing_index) {
  item = combi$Item_Identifier[i]
  combi$Item_Weight[i] = mean(combi$Item_Weight[combi$Item_Identifier == item], na.rm = TRUE)
}

sum(is.na(combi$Item_Weight))

ggplot(combi) +
  geom_histogram(aes(Item_Visibility), bins = 100) +
  labs(title = "Item_Visibility (Before Zero Replacement)", x = "Item_Visibility", y = "Count") +
  theme_minimal()

zero_index = which(combi$Item_Visibility == 0)
for (i in zero_index) {
  item = combi$Item_Identifier[i]
  combi$Item_Visibility[i] = mean(combi$Item_Visibility[combi$Item_Identifier == item], na.rm = TRUE)
}

ggplot(combi) +
  geom_histogram(aes(Item_Visibility), bins = 100) +
  labs(title = "Item_Visibility (After Zero Replacement)", x = "Item_Visibility", y = "Count") +
  theme_minimal()

# FEATURE ENGINEERING

perishable = c("Breads", "Breakfast", "Dairy", "Fruits and Vegetables", "Meat", "Seafood")
non_perishable = c("Baking Goods", "Canned", "Frozen Foods", "Hard Drinks",
                   "Health and Hygiene", "Household", "Soft Drinks")

# Item_Type_new: broader categories
combi[, Item_Type_new := fifelse(
  Item_Type %in% perishable, "perishable",
  fifelse(Item_Type %in% non_perishable, "non_perishable", "not_sure")
)]

# Item_category: derived from Item_Identifier (DR/FD/NC)
combi[, Item_category := substr(Item_Identifier, 1, 2)]
combi[Item_category == "NC", Item_Fat_Content := "Non-edible"]

# Outlet_Years: years of operation (data collected in 2013)
combi[, Outlet_Years := 2013 - Outlet_Establishment_Year]
combi[, Outlet_Establishment_Year := as.factor(Outlet_Establishment_Year)]

# Price_per_unit_wt: Item_MRP / Item_Weight
combi[, Price_per_unit_wt := Item_MRP / Item_Weight]

# Item_MRP_clusters: binned MRP feature
combi[, Item_MRP_clusters := fifelse(
  Item_MRP < 69, "1st",
  fifelse(Item_MRP < 136, "2nd",
          fifelse(Item_MRP < 203, "3rd", "4th"))
)]

# ENCODING CATEGORICAL VARIABLES

# Ordinal encoding
combi[, Outlet_Size_num := fifelse(Outlet_Size == "Small", 0L,
                                   fifelse(Outlet_Size == "Medium", 1L, 2L))]

combi[, Outlet_Location_Type_num := fifelse(Outlet_Location_Type == "Tier 3", 0L,
                                            fifelse(Outlet_Location_Type == "Tier 2", 1L, 2L))]

# Remove original ordinal categorical features
combi[, c("Outlet_Size", "Outlet_Location_Type") := NULL]

# One-hot encoding for remaining categorical variables
ohe_data = combi[, -c("Item_Identifier", "Outlet_Establishment_Year", "Item_Type"), with = FALSE]

ohe = dummyVars("~ .", data = ohe_data, fullRank = TRUE)
ohe_df = as.data.table(predict(ohe, ohe_data))

combi = cbind(combi[, .(Item_Identifier)], ohe_df)

# DATA PREPROCESSING

# Remove skewness
combi[, Item_Visibility := log1p(Item_Visibility)]
combi[, Price_per_unit_wt := log1p(Price_per_unit_wt)]

# Scale numeric predictors (exclude target)
num_cols = names(which(sapply(combi, is.numeric)))
num_x = setdiff(num_cols, "Item_Outlet_Sales")

prep_num = preProcess(combi[, ..num_x], method = c("center", "scale"))
combi_scaled = predict(prep_num, combi[, ..num_x])

combi[, (num_x) := NULL]
combi = cbind(combi, combi_scaled)

# SPLIT BACK INTO TRAIN AND TEST

n_train = nrow(train)
train = combi[1:n_train]
test = combi[(n_train + 1):nrow(combi)]
test[, Item_Outlet_Sales := NULL]

# CORRELATION ANALYSIS

cor_train = cor(train[, !c("Item_Identifier"), with = FALSE])
corrplot(cor_train, method = "color", type = "lower", tl.cex = 0.5, cl.cex = 0.5)

