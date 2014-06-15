rm(list = ls())
library(RSQLite)
setwd("Analysis")
source("Rcode/SQL/simQueries.R")

dataJoiner = function(match, lastMatches, basketFunction, playersQueryFunction) {
    homeSubmatches = getSubmatchesDataQuery(db, match$HomeTeamID, lastMatches, match$Date)
    awaySubmatches = getSubmatchesDataQuery(db, match$AwayTeamID, lastMatches, match$Date)
    
    players = playersQueryFunction(db, matchID = match$ID,
                                   submatchIDs = c(homeSubmatches$MatchID, awaySubmatches$MatchID), 
                                   teamIDs = c(match$HomeTeamID, match$AwayTeamID))
    homePlayers = subset(players, TeamID == match$HomeTeamID)
    awayPlayers = subset(players, TeamID == match$AwayTeamID)
    
    homeBaskets = basketFunction("A", match$HomeTeamID, homePlayers, homeSubmatches)
    awayBaskets = basketFunction("B", match$AwayTeamID, awayPlayers, awaySubmatches)
    
    return (c(Class = match$Class, MatchID = match$ID, A_Count = nrow(homeSubmatches),
              homeBaskets, B_Count = nrow(awaySubmatches), awayBaskets))
}

getTeamBaskets = function(prefix, teamID, teamPlayers, teamSubmatches) {
    baskets = getBasketsQuery(db, teamPlayers$TeamPlayerID, teamSubmatches$MatchID)
    if (nrow(baskets) == 0)
        results = rep(0, 6)
    else {
        aggr = aggregate(baskets$Baskets, 
                         list(pointType = ifelse(baskets$EventID == 8, 3, ifelse(baskets$EventID == 11, 1, 2)),
                              teamBaskets = baskets$InvolvedTeamID == teamID), sum)
        necessaryData = data.frame(pointType = c(1:3, 1:3), teamBaskets = c(FALSE, FALSE, FALSE, TRUE, TRUE, TRUE))
        merger = merge(necessaryData, aggr, by = c("pointType", "teamBaskets"), all.x = TRUE)
        merger = merger[order(merger$teamBaskets),]
        merger$x[is.na(merger$x)] = 0
        results = merger$x / sum(teamPlayers$Seconds)
    }
    names(results) = c(paste0(prefix, "_OPP_", c(1, 2, 3)), paste0(prefix, "_TEAM_", c(1, 2, 3)))
    
    return (results)
}

getTeamBasketsNonHomogeneous = function(prefix, teamID, teamPlayers, teamSubmatches) {
    baskets = getBasketsQueryNonHomogeneous(db, unique(teamPlayers$TeamPlayerID), teamSubmatches$MatchID)
    if (nrow(baskets) == 0)
        results = rep(0, 25)
    else {
        aggr = aggregate(baskets$Baskets, 
                         list(pointType = ifelse(baskets$EventID == 8, 3, ifelse(baskets$EventID == 11, 1, 2)),
                              teamBaskets = baskets$InvolvedTeamID == teamID,
                              period = baskets$Period), sum)
        necessaryData = data.frame(pointType = rep(1:3, 8), period = rep(1:4, each = 6),
                                   teamBaskets = rep(c(FALSE, FALSE, FALSE, TRUE, TRUE, TRUE), 4))
        merger = merge(necessaryData, aggr, by = c("period", "pointType", "teamBaskets"), all.x = TRUE)
        merger = merger[order(merger$teamBaskets),]
        merger$x[is.na(merger$x)] = 0
        
        periodTimes = aggregate(teamPlayers$PossessionTime, list(period = teamPlayers$Period), sum)
        periodTimesVec = rep(rep(periodTimes$x, each = 3), 2)
        
        results = c(merger$x / periodTimesVec, sum(periodTimes$x))
    }
    names(results) = c(paste0(prefix, "_", c(1, 2, 3), rep(paste0("_OPP_", c(1, 2, 3, 4)), each = 3)), 
                       paste0(prefix, "_", c(1, 2, 3), rep(paste0("_TEAM_", c(1, 2, 3, 4)), each = 3)),
                       paste0(prefix, "_TotalTime"))
    # pointType_teamType_period
    
    return (results)
}

buildData = function(lastMatches, filename, nonHomogeneous = FALSE) {
    if (nonHomogeneous) {
        basketFn = getTeamBasketsNonHomogeneous
        playersQueryFn = getTeamPlayersNonHomogeneousDataQuery
    }
    else {
        basketFn = getTeamBaskets
        playersQueryFn = getTeamPlayersDataQuery
    }
    matchData = sqlSimMatchesData(db)
    
    print (Sys.time())
    data = data.frame(t(dataJoiner(matchData[1,], lastMatches, basketFn, playersQueryFn)))
    
    for (i in 2:nrow(matchData)) {
        data = rbind(data, dataJoiner(matchData[i,], lastMatches, basketFn, playersQueryFn))
        if (i %% 1000 == 0) {
            data[,] <- as.numeric(as.matrix(data[,]))
            save(data, file = paste0("_", i , "_", filename))
        }
        print (paste0("Finished match ", i , ": ", Sys.time()))
    }
    
    data[,] <- as.numeric(as.matrix(data[,]))
    save(data, file = filename)
    print (Sys.time())
}

