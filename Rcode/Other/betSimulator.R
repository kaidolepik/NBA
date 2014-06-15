
betEvaluator = function(match, homeWinProb, awayWinProb, valueThreshold, betSize) {
    values = unlist(c(homeWinProb * match["HomeOdds"], 
                      awayWinProb * match["AwayOdds"]))
    names(values) = c("homeValue", "awayValue")
    
    betData = c(profit = 0, predictedClass = -1)
    
    if (sum(values > 1 + valueThreshold)) {
        bettingChoice = which.max(values)
        if (match["Class"] == bettingChoice || match["Class"] == 0 && bettingChoice == 2)
            betData[1] =  match[c("HomeOdds", "AwayOdds")][bettingChoice] - 1
        else
            betData[1] = -betSize
        betData[2] = 2 - bettingChoice
    }
    
    return (betData)
}

bettor = function(match, valueThreshold, betSize) {
    homeWinProb = match["predictProbs"]
    if (homeWinProb == -1)
        return (c(profit = 0, predictedClass = -1))
    else {
        awayWinProb = 1 - homeWinProb
        return (betEvaluator(match, homeWinProb, awayWinProb, valueThreshold, betSize))
    }
}

reproduceCashflow = function(testset, predictProbs, valueThreshold = 0, betSize = 1) {
    testset$predictProbs = predictProbs
    cumsum(apply(testset, 1, bettor, valueThreshold = valueThreshold, betSize = betSize)[1,])
}

getAccuracy = function(classes, predictProbs) {
    predictClasses = 1*(predictProbs >= 0.5)
    fit = sum(predictClasses == classes) / length(classes)
    
    fit
}

getAccuracyByYear = function(classes, predictProbs, matchIDs) {
    years = substr(matchIDs, 2, 3)
    accuracies = c()
    
    for (year in unique(years))
        accuracies = rbind(accuracies, c(getAccuracy(classes[years == year], predictProbs[years == year]), 
                                         sum(years == year), year))
    
    return (accuracies)
}

getBookieAccuracy = function(testsetOdds) {
    bookiePredictions = 1*(testsetOdds$HomeOdds < testsetOdds$AwayOdds)
    accuracy = getAccuracy(testsetOdds$Class, bookiePredictions)
    
    accuracy
}

getBookieAccuracyByYear = function(testsetOdds) {
    bookiePredictions = 1*(testsetOdds$HomeOdds < testsetOdds$AwayOdds)
    accuracies = getAccuracyByYear(testsetOdds$Class, bookiePredictions, testsetOdds$MatchID)
    
    accuracies
}
