## Some code/skeletons used from Sven Laur's Machine Learning course

rm(list=ls())
setwd("Analysis")
source("Rcode/Other/datasetBuilder.R")
source("Rcode/Other/betSimulator.R")

findThresholds = function(attribute) {
    uniques = unique(attribute)
    thresholds <- seq(min(uniques), rev(sort(uniques))[ifelse(length(uniques) > 2, 2, 1)], 
                      length.out = min(100, length(uniques)))
    thresholds[1] = round(thresholds[1], 4) + 1e-04
    thresholds[length(thresholds)] = round(thresholds[length(thresholds)], 4) - 1e-04
    
    return (thresholds)
}

ComputeProfit <- function(targets, predictionClass) {
    profit = targets$weights * ((targets$HomeOdds-1)*(targets$Class == 1 & predictionClass == 1) +
                                    (targets$AwayOdds-1)*(targets$Class == 0 & predictionClass == 0) + 
                                    (-1)*(targets$Class != predictionClass))
    return (sum(profit))
}

ComputeProfitGain_minError <- function(attribute, threshold, targets) {
    partitionIndex <- (attribute <= threshold)
    
    targets1 <- targets[partitionIndex == TRUE, ]
    targets2 <- targets[partitionIndex == FALSE, ]
    
    w = targets$weights
    y = targets$Class
    side1 = partitionIndex
    side2 = (!partitionIndex)
    split.error1 = sum(w[side1]*(y[side1] != 1)) + sum(w[side2]*(y[side2] != 0))
    split.error2 = sum(w[side1]*(y[side1] != 0)) + sum(w[side2]*(y[side2] != 1))
    gain = 1.1 - min(split.error1, split.error2)
    
    return (list(threshold = threshold, gain = gain, side1 = 1*(split.error1 < split.error2)))
}

ComputeProfitGain_maxProfit <- function(attribute, threshold, targets) {
    partitionIndex <- (attribute <= threshold)
    
    targets1 <- targets[partitionIndex == TRUE, ]
    targets2 <- targets[partitionIndex == FALSE, ]
    
    profit = max(c(ComputeProfit(targets, 1), ComputeProfit(targets, 0)))
    profit1 = ComputeProfit(targets1, 1) + ComputeProfit(targets2, 0)
    profit2 = ComputeProfit(targets1, 0) + ComputeProfit(targets2, 1)
    gain <- max(c(profit1, profit2)) - profit
    
    return(list(threshold = threshold, gain = gain))
}

ComputeBestProfitGain <- function(attribute, targets) {
    thresholds = findThresholds(attribute)
    
    bestResult <- list(threshold = "threshold", gain = -1e+06, side1 = -1)
    for (threshold in thresholds) {
        thresholdResult = ComputeProfitGain(attribute, threshold, targets)
        if (thresholdResult[["gain"]] > bestResult[["gain"]])
            bestResult = thresholdResult
    }
    
    return(bestResult)
}

findBestAttribute = function(attributes, targets) {
    bestAttribute = list(attribute = 0, profitGain = list(threshold = "threshold", gain = -1e+06, side1 = -1))
    
    for(i in 1:ncol(attributes)) {
        if (length(unique(attributes[,i])) <= 1)
            next
        profitGain <- ComputeBestProfitGain(attributes[,i], targets)    
        if (profitGain$gain > bestAttribute$profitGain$gain) {
            bestAttribute$attribute = i
            bestAttribute$profitGain = profitGain
        }
    }
    
    return (bestAttribute)
}

# A function for printing indented text lines
TreeNodeLine <- function(text, level) {
    cat(rep("\t", level))
    cat(text)
    cat("\n")
}