db = getDatabase()
#buildData(30, "simHomData.Rdata")
#buildData(30, "simNonHomData.Rdata", nonHomogeneous = TRUE)

load("datas/simHomData.Rdata")
dataHom = data
load("datas/simNonHomData.Rdata")
dataNonHom = data


## Homogeneous data playtimes correction

lastMatches = 30
matchData = sqlSimMatchesData(db)
dataHomCorrected = dataHom
dataHomCorrected$A_TotalTime = rep(0, nrow(dataHomCorrected))
dataHomCorrected$B_TotalTime = rep(0, nrow(dataHomCorrected))

for (i in 1:nrow(dataHom)) {
    match = matchData[i,]
    homeSubmatches = getSubmatchesDataQuery(db, match$HomeTeamID, lastMatches, match$Date)
    awaySubmatches = getSubmatchesDataQuery(db, match$AwayTeamID, lastMatches, match$Date)
    players = getTeamPlayersDataQuery(db, matchID = match$ID,
                                      submatchIDs = c(homeSubmatches$MatchID, awaySubmatches$MatchID), 
                                      teamIDs = c(match$HomeTeamID, match$AwayTeamID))
    homePlayers = subset(players, TeamID == match$HomeTeamID)
    awayPlayers = subset(players, TeamID == match$AwayTeamID)
    dataHomCorrected[i, 4:9] = dataHomCorrected[i, 4:9] * sum(homePlayers$Seconds) / dataNonHom[i, "A_TotalTime"]
    dataHomCorrected[i, 11:16] = dataHomCorrected[i, 11:16] * sum(awayPlayers$Seconds) / dataNonHom[i, "B_TotalTime"]
    dataHomCorrected[i, c("A_TotalTime", "B_TotalTime")] = c(sum(homePlayers$Seconds), sum(awayPlayers$Seconds))
    print (paste0("Finished match ", i , ": ", Sys.time()))
}
save(dataHomCorrected, file = "dataHomCorrected.Rdata")

## // Homogeneous data playtimes correction



basketsFinder = function(basketTimes, playTime) {
    cumulatedTimes = cumsum(basketTimes)
    cumulatedTimes[cumulatedTimes > playTime] = 0
    
    which.max(cumulatedTimes)
}

getScores = function(basketTimes, playTime, rows) {
    basketsVec = apply(basketTimes, 1, basketsFinder, playTime = playTime)
    basketsMat = matrix(basketsVec, nrow = rows)
    homeScores = 1*basketsMat[,1] + 2*basketsMat[,2] + 3*basketsMat[,3]
    awayScores = 1*basketsMat[,4] + 2*basketsMat[,5] + 3*basketsMat[,6]

    data.frame(homeScores = homeScores, awayScores = awayScores)
}

scoreSimulator = function(intensities) {
    rows = nrow(intensities)
    cols = ncol(intensities)
    
    basketTimes = matrix(rexp(rows*cols*100, rate = intensities), nrow = rows*cols)
    
    scores = getScores(basketTimes, 2880, rows)
    draws <- scores$homeScores == scores$awayScores
    overtime = 1
    
    while (sum(draws) != 0) {
        drawRows = rep(draws, cols)
        drawScores = getScores(basketTimes[drawRows,], 2880 + overtime*300, sum(draws))
        scores[draws,] = drawScores
        
        draws <- scores$homeScores == scores$awayScores
        overtime = overtime + 1
    }
    
    return (scores)
}

simulator = function(intensities, rows, trials = 100, scoreSimulatorFunction = scoreSimulator) {
    scoreTotals = matrix(0, nrow = rows, ncol = 2)
    winCounts = matrix(0, nrow = rows, ncol = 2)
    
    for (i in 1:trials) {
        scores = scoreSimulatorFunction(intensities)
        scoreTotals = scoreTotals + scores
        winCounts = winCounts + 1*cbind(scores$homeScores > scores$awayScores,
                                        scores$homeScores < scores$awayScores)
    }
    
    colnames(scoreTotals) = c("homeScores", "awayScores")
    colnames(winCounts) = c("homeWins", "awayWins")
    
    list(scores = as.data.frame(scoreTotals/trials), wins = as.data.frame(winCounts))
}

