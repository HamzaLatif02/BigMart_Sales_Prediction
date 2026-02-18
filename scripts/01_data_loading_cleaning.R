# Big Mart Sales Prediction — Setup & Data Loading

# Load required libraries
source("scripts/00_libraries.R")

# Load datasets
train = fread("datasets/train_v9rqX0R.csv")
test = fread("datasets/test_AbJTz2l.csv")
submission = fread("datasets/sample_submission_8RXa3c6.csv")

# Basic checks

# Dimensions (rows, columns)
dim(train)
dim(test)
dim(submission)

# Column names
names(train)
names(test)

# Data structure summary
str(train)
str(test)

# Combine train and test
# Useful for consistent preprocessing/encoding
test[, Item_Outlet_Sales := NA]
combi <- rbind(train, test)

dim(combi)