ModifiedRecursiveID3_maxProfit <- function(training, test, max.level, rec.level = 0) {
    attributes = as.data.frame(training$attributes)
    if (rec.level >= max.level || nrow(as.matrix(unique(attributes))) <= 1) {
        trainingProfits = c(ComputeProfit(training$targets, 1), ComputeProfit(training$targets, 0))
        decision = c("home", "away")[which.max(trainingProfits)]
        
        if (max(trainingProfits) <= 0)
            testPredictions[test$positions] <<- -1
        else
            testPredictions[test$positions] <<- 1*(decision == "home")
        trainingPredictions[training$positions] <<- 1*(decision == "home")
        
        testProfit = ComputeProfit(test$targets, 1*(decision == "home"))
        TreeNodeLine(paste("Decision:", decision, ", profit:", round(testProfit, 2)), rec.level)
    }
    else {
        # Find the best attribute for splitting
        bestAttribute = findBestAttribute(attributes, training$targets)
        
        splitColumn = bestAttribute$attribute
        splitThreshold = bestAttribute$profitGain$threshold
        
        trainingRows = (training$attributes[,splitColumn] <= splitThreshold)
        
        if (nrow(test$attributes) != 0) {
            testRows = (test$attributes[,splitColumn] <= splitThreshold)
            leftTest = list(attributes = matrix(test$attributes[testRows,], nrow = sum(testRows)), 
                            targets = test$targets[testRows,], positions = test$positions[testRows])
            rightTest = list(attributes = matrix(test$attributes[!testRows,], nrow = sum(!testRows)), 
                             targets = test$targets[!testRows,], positions = test$positions[!testRows])
        }
        else {
            leftTest = list(attributes = matrix(nrow = 0, ncol = 0), 
                            targets = test$targets, positions = test$positions)
            rightTest = list(attributes = matrix(nrow = 0, ncol = 0), 
                             targets = test$targets, positions = test$positions)
        }
        
        TreeNodeLine(paste(c(colnames(attributes)[splitColumn], "<=", round(splitThreshold, 2))), rec.level)
        ModifiedRecursiveID3_maxProfit(list(attributes = matrix(training$attributes[trainingRows,], nrow = sum(trainingRows)), 
                                  targets = training$targets[trainingRows,], positions = training$positions[trainingRows]),
                             leftTest, max.level, rec.level = rec.level + 1)   
        
        TreeNodeLine(paste(c(colnames(attributes)[splitColumn], ">", round(splitThreshold, 2))), rec.level)
        ModifiedRecursiveID3_maxProfit(list(attributes = matrix(training$attributes[!trainingRows,], nrow = sum(!trainingRows)), 
                                  targets = training$targets[!trainingRows,], positions = training$positions[!trainingRows]),
                             rightTest, max.level, rec.level = rec.level + 1)    
    }
}

ModifiedRecursiveID3_minError <- function(training, test, max.level, rec.level = 0) {
    attributes = as.data.frame(training$attributes)
    if (rec.level >= max.level || nrow(as.matrix(unique(attributes))) <= 1) {
        trainingProfits = c(ComputeProfit(training$targets, 1), ComputeProfit(training$targets, 0))
        decision = c("home", "away")[which.max(trainingProfits)]
        
        testProfit = ComputeProfit(test$targets, 1*(decision == "home"))
        TreeNodeLine(paste("Decision:", decision, ", profit:", round(testProfit, 2)), rec.level)
    }
    else {
        # Find the best attribute for splitting
        bestAttribute = findBestAttribute(attributes, training$targets)
        
        splitColumn = bestAttribute$attribute
        splitThreshold = bestAttribute$profitGain$threshold
        
        trainingRows = (training$attributes[,splitColumn] <= splitThreshold)
        trainingPredictions[training$positions[trainingRows]] <<- bestAttribute$profitGain$side1
        trainingPredictions[training$positions[!trainingRows]] <<- ifelse(bestAttribute$profitGain$side1 == 1, 0, 1)
        
        if (nrow(test$attributes) != 0) {
            testRows = (test$attributes[,splitColumn] <= splitThreshold)
            leftTest = list(attributes = matrix(test$attributes[testRows,], nrow = sum(testRows)), 
                            targets = test$targets[testRows,], positions = test$positions[testRows])
            rightTest = list(attributes = matrix(test$attributes[!testRows,], nrow = sum(!testRows)), 
                             targets = test$targets[!testRows,], positions = test$positions[!testRows])
            
            testPredictions[test$positions[testRows]] <<- bestAttribute$profitGain$side1
            testPredictions[test$positions[!testRows]] <<- ifelse(bestAttribute$profitGain$side1 == 1, 0, 1)
        }
        else {
            leftTest = list(attributes = matrix(nrow = 0, ncol = 0), 
                            targets = test$targets, positions = test$positions)
            rightTest = list(attributes = matrix(nrow = 0, ncol = 0), 
                             targets = test$targets, positions = test$positions)
        }
        
        TreeNodeLine(paste(c(colnames(attributes)[splitColumn], "<=", round(splitThreshold, 2))), rec.level)
        ModifiedRecursiveID3_minError(list(attributes = matrix(training$attributes[trainingRows,], nrow = sum(trainingRows)), 
                                  targets = training$targets[trainingRows,], positions = training$positions[trainingRows]),
                             leftTest, max.level, rec.level = rec.level + 1)   
        
        TreeNodeLine(paste(c(colnames(attributes)[splitColumn], ">", round(splitThreshold, 2))), rec.level)
        ModifiedRecursiveID3_minError(list(attributes = matrix(training$attributes[!trainingRows,], nrow = sum(!trainingRows)), 
                                  targets = training$targets[!trainingRows,], positions = training$positions[!trainingRows]),
                             rightTest, max.level, rec.level = rec.level + 1)    
    }
}

