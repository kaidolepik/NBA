
sqlData = function(db, teamID, date, matches) {
    query = paste0("SELECT ",
                    "COUNT(*) AS Count, ",
                    "AVG(TeamA.PTS - TeamB.PTS) AS DIFF, ",
                    "AVG(1.0 * TeamA.PTS / TeamA.Minutes) AS PTS, ",
                    "AVG(1.0 * TeamA.FGM / TeamA.Minutes) AS FGM, ",
                    "AVG(1.0 * TeamA.FGA / TeamA.Minutes) AS FGA, ",
                    "AVG(1.0 * TeamA.'3FGM' / TeamA.Minutes) AS '3FGM', ",
                    "AVG(1.0 * TeamA.'3FGA' / TeamA.Minutes) AS '3FGA', ",
                    "AVG(1.0 * TeamA.FTM / TeamA.Minutes) AS FTM, ",
                    "AVG(1.0 * TeamA.FTA / TeamA.Minutes) AS FTA, ",
                    "AVG(1.0 * TeamA.OREB / TeamA.Minutes) AS OREB, ",
                    "AVG(1.0 * TeamA.DREB / TeamA.Minutes) AS DREB, ",
                    "AVG(1.0 * TeamA.AST / TeamA.Minutes) AS AST, ",
                    "AVG(1.0 * TeamA.TOV / TeamA.Minutes) AS TOV, ",
                    "AVG(1.0 * TeamA.STL / TeamA.Minutes) AS STL, ",
                    "AVG(1.0 * TeamA.BLK / TeamA.Minutes) AS BLK, ",
                    "AVG(1.0 * TeamA.PF / TeamA.Minutes) AS PF ",
                 "FROM (",
                    "SELECT ",
                        "xyz_Match.ID AS MatchID, ",
                        "(xyz_Match.Periods - 4)*5 + 48 AS Minutes, ",
                        "xyz_Match.HomeTeamID AS TeamA, ",
                        "xyz_Match.AwayTeamID AS TeamB, ",
                        "TeamAScores.* ",
                    "FROM ",
                        "xyz_Match ",
                        "INNER JOIN xyz_Scores AS TeamAScores ON xyz_Match.ID = TeamAScores.MatchID ",
                    "WHERE ",
                        "TeamAScores.TeamID = :teamID ",
                        "AND datetime(xyz_Match.Date) < datetime(:date) ",
                    "ORDER BY ",
                        "xyz_Match.ID DESC ",
                    "LIMIT :matches) AS TeamA ",
                 "INNER JOIN xyz_Scores AS TeamB ON (TeamB.MatchID = TeamA.MatchID AND TeamB.TeamID != :teamID);")
    sql = dbGetPreparedQuery(db, query, data.frame(teamID = teamID, date = date, matches = matches))
    
    return (sql)
}

sqlSideData = function(db, teamID, date, matches, sideTeamID) {
    query = paste0("SELECT ",
                    "COUNT(*) AS Count, ",
                    "AVG(TeamA.PTS - TeamB.PTS) AS DIFF, ",
                    "AVG(1.0 * TeamA.PTS / TeamA.Minutes) AS PTS, ",
                    "AVG(1.0 * TeamA.FGM / TeamA.Minutes) AS FGM, ",
                    "AVG(1.0 * TeamA.FGA / TeamA.Minutes) AS FGA, ",
                    "AVG(1.0 * TeamA.'3FGM' / TeamA.Minutes) AS '3FGM', ",
                    "AVG(1.0 * TeamA.'3FGA' / TeamA.Minutes) AS '3FGA', ",
                    "AVG(1.0 * TeamA.FTM / TeamA.Minutes) AS FTM, ",
                    "AVG(1.0 * TeamA.FTA / TeamA.Minutes) AS FTA, ",
                    "AVG(1.0 * TeamA.OREB / TeamA.Minutes) AS OREB, ",
                    "AVG(1.0 * TeamA.DREB / TeamA.Minutes) AS DREB, ",
                    "AVG(1.0 * TeamA.AST / TeamA.Minutes) AS AST, ",
                    "AVG(1.0 * TeamA.TOV / TeamA.Minutes) AS TOV, ",
                    "AVG(1.0 * TeamA.STL / TeamA.Minutes) AS STL, ",
                    "AVG(1.0 * TeamA.BLK / TeamA.Minutes) AS BLK, ",
                    "AVG(1.0 * TeamA.PF / TeamA.Minutes) AS PF ",
                 "FROM (",
                    "SELECT ",
                        "xyz_Match.ID AS MatchID, ",
                        "(xyz_Match.Periods - 4)*5 + 48 AS Minutes, ",
                        "xyz_Match.HomeTeamID AS TeamA, ",
                        "xyz_Match.AwayTeamID AS TeamB, ",
                        "TeamAScores.* ",
                    "FROM ",
                        "xyz_Match ",
                        "INNER JOIN xyz_Scores AS TeamAScores ON (",
                            "xyz_Match.ID = TeamAScores.MatchID ",
                            "AND xyz_Match.", sideTeamID, " = TeamAScores.TeamID)",
                    "WHERE ",
                        "TeamAScores.TeamID = :teamID ",
                        "AND datetime(xyz_Match.Date) < datetime(:date) ",
                    "ORDER BY ",
                        "xyz_Match.ID DESC ",
                    "LIMIT :matches) AS TeamA ",
                 "INNER JOIN xyz_Scores AS TeamB ON (TeamB.MatchID = TeamA.MatchID AND TeamB.TeamID != :teamID);")
    sql = dbGetPreparedQuery(db, query, data.frame(teamID = teamID, date = date, matches = matches))
    
    return (sql)
}

