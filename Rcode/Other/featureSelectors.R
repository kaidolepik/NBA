
simulatedAnnealingFeatureSelector = function(trainingData, testData, temp = 0.05, coolingRate = 0.0001) {
    features = data.frame(feature = 2:ncol(trainingData), isIn = runif(ncol(trainingData)-1) > 0.5)
    bestFeatures = features[features$isIn, 1]
    bestOverallFit = getFit(trainingData[, c(1, bestFeatures)], testData[, c(1, bestFeatures)])
    
    currentFit = bestOverallFit
    while (temp > 0) {
        feature = sample(1:nrow(features), 1)
        while (sum(features$isIn) <= 1 && features[feature, 2] == TRUE)
            feature = sample(1:nrow(features), 1)
        features[feature, 2] <- features[feature, 2] == FALSE
        
        fit = getFit(trainingData[, c(1, features[features$isIn, 1])],
                     testData[, c(1, features[features$isIn, 1])])
        if (fit > currentFit || isLucky(fit, currentFit, temp)) {
            currentFit = fit
            if (currentFit > bestOverallFit) {
                bestOverallFit = currentFit
                bestFeatures = features[features$isIn, 1]
                print (bestOverallFit)
                print (bestFeatures)
            }
        }
        else
            features[feature, 2] <- features[feature, 2] == FALSE
        temp = temp - coolingRate
    }
    names(bestFeatures) = names(trainingData)[bestFeatures]
    
    return (bestFeatures)
}


forwardGreedyFeatureSelector = function(trainingData, testData) {
    selectedFeatures = c()
    selectableFeatures = 2:ncol(trainingData)
    bestOverallFit = 0
    
    while (TRUE) {
        bestIterationFit = 0
        bestIterationFeature = 0
        for (feature in selectableFeatures) {
            fit = getFit(trainingData[, c(1, selectedFeatures, feature)],
                         testData[, c(1, selectedFeatures, feature)])
            if (fit > bestIterationFit) {
                bestIterationFit = fit
                bestIterationFeature = feature
            }
        }
        if (bestIterationFit > bestOverallFit) {
            bestOverallFit = bestIterationFit
            selectedFeatures = c(selectedFeatures, bestIterationFeature)
            selectableFeatures = selectableFeatures[-which(selectableFeatures == bestIterationFeature)]
        }
        else
            break
    }
    names(selectedFeatures) = names(trainingData)[selectedFeatures]
    
    return (selectedFeatures)
}


backwardGreedyFeatureSelector = function(trainingData, testData) {
    selectedFeatures = 2:ncol(trainingData)
    bestOverallFit = 0
    
    while (TRUE) {
        bestIterationFit = 0
        worstIterationFeature = 0
        for (feature in 1:length(selectedFeatures)) {
            fit = getFit(trainingData[, c(1, selectedFeatures[-feature])], 
                         testData[, c(1, selectedFeatures[-feature])])
            if (fit > bestIterationFit) {
                bestIterationFit = fit
                worstIterationFeature = selectedFeatures[feature]
            }
        }
        if (bestIterationFit > bestOverallFit) {
            bestOverallFit = bestIterationFit
            selectedFeatures = selectedFeatures[-feature]
        }
        else
            break
    }
    names(selectedFeatures) = names(trainingData)[selectedFeatures]
    
    return (selectedFeatures)
}


### Privaatsena mõeldud abimeetodid

getFit = function(trainingData, testData) {
    model = glm(Class ~ ., data = trainingData, family = binomial)
    predictProbs = predict(model, newdata = testData, type = "response")
    predictClasses = 1*(predictProbs >= 0.5)
    fit = sum(predictClasses == testData$Class) / nrow(testData)
    
    return (fit)
}

getFit2 = function(trainingData, testData) {
    four = rpart.control(cp = -1 , maxdepth = 2, minsplit = 0)
    model = ada(Class ~ ., data = trainingData, control = four)
    predictProbs = predict(model, newdata = testData, type = "probs")[,2]
    predictClasses = 1*(predictProbs >= 0.5)
    fit = sum(predictClasses == testData$Class) / nrow(testData)
    
    return (fit)
}

isLucky = function(newFit, oldFit, temp) {
    return (runif(1) < exp((newFit - oldFit) / temp))
}