adaboost = function(trainingList, testList, iter, lambda = 0, levels = 1) {
    alphas = rep(NA, iter)
    weak.testPredictions = matrix(NA, nrow = nrow(testList$targets), ncol = iter)
    weak.trainingPredictions = matrix(NA, nrow = nrow(trainingList$targets), ncol = iter)
    trainingList$targets$weights = rep(1/nrow(trainingList$targets), nrow(trainingList$targets))
    trainingList$targets$weights = exp(lambda * ifelse(trainingList$targets$Class == 1,
                                                       trainingList$targets$HomeOdds-1, trainingList$targets$AwayOdds-1))
    trainingList$targets$weights = trainingList$targets$weights / sum(trainingList$targets$weights)
    
    for (i in 1:iter) {
        w = trainingList$targets$weights
        y = trainingList$targets$Class
        ModifiedRecursiveID3_minError(trainingList, testList, levels) # weak.classifier
        
        err = sum(w * (trainingPredictions != y))
        alpha = log((1-err) / err)
        w = w * exp(alpha * (trainingPredictions != y))
        w = w / sum(w)
        
        trainingList$targets$weights = w
        weak.testPredictions[,i] = testPredictions
        weak.trainingPredictions[,i] = trainingPredictions
        alphas[i] = alpha
    }
    
    weak.testPredictions = 2*weak.testPredictions - 1
    weak.trainingPredictions = 2*weak.trainingPredictions - 1
    list(alphas = alphas, weak.testPredictions = weak.testPredictions, 
         weak.trainingPredictions = weak.trainingPredictions)
}

data = getDataset("datasets/data_joiner_30.Rdata", minCount = 10)
features = 2:31
trainingNr = 1:4000
testNr = 4001:5319

minError_results = matrix(NA, nrow = 30, ncol = 4)
maxProfit_results = matrix(NA, nrow = 30, ncol = 4)
colnames(minError_results) = c("testProft", "testAccuracy", "trainingProfit", "trainingAccuracy")
colnames(maxProfit_results) = c("testProft", "testAccuracy", "trainingProfit", "trainingAccuracy")

