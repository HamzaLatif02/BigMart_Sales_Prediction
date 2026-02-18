# Big Mart Sales Prediction — Modelling (RMSE)

source("scripts/00_libraries.R")

dir.create("submission", showWarnings = FALSE)

# Helper Functions

clip_negatives = function(x) {
  x[x < 0] = 0
  x
}

save_submission = function(pred, submission_df, path) {
  submission_df$Item_Outlet_Sales = pred
  write.csv(submission_df, path, row.names = FALSE)
}

get_xy = function(train_df, test_df, drop_cols = c("Item_Identifier", "Item_Outlet_Sales")) {
  x_train = train_df[, setdiff(names(train_df), drop_cols), with = FALSE]
  y_train = train_df$Item_Outlet_Sales
  x_test = test_df[, names(x_train), with = FALSE]
  list(x_train = x_train, y_train = y_train, x_test = x_test)
}

# LINEAR REGRESSION (log target)

train_lr = copy(train)
train_lr$log_sales = log1p(train_lr$Item_Outlet_Sales)

linear_reg_mod = lm(log_sales ~ ., data = train_lr[, -c("Item_Identifier", "Item_Outlet_Sales"), with = FALSE])

log_preds = predict(linear_reg_mod, newdata = test[, -c("Item_Identifier"), with = FALSE])
preds = expm1(log_preds)
preds = clip_negatives(preds)

save_submission(preds, submission, "submission/Linear_Reg.csv")

# REGULARISED LINEAR REGRESSION (caret + glmnet)

xy = get_xy(train, test)

my_control = trainControl(method = "cv", number = 5)

lambda_grid = seq(0.001, 0.1, by = 0.0002)

run_glmnet = function(alpha_value, seed_value, out_path) {
  set.seed(seed_value)
  
  Grid = expand.grid(alpha = alpha_value, lambda = lambda_grid)
  
  mod = train(
    x = xy$x_train,
    y = xy$y_train,
    method = "glmnet",
    trControl = my_control,
    tuneGrid = Grid,
    metric = "RMSE"
  )
  
  best_rmse = min(mod$results$RMSE)
  
  pred_test = predict(mod, newdata = xy$x_test)
  pred_test = clip_negatives(pred_test)
  
  save_submission(pred_test, submission, out_path)
  
  list(model = mod, best_rmse = best_rmse)
}

lasso_out = run_glmnet(alpha_value = 1, seed_value = 1235, out_path = "submission/Lasso_Reg.csv")
lasso_rmse = lasso_out$best_rmse

ridge_out = run_glmnet(alpha_value = 0, seed_value = 1236, out_path = "submission/Ridge_Reg.csv")
ridge_rmse = ridge_out$best_rmse

# RANDOM FOREST (caret + ranger)

set.seed(1237)

rf_control = trainControl(method = "cv", number = 5)

tgrid = expand.grid(
  .mtry = 3:10,
  .splitrule = "variance",
  .min.node.size = c(10, 15, 20)
)

rf_mod = train(
  x = xy$x_train,
  y = xy$y_train,
  method = "ranger",
  trControl = rf_control,
  tuneGrid = tgrid,
  num.trees = 400,
  importance = "permutation",
  metric = "RMSE"
)

rf_rmse = min(rf_mod$results$RMSE)

rf_pred = predict(rf_mod, newdata = xy$x_test)
rf_pred = clip_negatives(rf_pred)

save_submission(rf_pred, submission, "submission/Random_Forest.csv")

plot(rf_mod)
plot(varImp(rf_mod))

# XGBOOST (xgboost native)

param_list = list(
  objective = "reg:squarederror",
  eta = 0.1,
  gamma = 1,
  max_depth = 6,
  subsample = 0.8,
  colsample_bytree = 0.5
)

dtrain = xgb.DMatrix(data = as.matrix(xy$x_train), label = xy$y_train)
dtest = xgb.DMatrix(data = as.matrix(xy$x_test))

set.seed(112)

xgbcv = xgb.cv(
  params = param_list,
  data = dtrain,
  nrounds = 1000,
  nfold = 5,
  print_every_n = 10,
  early_stopping_rounds = 30,
  maximize = FALSE
)

xgb_model = xgb.train(
  data = dtrain,
  params = param_list,
  nrounds = 72
)

xgb_pred = predict(xgb_model, dtest)
xgb_pred = clip_negatives(xgb_pred)

save_submission(xgb_pred, submission, "submission/XGBoost.csv")

# XGBoost feature importance
feature_names = names(xy$x_train)
var_imp = xgb.importance(feature_names = feature_names, model = xgb_model)
xgb.plot.importance(var_imp)

# Print RMSE summary
rmse_summary = data.frame(
  Model = c("Lasso", "Ridge", "Random Forest", "XGBoost"),
  RMSE = c(lasso_rmse, ridge_rmse, rf_rmse, xgbcv$evaluation_log[72]$test_rmse_mean)
)

rmse_summary