sqlMatchesData = function(db) {
    query = paste0("SELECT ", 
                        "xyz_Match.ID AS ID, ", 
                        "xyz_Match.HomeTeamID AS HomeTeamID, ",
                        "xyz_Match.AwayTeamID AS AwayTeamID, ",
                        "xyz_Match.Date AS Date, ",
                        "xyz_MatchResults.Winner AS Class ",
                   "FROM ", 
                        "xyz_Match ",
                        "INNER JOIN xyz_MatchResults ON xyz_MatchResults.ID = xyz_Match.ID;")
    sql = dbGetQuery(db, query)
    
    return (sql)
} 



### Deprecated functions?

getHomeAverageOfTeam = function(db, teamName, seasonID) {
    query = paste0("SELECT ",
                    "HomeAverage ",
                 "FROM ",
                    "test_HomePTSAverages ",
                 "WHERE ",
                    "TeamName = :teamName ",
                 "AND SeasonName = :seasonName;")
    sql = dbGetPreparedQuery(db, query, data.frame(teamName=teamName, seasonName=seasonName))
    
    return (sql)
}

getAwayAverageOfTeam = function(db, teamName, seasonID) {
    query = paste0("SELECT ",
                    "AwayAverage ",
                 "FROM ",
                    "test_AwayPTSAverages ",
                 "WHERE ",
                    "TeamName = :teamName ",
                 "AND SeasonName = :seasonName;")
    sql = dbGetPreparedQuery(db, query, data.frame(teamName=teamName, seasonName=seasonName))
    
    return (sql)
}

getAverageOfTeam = function(db, teamName, seasonID) {
    query = paste0("SELECT ",
                    "Average ",
                 "FROM ",
                    "test_PTSAverages ",
                 "WHERE ",
                    "TeamName = :teamName ",
                 "AND SeasonName = :seasonName;")
    sql = dbGetPreparedQuery(db, query, data.frame(teamName=teamName, seasonName=seasonName))
    
    return (sql)
}

dataQuery = function(db) {
    query = paste0("SELECT ",
                        "xyz_MatchResults.Winner AS Class, ",
                        "xyz_MatchResults.SeasonID AS Season, ",
                        "xyz_MatchResults.HomeTeam AS HomeTeam, ",
                        "xyz_MatchResults.AwayTeam AS AwayTeam, ",
                        "HomeAverages.*, ",
                        "AwayAverages.* ",
                   "FROM ",
                        "xyz_MatchResults ",
                        "INNER JOIN test_Averages AS HomeAverages ",
                            "ON HomeAverages.SeasonID = xyz_MatchResults.SeasonID+1 ",
                            "AND HomeAverages.TeamName = xyz_MatchResults.HomeTeam ",
                        "INNER JOIN test_Averages AS AwayAverages ",
                            "ON AwayAverages.SeasonID = xyz_MatchResults.SeasonID+1 ",
                            "AND AwayAverages.TeamName = xyz_MatchResults.AwayTeam;")
    sql = dbGetQuery(db, query)
    
    return (sql)
}