for (i in 1:length(features)) {
    feats = features[i]
    trainingList = list(attributes = as.matrix(data$testData[trainingNr, feats]), 
                        targets = cbind(data$testsetOdds[trainingNr, 2:4], 
                                        weights = rep(1/length(trainingNr), length(trainingNr))), 
                        positions = 1:nrow(data$testData[trainingNr,]))
    testList = list(attributes = as.matrix(data$testData[testNr, feats]), 
                    targets = cbind(data$testsetOdds[testNr, 2:4],
                                    weights = rep(1/length(testNr), length(testNr))),
                    positions = 1:nrow(data$testData[testNr,]))
    
    trainingPredictions <<- rep(NA, length(trainingNr))
    testPredictions <<- rep(NA, length(testNr))
    
    ComputeProfitGain = ComputeProfitGain_minError
    ModifiedRecursiveID3_minError(trainingList, testList, 2)
    
    minError_results[i, 1] = rev(reproduceCashflow(testList$targets, testPredictions))[1] # testProfit
    minError_results[i, 2] = getAccuracy(testList$targets$Class, testPredictions) # testAccuracy
    
    minError_results[i, 3]= rev(reproduceCashflow(trainingList$targets, trainingPredictions))[1] # trainingProfit
    minError_results[i, 4] = getAccuracy(trainingList$targets$Class, trainingPredictions) # trainingAccuracy
    
    trainingPredictions <<- rep(NA, length(trainingNr))
    testPredictions <<- rep(NA, length(testNr))
    
    ComputeProfitGain = ComputeProfitGain_maxProfit
    ModifiedRecursiveID3_maxProfit(trainingList, testList, 2)
    
    maxProfit_results[i, 1] = rev(reproduceCashflow(testList$targets, testPredictions))[1] # testProfit
    maxProfit_results[i, 2] = getAccuracy(testList$targets$Class, testPredictions) # testAccuracy
    
    maxProfit_results[i, 3]= rev(reproduceCashflow(trainingList$targets, trainingPredictions))[1] # trainingProfit
    maxProfit_results[i, 4] = getAccuracy(trainingList$targets$Class, trainingPredictions) # trainingAccuracy
}

minError_results[1:6,]
maxProfit_results[1:6,]

pdf("pics/testProfits.pdf")
testProfits = t(cbind(minError_results[,1], maxProfit_results[,1]))
b1 = barplot(testProfits, beside = TRUE, legend = c("Min viga", "Max kasum"),
        xlab = "Erinevad tunnused (kokku 30)", ylab = "Kasum testandmetel (pärast 1319 mängu)",
        args.legend = list(cex = 0.65))
dev.off()
pdf("pics/trainingProfits.pdf")
trainingProfits = t(cbind(minError_results[,3], maxProfit_results[,3]))
b2 = barplot(trainingProfits, beside = TRUE, legend = c("Min viga", "Max kasum"),
        xlab = "Erinevad tunnused (kokku 30)", ylab = "Kasum treeningandmetel (pärast 4000 mängu)",
        args.legend = list(cex = 0.65))
dev.off()
pdf("pics/testAccuracies.pdf")
testAccuracies = t(cbind(minError_results[,2], maxProfit_results[,2]))
b1 = barplot(testAccuracies, beside = TRUE, legend = c("Treeningvea minimiseerimine", "Treeningkasumi maksimiseerimine"),
             xlab = "Erinevad tunnused (kokku 30)", ylab = "Täpsus testandmetel (1319 mängu jooksul)",
             ylim = c(0, 1))
dev.off()
pdf("pics/trainingAccuracies.pdf")
trainingAccuracies = t(cbind(minError_results[,4], maxProfit_results[,4]))
b2 = barplot(trainingAccuracies, beside = TRUE, legend = c("Treeningvea minimiseerimine", "Treeningkasumi maksimiseerimine"),
             xlab = "Erinevad tunnused (kokku 30)", ylab = "Täpsus treeningandmetel (4000 mängu jooksul)",
             ylim = c(0, 1))
dev.off()



feats = features
trainingList = list(attributes = as.matrix(data$testData[trainingNr, feats]), 
                    targets = cbind(data$testsetOdds[trainingNr, 2:4], 
                                    weights = rep(1/length(trainingNr), length(trainingNr))), 
                    positions = 1:nrow(data$testData[trainingNr,]))
testList = list(attributes = as.matrix(data$testData[testNr, feats]), 
                targets = cbind(data$testsetOdds[testNr, 2:4],
                                weights = rep(1/length(testNr), length(testNr))),
                positions = 1:nrow(data$testData[testNr,]))

