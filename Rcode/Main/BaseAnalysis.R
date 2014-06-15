
### Siin tehakse analüüs lihtsate mudelitega ###
################################################
### Juhuslikud mudelid
### Koduvõitude mudel
### Viimaste omavaheliste mängude mudelid

rm(list=ls())
setwd("Analysis")
source("Rcode/SQL/DatabaseHandler.R")
source("Rcode/SQL/BaseQueries.R")
library(ggplot2)
library(grid)

db = getDatabase()

### Random betting ###

data = getBaseTestSetQuery()

randomBettor = function(trials, betSize = 1) {
    n = nrow(data)
    betSequences = matrix(NA, nrow = trials, ncol = n)
    for (i in 1:trials) {
        choices = round(runif(n))
        betSequences[i,] = cumsum((choices == data[, "Class"]) * 
                              ((choices == 1)*(data[, "HomeOdds"]-1) + (choices==0)*(data[, "AwayOdds"]-1))
                          - betSize*(choices != data[, "Class"]))
    }
    return (betSequences)
}

randomBettorMC = function(trials, betSize = 1) {
    results = rep(NA, trials)
    n = nrow(data)
    for (i in 1:trials) {
        choices = round(runif(n))
        cashflow = cumsum((choices == data[, "Class"]) * 
                              ((choices == 1)*(data[, "HomeOdds"]-1) + (choices==0)*(data[, "AwayOdds"]-1))
                          - betSize*(choices != data[, "Class"]))
        results[i] = cashflow[n]
    }
    return (results)
}

results.matrix = c()
for (trials in c(1, 10, 100, 1000)) {
    results = rep(NA, 100)
    for (i in 1:100)
        results[i] = mean(randomBettorMC(trials))
    results.matrix = rbind(results.matrix, cbind(results, rep(trials, 100)))
}

df = as.data.frame(results.matrix)
df$V2 = as.factor(df$V2)

pdf("pics/randomBoxplots.pdf")
p <- ggplot(df, aes(x = V2, y = results))
p + stat_boxplot(geom = "errorbar") + 
    geom_boxplot() +
    theme_bw() +
    labs(x = "Mängitud simulatsioonid", y = "Keskmine konto jääk (ühik)") +
    ggtitle("Konto lõppjääk juhuslikel panustamistel") +
    theme(panel.grid.major = element_line(size = .2, color = "grey"),
          axis.line = element_line(size = .5, color = "black"),
          legend.position = c(.2, .24), legend.text = element_text(size = 16), legend.key.width = unit(1.8, "cm"),
          axis.title = element_text(size = 16), plot.title = element_text(size = 18, face = "bold"))
dev.off()

randomBetting = randomBettor(10, 1)
df.MCaverage = data.frame(results = randomBettorMC(10000, 1))
average = mean(results.matrix[results.matrix[,2] == 1000, 1])
quant = quantile(df.MCaverage$results, 0.999)
expr = bquote(q[0.999] ~ "" %~~% "" ~ .(round(quant, 2)))

pdf("pics/randomHistogram.pdf")
ggplot(df.MCaverage, aes(x = results)) + geom_histogram(aes(y = ..density..), binwidth = 10) +
    geom_vline(xintercept = quant, colour = "red", size = .8) +
    theme_bw() +
    scale_x_continuous(breaks = c(-400, -200, 0, quant), labels = c(-400, -200, 0, expr)) +
    labs(x = "Konto lõppjääk", y = "Suhteline sagedus") +
    ggtitle("Konto lõppjäägi jaotus juhuslikel panustamistel") +
    theme(panel.grid.major = element_line(size = .2, color = "grey"),
          axis.line = element_line(size = .5, color = "black"),
          legend.position = c(.2, .24), legend.text = element_text(size = 16), legend.key.width = unit(1.8, "cm"),
          axis.title = element_text(size = 16), plot.title = element_text(size = 16, face = "bold"))
dev.off()

stackedSequences = stack(as.data.frame(t(randomBetting)))
stackedSequences$match <- rep(seq_len(ncol(randomBetting)), nrow(randomBetting))
stackedSequences$color <- rep("group 1", ncol(randomBetting))
df2 = data.frame(stackedSequences)

pdf("pics/randomSequences.pdf", width = 12)
p <- ggplot(df2, aes(x = match, y = values, group = ind, colour = color))
p + geom_line(aes(colour = "Juhuslik panustamine")) + 
    geom_hline(aes(yintercept = average, colour = "MC-keskmine"), 
               linetype = "twodash", size = .8) + 
    geom_hline(aes(yintercept = 0, colour = "Nullnivoo"),
               linetype = "longdash", size = .8) +
    scale_colour_manual(values = c("gray", "red", "blue")) +
    guides(colour = guide_legend(override.aes = list(linetype = c(1, 6, 5)), title = NULL)) +
    theme_bw() +
    labs(x = "Mäng", y = "Konto jääk (ühik)") +
    ggtitle("Kumulatiivne kontojääk juhuslikel panustamistel") +
    theme(panel.grid.major = element_line(size = .2, color = "grey"),
          axis.line = element_line(size = .5, color = "black"),
          legend.position = c(.2, .24), legend.text = element_text(size = 16), legend.key.width = unit(1.8, "cm"),
          axis.title = element_text(size = 14), plot.title = element_text(size = 16, face = "bold"))
