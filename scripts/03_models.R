# Evaluation Metric: RMSE (Root Mean Squared Error)

# LINEAR REGRESSION
# To avoid negative values in the prediction, we train on log-transformed target.
train_lr <- copy(train) # make a copy of train set
train_lr$log_sales <- log1p(train_lr$Item_Outlet_Sales)
# Building the model
linear_reg_mod = lm(log_sales ~., data = train_lr[,-c("Item_Identifier",  'Item_Outlet_Sales')])
# Making predictions on the test dataset
log_preds = predict(linear_reg_mod, test[,-c('Item_Identifier')])
preds = expm1(log_preds) # convert back
preds[preds < 0 ] = 0 # ensure no negatives (rare after log)
submission$Item_Outlet_Sales = preds
write.csv(submission, 'submission/Linear_Reg.csv', row.names = F)

# linear regression submission score: 1181.589

# REGULARISD LINEAR REGRESSION
# Lasso Regression
# train model
set.seed(1235)
my_control = trainControl(method='cv', number=5)
Grid = expand.grid(alpha = 1, lambda = seq(0.001, 0.1, by=0.0002))
lasso_linear_reg_mod = train(x=train[,-c("Item_Identifier", 'Item_Outlet_Sales')], y = train$Item_Outlet_Sales, method='glmnet', trControl = my_control, tuneGrid = Grid)
min(lasso_linear_reg_mod$results$RMSE) # extract lowest RMSE across all lambdas
# predict and save
pred_test = predict(lasso_linear_reg_mod, test[,-c("Item_Identifier")])
pred_test[pred_test < 0] = 0
submission$Item_Outlet_Sales = pred_test
write.csv(submission,'submission/Lasso_Reg.csv', row.names = F)

# lasso regression RMSE: 1129.527
# lasso regression submission score: 1185.455

# Ridge Regression
# train model
set.seed(1236)
my_control = trainControl(method='cv', number = 5)
Grid = expand.grid(alpha = 0, lambda = seq(0.001, 0.1, by = 0.0002))
ridge_linear_red_mod = train(x = train[, -c('Item_Identifier', 'Item_Outlet_Sales')], y = train$Item_Outlet_Sales, method ='glmnet', trControl = my_control, tuneGrid = Grid)
min(ridge_linear_red_mod$results$RMSE) # extract lowest RMSE across all lambdas
# predict and save
pred_test = predict(ridge_linear_red_mod, test[, -c("Item_Identifier")])
pred_test[pred_test < 0] = 0
submission$Item_Outlet_Sales = pred_test
write.csv(submission, 'submission/Ridge_Reg.csv', row.names = F)

# ridge regression RMSE: 1134.585
# ridge regression submission score: 1195.369

# RANDOM FOREST
# train model
set.seed(1237)
my_control = trainControl(method = 'cv', number = 5) # 5-fold CV
tgrid = expand.grid(.mtry = c(3:10), .splitrule = 'variance', .min.node.size = c(10,15,20))
rf_mod = train(x = train[, -c('Item_Identifier', 'Item_Outlet_Sales')], y = train$Item_Outlet_Sales, method = 'ranger', trControl = my_control, tuneGrid = tgrid, num.trees = 400, importance = 'permutation')
min(rf_mod$results$RMSE) # extract lowest RMSE across all lambdas
# predict and save
pred_test = predict(rf_mod, test[, -c('Item_Identifier')])
pred_test[pred_test < 0] = 0
submission$Item_Outlet_Sales = pred_test
write.csv(submission, 'submission/Random_Forest.csv', row.names = F)

# random forest RMSE: 1086.488
# random forest submission score: 1158.289

# best model parameters
plot(rf_mod)
# variable importance
plot(varImp(rf_mod))

# XGBOOST
# setup
param_list = list(objective='reg:squarederror', eta=0.1, gamma=1, max_depth=6, subsample=0.8, colsample_bytree=0.5)
dtrain = xgb.DMatrix(data = as.matrix(train[,-c('Item_Identifier', 'Item_Outlet_Sales')]), label = train$Item_Outlet_Sales)
dtest = xgb.DMatrix(data = as.matrix(test[,-c('Item_Identifier')]))
# cross validation to find optimal value of nrounds
set.seed(112)
xgbcv = xgb.cv(params = param_list, data = dtrain, nrounds = 1000, nfold = 5, print_every_n = 10, early_stopping_rounds = 30, maximize = F)
# the best test score is at the 72nd iteration.
# build model
xgb_model = xgb.train(data = dtrain, params = param_list, nrounds = 72)
# predict and save
pred_test = predict(xgb_model, dtest)
pred_test[pred_test < 0] = 0
submission$Item_Outlet_Sales = pred_test
write.csv(submission, 'submission/XGBoost.csv', row.names = F)

# xgboost RMSE: 1104.560
# xgboost submission score: 1164.868

# variable importance
var_imp = xgb.importance(feature_names = setdiff(names(train), c('Item_Identifier', 'Item_Outlet_Sales')), model = xgb_model)
xgb.plot.importance(var_imp)