trainingPredictions <<- rep(NA, length(trainingNr))
testPredictions <<- rep(NA, length(testNr))

ComputeProfitGain = ComputeProfitGain_minError
ModifiedRecursiveID3_minError(trainingList, testList, 2)

minError_testProfit = rev(reproduceCashflow(testList$targets, testPredictions))[1]
minError_testAccuracy = getAccuracy(testList$targets$Class, testPredictions)
minError_trainingProfit = rev(reproduceCashflow(trainingList$targets, trainingPredictions))[1]
minError_trainingAccuracy = getAccuracy(trainingList$targets$Class, trainingPredictions)

trainingPredictions <<- rep(NA, length(trainingNr))
testPredictions <<- rep(NA, length(testNr))

ComputeProfitGain = ComputeProfitGain_maxProfit
ModifiedRecursiveID3_maxProfit(trainingList, testList, 2)

maxProfit_testProfit = rev(reproduceCashflow(testList$targets, testPredictions))[1]
maxProfit_testAccuracy = getAccuracy(testList$targets$Class, testPredictions)
maxProfit_trainingProfit = rev(reproduceCashflow(trainingList$targets, trainingPredictions))[1]
maxProfit_trainingAccuracy = getAccuracy(trainingList$targets$Class, trainingPredictions)


### Adaboost

ComputeProfitGain = ComputeProfitGain_minError
data = getDataset("datasets/data_joiner_30.Rdata", minCount = 10)

trainingNr = 1:4000
testNr = 4001:5319
feats = c(2, 17, 26, 16, 15)

trainingList = list(attributes = as.matrix(data$testData[trainingNr, feats]), 
                    targets = cbind(data$testsetOdds[trainingNr, 2:4], 
                                    weights = rep(1/length(trainingNr), length(trainingNr))), 
                    positions = 1:nrow(data$testData[trainingNr,]))
testList = list(attributes = as.matrix(data$testData[testNr, feats]), 
                targets = cbind(data$testsetOdds[testNr, 2:4],
                                weights = rep(1/length(testNr), length(testNr))),
                positions = 1:nrow(data$testData[testNr,]))

trainingPredictions <<- rep(NA, length(trainingNr))
testPredictions <<- rep(NA, length(testNr))

ModifiedRecursiveID3_minError(trainingList, testList, 1)

testCashflow = reproduceCashflow(testList$targets, testPredictions)
testAccuracy = getAccuracy(testList$targets$Class, testPredictions)

trainingCashflow = reproduceCashflow(trainingList$targets, trainingPredictions)
trainingAccuracy = getAccuracy(trainingList$targets$Class, trainingPredictions)

plot(testCashflow, type = "l")
plot(trainingCashflow, type = "l")



ada = adaboost(trainingList, testList, iter = 10, lambda = 0, levels = 2)
testPreds = (sign(apply(ada$weak.testPredictions, 1, function(x) sum(ada$alphas*x))) + 1) / 2
trainingPreds = (sign(apply(ada$weak.trainingPredictions, 1, function(x) sum(ada$alphas*x))) + 1) / 2
testAccuracy = getAccuracy(testList$targets$Class, testPreds)
trainingAccuracy = getAccuracy(trainingList$targets$Class, trainingPreds)
testCashflow = reproduceCashflow(testList$targets, testPredictions)
trainingCashflow = reproduceCashflow(trainingList$targets, trainingPredictions)
plot(testCashflow, type = "l", ylim = c(-150, 50), xlab = "Mäng", ylab = "Konto jääk (ühik)",
     main = "Kumulatiivne kontojääk modifitseeritud AdaBoosti korral", col = "black")
#plot(trainingCashflow, type = "l")

