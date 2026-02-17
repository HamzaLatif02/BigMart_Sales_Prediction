library(data.table) #used for reading and manipulation of data
library(dplyr) #used for data manipulation and joining
library(ggplot2) #used doe plotting
library(caret) #used for modeling
library(corrplot) #used for making correlation plot
library(xgboost) #used for building XGBoost model
library(cowplot) #used for combining multiple plots
library(tidyr) #used to clean data in tidy format

#load datasets
train = fread("datasets/train_v9rqX0R.csv")
test = fread("datasets/test_AbJTz2l.csv")
submission = fread("datasets/sample_submission_8RXa3c6.csv")

# check dimensions of datasets (columns and rows)
dim(train);dim(test);dim(submission);

# quick glance over the feature names of train and test datasets
names(train)
names(test)

# use .str() function to get a short summary of all the features present in the dataset.
str(train)
str(test)

# combine train and test data for easier data manipulation and handling
test[,Item_Outlet_Sales := NA]
combi = rbind(train, test) #combining train and test datasets
dim(combi)