load("datas/dataHomCorrected.Rdata")
simData = subset(dataHomCorrected, A_Count >= 10 & B_Count >= 10)

lambda = 0.5
homeIntensities = lambda*simData[,7:9] + (1-lambda)*simData[,11:13]
awayIntensities = lambda*simData[,14:16] + (1-lambda)*simData[,4:6]
intensities = as.matrix(cbind(homeIntensities, awayIntensities))

results = simulator(intensities, rows = nrow(intensities), trials = 1001)
predClass1 = 1*(results$wins$homeWins >= results$wins$awayWins)
predClass2 = 1*(results$scores$homeScores >= results$scores$awayScores)
sum(simData$Class == predClass1) / nrow(simData)
sum(simData$Class == predClass2) / nrow(simData)


testset = getBaseTestSetQuery(db)

oddsRows = simData$MatchID %in% testset$MatchID
preds = (results$wins$homeWins / (results$wins$homeWins + results$wins$awayWins))[oddsRows]
preds = (1*(results$wins$homeWins >= results$wins$awayWins))[oddsRows]
preds = (1*(results$scores$homeScores >= results$scores$awayScores))[oddsRows]
testsetOdds = testset[testset$MatchID %in% simData$MatchID,]
cashflow = reproduceCashflow(testsetOdds, preds)
plot(cashflow, type = "l")
rev(cashflow)[1]



nonHomogeneousScoreSimulator = function(intensities) {
    rows = nrow(intensities[[1]][[1]])
    cols = 2*ncol(intensities[[1]][[1]])
    scores = data.frame(homeScores = rep(0, rows), awayScores = rep(0, rows))
    
    for (period in 1:4) {
        periodBasketTimes = matrix(rexp(rows*cols*25, rate = unlist(intensities[[period]])), nrow = rows*cols)
        periodScores = getScores(periodBasketTimes, 720, rows)
        scores = scores + periodScores
    }
    
    draws <- scores$homeScores == scores$awayScores
    overtime = 1
    
    while (sum(draws) != 0) {
        drawRows = rep(draws, cols)
        overtimeBasketTimes = matrix(rexp(rows*cols*15, rate = unlist(intensities[[4]])), nrow = rows*cols)
        drawScores = getScores(overtimeBasketTimes[drawRows,], 300, sum(draws))
        scores[draws,] = scores[draws,] + drawScores
        
        draws <- scores$homeScores == scores$awayScores
        overtime = overtime + 1
    }
    
    return (scores)
}


load("datas/simNonHomData.Rdata")
simData = subset(data, A_Count >= 10 & B_Count >= 10)
#names(simData)[4:27] = c(paste0("A_", c(1, 2, 3), rep(paste0("_OPP_", c(1, 2, 3, 4)), each = 3)), 
#                         paste0("A_", c(1, 2, 3), rep(paste0("_TEAM_", c(1, 2, 3, 4)), each = 3)))
#names(simData)[29:52] = c(paste0("B_", c(1, 2, 3), rep(paste0("_OPP_", c(1, 2, 3, 4)), each = 3)), 
#                         paste0("B_", c(1, 2, 3), rep(paste0("_TEAM_", c(1, 2, 3, 4)), each = 3)))
head(simData)

lambda = 0.5
homeIntensities = lambda*simData[,16:27] + (1-lambda)*simData[,30:41]
awayIntensities = lambda*simData[,42:53] + (1-lambda)*simData[,4:15]
intensities = list(first = list(home = homeIntensities[,1:3], away = awayIntensities[,1:3]),
                   second = list(home = homeIntensities[,4:6], away = awayIntensities[,4:6]),
                   third = list(home = homeIntensities[,7:9], away = awayIntensities[,7:9]),
                   fourth = list(home = homeIntensities[,10:12], away = awayIntensities[,10:12]))
results = simulator(intensities, rows = nrow(simData), trials = 1000, scoreSimulatorFunction = nonHomogeneousScoreSimulator)
predClass1 = 1*(results$wins$homeWins >= results$wins$awayWins)
predClass2 = 1*(results$scores$homeScores >= results$scores$awayScores)
sum(simData$Class == predClass1) / nrow(simData)
sum(simData$Class == predClass2) / nrow(simData)

oddsRows = simData$MatchID %in% testset$MatchID
preds = (results$wins$homeWins / (results$wins$homeWins + results$wins$awayWins))[oddsRows]
preds = (1*(results$wins$homeWins >= results$wins$awayWins))[oddsRows]
preds = (1*(results$scores$homeScores >= results$scores$awayScores))[oddsRows]
testsetOdds = testset[testset$MatchID %in% simData$MatchID,]
cashflow = reproduceCashflow(testsetOdds, preds)
plot(cashflow, type = "l")
rev(cashflow)[1]


closeDatabase(db)