dev.off()

### Betting based on home-away probabilities ###

trainingData = getBaseTrainingSetQuery(db)
homeWinProb = sum(trainingData$Class == 1) / nrow(trainingData)
awayWinProb = sum(trainingData$Class == 0) / nrow(trainingData)
testData = getBaseTestSetQuery(db)

betEvaluator = function(match, homeWinProb, awayWinProb, betSize = 1) {
    values.homeAway = unlist(c(homeWinProb * match["HomeOdds"], awayWinProb * match["AwayOdds"]))
    
    if (max(values.homeAway) > 1) {
        bettingChoice = which.max(values.homeAway)
        if (match["Class"] == bettingChoice || match["Class"] == 0 && bettingChoice == 2)
            return (c(match[c("HomeOdds", "AwayOdds")][bettingChoice] - 1, 2 - bettingChoice))
        return (c(-betSize, 2 - bettingChoice))
    }
    
    return (c(0, -1))
}

testError.homeAway = sum(testData$Class == 0) / nrow(testData)
cashflow.homeAway = cumsum(apply(testData, 1, betEvaluator, 
                                 homeWinProb = homeWinProb, awayWinProb = awayWinProb)[1,])

### Betting based on submatches ###

submatchesBettor = function(match, betSize = 1) {
    homeWinProb = match["HomeWins"] / match["Matches"]
    awayWinProb = 1 - homeWinProb
    return (betEvaluator(match, homeWinProb, awayWinProb, betSize))
}

matchLimits.total = c(1, 3, 5, 7, 10)
cashflows.total = c()
testErrors.total = c()
for (matchLimit in matchLimits.total) {
    data = getSubmatchesTotalQuery(db, 1, matchLimit)
    cashflow = cumsum(apply(data, 1, submatchesBettor)[1,])
    testError = 1 - sum((data$HomeWins/data$Matches >= 0.5) & (data$Class == 1) | 
                            (data$HomeWins/data$Matches < 0.5) & (data$Class == 0)) / nrow(data)
    cashflows.total = rbind(cashflows.total, cashflow)
    testErrors.total = c(testErrors.total, testError)
}

matplot(t(cashflows.total), type = "l")

### Betting based on submatches by field ###

matchLimits.field = c(1, 3, 5)
cashflows.field = c()
testErrors.field = c()
for (matchLimit in matchLimits.field) {
    data = getSubmatchesByFieldQuery(db, 1, matchLimit)
    cashflow = cumsum(apply(data, 1, submatchesBettor)[1,])
    testError = 1 - sum((data$HomeWins/data$Matches >= 0.5) & (data$Class == 1) | 
                            (data$HomeWins/data$Matches < 0.5) & (data$Class == 0)) / nrow(data)
    cashflows.field = rbind(cashflows.field, cashflow)
    testErrors.field = c(testErrors.field, testError)
}

matplot(t(cashflows.field), type = "l")

sequences = rbind(cashflow.homeAway, cashflows.total[1,], cashflows.field[1,])
stackedSequences = stack(as.data.frame(t(sequences)))
stackedSequences$match <- rep(seq_len(ncol(sequences)), nrow(sequences))
sequences.df = data.frame(stackedSequences)

pdf("pics/simpleModelSequences.pdf", width = 12)
p <- ggplot(sequences.df, aes(x = match, y = values, group = ind, colour = ind))
p + geom_line() +
    guides(colour = guide_legend(title = NULL)) +
    scale_colour_discrete(labels=c("Koduväljaku mudel", "Eelmine mäng", "Eelmine samal väljakul mäng")) +
    theme_bw() +
    labs(x = "Mäng", y = "Konto jääk (ühik)") +
    ggtitle("Kumulatiivne kontojääk lihtsate mudelitega panustamisel") +
    theme(panel.grid.major = element_line(size = .2, color = "grey"),
          axis.line = element_line(size = .5, color = "black"),
          legend.position = c(.2, .24), legend.text = element_text(size = 14), legend.key.width = unit(1.8, "cm"),
          axis.title = element_text(size = 14), plot.title = element_text(size = 16, face = "bold"))
dev.off()

# Find significance of cashflow endresult but only use this data on which was actually bet

significanceFinder = function(data, bets) {
    avg.bookies.prob = mean(c(1/data[bets == 1, "HomeOdds"], 1/data[bets == 0, "AwayOdds"]))
    avg.prob = avg.bookies.prob / 1.022
    expected.correct.bets = round(avg.prob * nrow(data))
    actual.correct.bets = sum(bets == data$Class)
    test.matrix = matrix(c(expected.correct.bets, nrow(data) - expected.correct.bets, 
                           actual.correct.bets, nrow(data) - actual.correct.bets), nrow = 2, byrow = TRUE)
    chisq.test(test.matrix)
}

data = getSubmatchesTotalQuery(db, 1, 1)
bet.evaluations = apply(data, 1, submatchesBettor)
bet.sides = bet.evaluations[2, bet.evaluations[2, ] != -1]
significance = significanceFinder(data, bet.sides)


closeDatabase(db)