cols = c("blue", "red", "green", "pink", "orange", "purple")
lambda_values = -c(1, 2, 5, 10, 20, 30)
for (i in 1:length(lambda_values)) {
    lambda = lambda_values[i]
    ada = adaboost(trainingList, testList, 10, lambda = lambda, levels = 2)
    testPreds = (sign(apply(ada$weak.testPredictions, 1, function(x) sum(ada$alphas*x))) + 1) / 2
    trainingPreds = (sign(apply(ada$weak.trainingPredictions, 1, function(x) sum(ada$alphas*x))) + 1) / 2
    testAccuracy = getAccuracy(testList$targets$Class, testPreds)
    trainingAccuracy = getAccuracy(trainingList$targets$Class, trainingPreds)
    testCashflow = reproduceCashflow(testList$targets, testPredictions)
    trainingCashflow = reproduceCashflow(trainingList$targets, trainingPredictions)
    lines(testCashflow, type = "l", col = cols[i]) # ifelse(lambda < 0, "red", "blue")
    #plot(trainingCashflow, type = "l")
}
legend("bottomleft", lty = rep(1, 7), col = c("black", cols), paste("lambda =", c(0, lambda_values)))
abline(h = 0, lty = "dashed")

trainingList$attributes = as.data.frame(cbind(trainingList$attributes, Class = trainingList$targets$Class))
testList$attributes = as.data.frame(cbind(testList$attributes, testList$targets$Class))


## Trying weighting in logistic regression
## Weights can be defined differently

g = glm(Class ~ ., weights = 1/(trainingList$targets$AwayOdds),
        data = trainingList$attributes, family = binomial)
predictProbsLog = predict(g, newdata = testList$attributes, type = "response")
cashflowLog = reproduceCashflow(testList$targets, predictProbsLog, valueThreshold = 0, betSize = 1)
plot(cashflowLog, type = "l")
testAccuracy = getAccuracy(testList$targets$Class, predictProbsLog)


## Decision tree, minimizing training error

ComputeProfitGain = ComputeProfitGain_minError
feats = c(2)

trainingList = list(attributes = as.matrix(data$testData[trainingNr, feats]), 
                    targets = cbind(data$testsetOdds[trainingNr, 2:4], 
                                    weights = rep(1/length(trainingNr), length(trainingNr))), 
                    positions = 1:nrow(data$testData[trainingNr,]))
testList = list(attributes = as.matrix(data$testData[testNr, feats]), 
                targets = cbind(data$testsetOdds[testNr, 2:4],
                                weights = rep(1/length(testNr), length(testNr))),
                positions = 1:nrow(data$testData[testNr,]))

trainingPredictions <<- rep(NA, length(trainingNr))
testPredictions <<- rep(NA, length(testNr))

ModifiedRecursiveID3_minError(trainingList, testList, 5)

testCashflow = reproduceCashflow(testList$targets, testPredictions)
testAccuracy = getAccuracy(testList$targets$Class, testPredictions)

trainingCashflow = reproduceCashflow(trainingList$targets, trainingPredictions)
trainingAccuracy = getAccuracy(trainingList$targets$Class, trainingPredictions)

#plot(testCashflow, type = "l", col = "blue", ylim = c(-80, 80), xlab = "Mäng", ylab = "Konto jääk (ühik)",
#     main = "Kumulatiivne kontojääk ühe tunnuse abil klassifitseerides")
plot(trainingCashflow, type = "l", col = "red", ylim = c(-180, 400), xlab = "Mäng", ylab = "Konto jääk (ühik)",
     main = "Kumulatiivne kontojääk ühe tunnuse abil klassifitseerides")

