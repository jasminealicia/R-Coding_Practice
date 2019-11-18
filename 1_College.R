# Jasmine Clark
#ADS 635 Data Mining I Homework 2
# (1.) College Data set 

#clear workspace
rm(list = ls())

#set the directory we are working in
setwd("/Users/jasmineclark/Documents/Bay Path MSADS/ADS 635/Homework/Homework 2")

#install the packages needed
install.packages("ISLR")
install.packages("glmnet")
install.packages("pls")
library(ISLR)
library(glmnet)
library(pls)

#let's look at the data to get a feel for it
data("College")
?College
dim(College)
names(College)
sum(is.na(College)) #no missing values woohoo!


##########################################
#(a.) Split into training and test sets
#Fit a linear model and report test error
##########################################
# We will split 80:20. Answers will vary depending on the split decision!
set.seed(12345)
train <- sample(1:nrow(College), nrow(College)*0.80)
college.train <- College[train,]
college.test <- College[-train,]

#fit
fit <- lm(Apps ~., data = college.train)

#prediction error/ test error
prediction = predict(fit, college.test)
mean((college.test[, "Apps"] - prediction)^2) #Test error: 2645751


##########################################
#(b.) Ridge regression model 
#Report test error
##########################################
#We gotta split up the response from the predictors
dropped <- c("Apps")
college.train_update <- college.train[, !(names(college.train) %in% dropped)]
college.test_update <- college.test[, !(names(college.test) %in% dropped)]

#Converting "Private" to numerics
X_train <- college.train_update
X_train$Private <- ifelse(X_train$Private == 'Yes', 1, 0)
Y_train <- college.train[, "Apps"]

X_test <- college.test_update
X_test$Private <- ifelse(X_test$Private == 'Yes', 1, 0)
Y_test <- college.test[, "Apps"]

#Fit to ridge regression
?cv.glmnet
ridge.mod = cv.glmnet(as.matrix(X_train), Y_train, alpha = 0)
ridge.mod$lambda.min #best lamdba - the smallest

#Test
pred_ridge = predict(ridge.mod, newx = as.matrix(X_test), s = ridge.mod$lambda.min)
mean((Y_test - pred_ridge)^2)


##########################################
#(d.) LASSO model
#Report test error and non-zero coefficients
##########################################
lasso.mod = cv.glmnet(as.matrix(X_train), Y_train, alpha = 1)
pred_lasso = predict(lasso.mod, newx = as.matrix(X_test), s = lasso.mod$lambda.min)
mean((Y_test - pred_lasso)^2) #2646616

predict(lasso.mod, newx = as.matrix(X_test), s = lasso.mod$lambda.min, type="coefficients") #seems to be 16 plus the intercept

##########################################
#(e.) PCR
#Test error and value of k
##########################################
#Converting "Private" to numerics
college.train_pcr <- college.train
college.train_pcr$Private <- ifelse(college.train_pcr$Private == 'Yes', 1, 0)

college.test_pcr <- college.test
college.test_pcr$Private <- ifelse(college.test_pcr$Private == 'Yes', 1, 0)

#fit
pcr.fit <- pcr(Apps ~., data = college.train_pcr, scale = TRUE, validation="CV")
validationplot(pcr.fit, val.type = "MSEP") #Wanna get the minimum MSEP

#Evaluate performance of the model with "i" components in the PCA 
#regression for test and training.
?predict.mvr
training_error_store <- c()
test_error_store <- c()

for (i in 1:17) {
  pcr.pred.train = predict(pcr.fit, college.train_pcr, ncomp = i)
  pcr.pred.test = predict(pcr.fit, college.test_pcr, ncomp = i)
  train.error <- mean((college.train[, "Apps"] - pcr.pred.train)^2)
  test.error <- mean((college.test[, "Apps"] - pcr.pred.test)^2)
  
  #add the errors to the vectors
  training_error_store <- c(training_error_store, train.error)
  test_error_store <- c(test_error_store, test.error)
}

quartz()
plot(test_error_store) #looks like the k = 17 yields the smallest test error 2645751 (the OLS)


##########################################
#(f.) PLS
#Test error and value of k
##########################################
pls.fit = plsr(Apps ~., data=college.train_pcr, scale = TRUE, validation="CV")
validationplot(pls.fit, val.type = "MSEP")

pls.train_error_store <- c()
pls.test_error_store <- c()

for (i in 1:17) {
  pls.pred.train = predict(pls.fit, college.train_pcr, ncomp = i)
  pls.pred.test = predict(pls.fit, college.test_pcr, ncomp = i)
  pls.train.error <- mean((college.train[, "Apps"] - pls.pred.train)^2)
  pls.test.error <- mean((college.test[,"Apps"] - pls.pred.test)^2)
  
  #add the errors to the vectors
  pls.train_error_store <- c(pls.train_error_store, pls.train.error)
  pls.test_error_store <- c(pls.test_error_store, pls.test.error)
}

quartz()
plot(pls.test_error_store) #I think k = 13 could be good, test error: 2650641



##########################################
#(g.) Compare results
#How accurately can we predict number of apps
##########################################
#To compare the results obtained above, we can compute the tets R^2 for all models
test.avg <- mean(college.test$Apps)
lm.r2 <- 1 - mean((prediction - college.test$Apps)^2) / mean((test.avg - college.test$Apps)^2) #0.9008
ridge.r2 <- 1 - mean((pred_ridge - college.test$Apps)^2) / mean((test.avg - college.test$Apps)^2) #0.832
lasso.r2 <- 1 - mean((pred_lasso - college.test$Apps)^2) / mean((test.avg - college.test$Apps)^2) #0.9007
pcr.r2 <- 1 - mean((pcr.pred.test - college.test$Apps)^2) / mean((test.avg - college.test$Apps)^2) #0.9008
pls.r2 <- 1 - mean((pls.pred.test - college.test$Apps)^2) / mean((test.avg - college.test$Apps)^2) #0.9008
