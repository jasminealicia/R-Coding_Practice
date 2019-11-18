# Jasmine Clark
#ADS 635 Data Mining I Homework 2
# (3.)
# Source: StackOverFlow for ideas of solving this problem

#clear workspace
rm(list = ls())

#set the directory we are working in
setwd("/Users/jasmineclark/Documents/Bay Path MSADS/ADS 635/Homework/Homework 2")

#We've seen that as the number of features used in a model increases, the training error will decrease, but
#the test error may not.

#Generate random x, beta
set.seed(1)
X <- matrix(rnorm(1000 * 20), 1000, 20)
b <- rnorm(20)
b[1:5] = 0
eps <- rnorm(1000)
Y <- X %*% b + eps

#Splitting 900 to training and 100 to test
sampling = sample(seq(1000), 900, replace = FALSE)
X.train <- X[sampling,]
X.test <- X[-sampling,]
Y.train <- Y[sampling]
Y.test <- Y[-sampling]


##########################################
#Exhaustive (Best) Subset Selection
##########################################
#Training data
data.train <- data.frame(y = Y.train, x = X.train)
regfit.full = regsubsets(y ~ ., data = data.train, nvmax = 20)
train.matrix <- model.matrix(y ~ ., data = data.train, nvmax = 20)
train.errors <- rep(NA, 20)

for (i in 1:20) {
  coeff <- coef(regfit.full, id = i)
  prediction <- train.matrix[, names(coeff)] %*% coeff
  train.errors[i] <- mean((prediction - Y.train)^2)
}

quartz()
plot(train.errors, xlab = "Number of predictors", ylab = "Training MSE", pch = 19, type = "b")

#Test data
data.test <- data.frame(y = Y.test, x = X.test)
regfit.full = regsubsets(y ~ ., data = data.test, nvmax = 20)
test.matrix <- model.matrix(y ~ ., data = data.test, nvmax = 20)
test.errors <- rep(NA, 20)

for (i in 1:20) {
  coeff <- coef(regfit.full, id = i)
  prediction <- test.matrix[, names(coeff)] %*% coeff
  test.errors[i] <- mean((prediction - Y.test)^2)
}

quartz()
plot(test.errors, xlab = "Number of predictors", ylab = "Test MSE", pch = 19, type = "b")

#Which model size yields the smallest MSE?
which.min(train.errors) #looks like 20 yields the smallest MSE (the OLS)
which.min(test.errors)

#Comment on coefficient values
coef(regfit.full, which.min(test.errors))