for (feature in 3:31) {
    feats = c(feature)
    
    trainingList = list(attributes = as.matrix(data$testData[trainingNr, feats]), 
                        targets = cbind(data$testsetOdds[trainingNr, 2:4], 
                                        weights = rep(1/length(trainingNr), length(trainingNr))), 
                        positions = 1:nrow(data$testData[trainingNr,]))
    testList = list(attributes = as.matrix(data$testData[testNr, feats]), 
                    targets = cbind(data$testsetOdds[testNr, 2:4],
                                    weights = rep(1/length(testNr), length(testNr))),
                    positions = 1:nrow(data$testData[testNr,]))
    
    trainingPredictions <<- rep(NA, length(trainingNr))
    testPredictions <<- rep(NA, length(testNr))
    
    ModifiedRecursiveID3_minError(trainingList, testList, 5)
    
    testCashflow = reproduceCashflow(testList$targets, testPredictions)
    testAccuracy = getAccuracy(testList$targets$Class, testPredictions)
    
    trainingCashflow = reproduceCashflow(trainingList$targets, trainingPredictions)
    trainingAccuracy = getAccuracy(trainingList$targets$Class, trainingPredictions)
    
    #lines(testCashflow, type = "l", col = "lightblue")
    lines(trainingCashflow, type = "l", col = "pink")
}
legend("topleft", lty = rep(1, 2), col = c("blue", "lightblue"), c("A_DIFF", "ülejäänud tunnused"))
abline(h = 0, lty = "dashed")



## Decision tree, maximizing profit

ComputeProfitGain = ComputeProfitGain_maxProfit
data = getDataset("datasets/data_joiner_30.Rdata", minCount = 10)

trainingNr = 1:4000
testNr = 4001:5319
feats = c(2:31)

trainingList = list(attributes = as.matrix(data$testData[trainingNr, feats]), 
                    targets = cbind(data$testsetOdds[trainingNr, 2:4], 
                                    weights = rep(1, length(trainingNr))), 
                    positions = 1:nrow(data$testData[trainingNr,]))
testList = list(attributes = as.matrix(data$testData[testNr, feats]), 
                targets = cbind(data$testsetOdds[testNr, 2:4],
                                weights = rep(1, length(testNr))), 
                positions = 1:nrow(data$testData[testNr,]))

trainingPredictions <<- rep(NA, length(trainingNr))
testPredictions <<- rep(NA, length(testNr))

ModifiedRecursiveID3_maxProfit(trainingList, testList, 5)

testCashflow = reproduceCashflow(testList$targets, testPredictions)
testAccuracy = getAccuracy(testList$targets$Class, testPredictions)

trainingCashflow = reproduceCashflow(trainingList$targets, trainingPredictions)
trainingAccuracy = getAccuracy(trainingList$targets$Class, trainingPredictions)

plot(testCashflow, type = "l", col = "blue", ylim = c(-80, 80), xlab = "Mäng", ylab = "Konto jääk (ühik)",
     main = "Kumulatiivne kontojääk kõikide tunnuste abil klassifitseerides")
#plot(trainingCashflow, type = "l", col = "red", ylim = c(-80, 400), xlab = "Mäng", ylab = "Konto jääk (ühik)",
#     main = "Kumulatiivne kontojääk kõikide tunnuste abil klassifitseerides")

for (feature in 3:31) {
    feats = c(feature)
    
    trainingList = list(attributes = as.matrix(data$testData[trainingNr, feats]), 
                        targets = cbind(data$testsetOdds[trainingNr, 2:4], 
                                        weights = rep(1, length(trainingNr))), 
                        positions = 1:nrow(data$testData[trainingNr,]))
    testList = list(attributes = as.matrix(data$testData[testNr, feats]), 
                    targets = cbind(data$testsetOdds[testNr, 2:4],
                                    weights = rep(1, length(testNr))), 
                    positions = 1:nrow(data$testData[testNr,]))
    
    trainingPredictions <<- rep(NA, length(trainingNr))
    testPredictions <<- rep(NA, length(testNr))
    
    ModifiedRecursiveID3_maxProfit(trainingList, testList, 2)
    
    testCashflow = reproduceCashflow(testList$targets, testPredictions)
    testAccuracy = getAccuracy(testList$targets$Class, testPredictions)
    
    trainingCashflow = reproduceCashflow(trainingList$targets, trainingPredictions)
    trainingAccuracy = getAccuracy(trainingList$targets$Class, trainingPredictions)
    
    lines(testCashflow, type = "l", col = "lightblue")
    #lines(trainingCashflow, type = "l", col = "pink")
}
legend("topleft", lty = rep(1, 2), col = c("blue", "lightblue"), c("A_DIFF", "ülejäänud tunnused"))
abline(h = 0, lty = "dashed")
