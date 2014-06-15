rm(list=ls())
setwd("Analysis")
source("Rcode/Other/datasetBuilder.R")
source("Rcode/Other/featureSelectors.R")
source("Rcode/Other/betSimulator.R")
library(ada)
library(ggplot2)
library(grid)

data = getDataset("datasets/data_joiner_30.Rdata", minCount = 10)

greedyFeatures = forwardGreedyFeatureSelector(data$trainingData, data$testData)
#simulatedFeatures = simulatedAnnealingFeatureSelector(data$trainingData, data$testData)

model = glm(Class ~ ., data = data$trainingData[,c(1, greedyFeatures)], family = binomial)
predictProbsLog = predict(model, newdata = data$testData[,c(1, greedyFeatures)], type = "response")
cashflowLog = reproduceCashflow(data$testsetOdds, predictProbsLog, valueThreshold = 0, betSize = 1)
plot(cashflowLog, type = "l")
accuracy = getAccuracy(data$testData$Class, predictProbsLog)
accuracyByYear = getAccuracyByYear(data$testData$Class, predictProbsLog, data$testsetOdds$MatchID)

# Greedy features for AdaBoost
# A_DIFF B_DIFF B_DREB   A_PF  A_BLK 
# 2     17     26     16     15 

four = rpart.control(cp = -1 , maxdepth = 2, minsplit = 0)
model.ada = ada(Class ~ ., data = data$trainingData[,c(1, greedyFeatures)], control = four)
predictProbsAda = predict(model.ada, newdata = data$testData, type = "probs")[,2]
cashflowAda = reproduceCashflow(data$testsetOdds, predictProbsAda, valueThreshold = 0, betSize = 1)
plot(cashflowAda, type = "l")
accuracy = getAccuracy(data$testData$Class, predictProbsAda)

bookieAccuracy = getBookieAccuracy(data$testsetOdds)
bookieAccuracyByYear = getBookieAccuracyByYear(data$testsetOdds)



sequences = data.frame(values = c(cashflowLog, cashflowAda), match = rep(1:nrow(data$testData), 2),
                       group = as.factor(rep(1:2, each = nrow(data$testData))))
ROCdata = data.frame(true.class = data$testData$Class, scoreLog = predictProbsLog, scoreAda = predictProbsAda)
ROCdataLog = ROCdata[order(-ROCdata$scoreLog),]
ROCdataAda = ROCdata[order(-ROCdata$scoreAda),]

TPlog = c(0, cumsum(1/sum(ROCdataLog$true.class == 1)*(ROCdataLog$true.class == 1)))
FPlog = c(0, cumsum(1/sum(ROCdataLog$true.class == 0)*(ROCdataLog$true.class == 0)))

TPada= c(0, cumsum(1/sum(ROCdataAda$true.class == 1)*(ROCdataAda$true.class == 1)))
FPada = c(0, cumsum(1/sum(ROCdataAda$true.class == 0)*(ROCdataAda$true.class == 0)))

roc = data.frame(TP = c(TPlog, TPada), FP = c(FPlog, FPada),
                 group = as.factor(rep(1:2, each = nrow(data$testData)+1)))

pdf("pics/complexSequences.pdf", width = 12)
p <- ggplot(sequences, aes(x = match, y = values, group = group, colour = group))
p + geom_line() +
    guides(colour = guide_legend(title = NULL)) +
    #scale_colour_discrete(labels=c("Logistilise regressiooni mudel", "AdaBoosti mudel")) +
    theme_bw() +
    labs(x = "Mäng", y = "Konto jääk (ühik)") +
    ggtitle("Kumulatiivne kontojääk keerukamate mudelitega panustamisel") +
    scale_colour_brewer(labels=c("Logistilise regressiooni mudel", "AdaBoosti mudel"), palette = "Set1") + 
    theme(panel.grid.major = element_line(size = .2, color = "grey"),
          axis.line = element_line(size = .5, color = "black"),
          legend.position = c(.2, .24), legend.text = element_text(size = 14), legend.key.width = unit(1.8, "cm"),
          axis.title = element_text(size = 14), plot.title = element_text(size = 16, face = "bold"))
dev.off()

pdf("pics/ROC.pdf")
p <- ggplot(roc, aes(x = FP, y = TP, group = group, colour = group))
p + geom_line() +
    guides(colour = guide_legend(title = NULL)) +
    #scale_colour_discrete(labels=c("Logistilise regressiooni mudel", "AdaBoosti mudel")) +
    theme_bw() +
    labs(x = "Valepositiivsete osakaal", y = "Õigete positiivsete osakaal") +
    ggtitle("Logistilise regressiooni ja AdaBoosti ROC-kõver") +
    scale_colour_brewer(labels=c("Logistilise regressiooni mudel", "AdaBoosti mudel"), palette = "Set1") +
    theme(panel.grid.major = element_line(size = .2, color = "grey"),
          axis.line = element_line(size = .5, color = "black"),
          legend.position = c(.7, .24), legend.text = element_text(size = 14), legend.key.width = unit(1.8, "cm"),
          axis.title = element_text(size = 14), plot.title = element_text(size = 16, face = "bold")) +
    geom_abline(intercept = 0, slope = 1)
dev.off()



favourites <- 1*(data$testsetOdds$HomeOdds <= data$testsetOdds$AwayOdds)
accuracy = getAccuracy(data$testData$Class, favourites)
cashflow_favourites = reproduceCashflow(data$testsetOdds, favourites, valueThreshold = 0, betSize = 1)
cashflow_losers = reproduceCashflow(data$testsetOdds, ifelse(favourites==1, 0, 1), valueThreshold = 0, betSize = 1)
plot(cashflow_losers, type = "l", col = "blue")
lines(cashflow_favourites, type = "l", col = "red")
legend("bottomleft", c("betting on favourites", "betting on underdogs"), col = c("red", "blue"), lty = c("solid", "solid"))


data = getDataset("datasets/data_joiner_30.Rdata", minCount = 10)
data$testData = cbind(data$testData, HomeOdds = data$testsetOdds[,3])
greedyFeatures = forwardGreedyFeatureSelector(data$testData[1:4000,], data$testData[4001:5319,])

model = glm(Class ~ ., data = data$testData[1:4000, c(1, greedyFeatures)], family = binomial)
predictProbsLog = predict(model, newdata = data$testData[4001:5319,c(1, greedyFeatures)], type = "response")
cashflowLog = reproduceCashflow(data$testsetOdds[4001:5319,], predictProbsLog, valueThreshold = 0, betSize = 1)
plot(cashflowLog, type = "l")
accuracy = getAccuracy(data$testData[4001:5319,]$Class, predictProbsLog)
bookieAcc = getBookieAccuracy(data$testsetOdds[4001:5319,])
