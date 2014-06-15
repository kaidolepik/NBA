rm(list=ls())
setwd("Analysis")
source("Rcode/SQL/DatabaseHandler.R")
source("Rcode/SQL/MLmethodsQueries.R")
source("Rcode/SQL/BaseQueries.R")

dataJoiner = function(match, lastMatches) {
    homeData = sqlData(db, match$HomeTeamID, match$Date, lastMatches)
    awayData = sqlData(db, match$AwayTeamID, match$Date, lastMatches)
    names(homeData) = paste0("A_", names(homeData))
    names(awayData) = paste0("B_", names(awayData))
    
    return (cbind(Class = match$Class, MatchID = match$ID, homeData, awayData))
}

dataJoinerSide = function(match, lastMatches) {
    homeData = sqlSideData(db, match$HomeTeamID, match$Date, lastMatches, "HomeTeamID")
    awayData = sqlSideData(db, match$AwayTeamID, match$Date, lastMatches, "AwayTeamID")
    names(homeData) = paste0("A_", names(homeData))
    names(awayData) = paste0("B_", names(awayData))
    
    return (cbind(Class = match$Class, MatchID = match$ID, homeData, awayData))
}

buildData = function(matchData, lastMatches, dataJoinerFunction, filename) {
    print (Sys.time())
    data = data.frame()
    
    for (i in 1:nrow(matchData)) {
        data = rbind(data, dataJoinerFunction(matchData[i,], lastMatches))
        if (i %% 1000 == 0) {
            print (i)
            print (Sys.time())
        }
    }
    
    data[,] <- as.numeric(as.matrix(data[,]))
    save(data, file = filename)
    print (Sys.time())
}

buildSets = function() {
    db = getDatabase()
    matchData = sqlMatchesData(db)
    
    buildData(matchData, 5, dataJoinerSide, "data_joinerSide_5.Rdata")
    buildData(matchData, 10, dataJoiner, "data_joiner_10.Rdata")
    buildData(matchData, 10, dataJoinerSide, "data_joinerSide_10.Rdata")
    buildData(matchData, 20, dataJoiner, "data_joiner_20.Rdata")
    buildData(matchData, 15, dataJoinerSide, "data_joinerSide_15.Rdata")
    buildData(matchData, 30, dataJoiner, "data_joiner_30.Rdata")
    
    closeDatabase(db)
}

getDataset = function(filename, minCount) {
    db = getDatabase()
    testsetOdds = getBaseTestSetQuery(db)
    
    load(filename)
    data = subset(data, A_Count >= minCount & B_Count >= minCount)
    trainingData = data[!(data$MatchID %in% testsetOdds$MatchID), which(!names(data) %in% c("MatchID", "A_Count", "B_Count"))]
    testData = data[(data$MatchID %in% testsetOdds$MatchID),  which(!names(data) %in% c("MatchID", "A_Count", "B_Count"))]
    testsetOdds = subset(testsetOdds, MatchID %in% data$MatchID)
    
    data = list(trainingData = trainingData, testData = testData, testsetOdds = testsetOdds)
    closeDatabase(db)
    
    return (data)
}
