
getBaseTestSetQuery = function(db) {
    query = paste0("SELECT ", 
                    "xyz_MatchResults.ID AS MatchID, ", 
                    "xyz_MatchResults.Winner AS Class, ", 
                    "HomeOdds.Odds AS HomeOdds, ", 
                    "AwayOdds.Odds AS AwayOdds ", 
                 "FROM ", 
                    "xyz_MatchResults ", 
                    "INNER JOIN xyz_BestClosingOdds AS HomeOdds ", 
                        "ON (HomeOdds.MatchID = xyz_MatchResults.ID ", 
                        "AND HomeOdds.TeamBundleID = xyz_MatchResults.HomeTeam) ", 
                    "INNER JOIN xyz_BestClosingOdds AS AwayOdds ",
                        "ON (AwayOdds.MatchID = xyz_MatchResults.ID ", 
                        "AND AwayOdds.TeamBundleID = xyz_MatchResults.AwayTeam);")
    sql = dbGetQuery(db, query)
    
    return (sql)
}

getBaseTrainingSetQuery = function(db) {
    sql = paste0("SELECT ", 
                    "xyz_MatchResults.ID AS MatchID, ", 
                    "xyz_MatchResults.Winner AS Class ", 
                 "FROM ", 
                    "xyz_MatchResults ", 
                 "WHERE ", 
                    "ID NOT IN (SELECT DISTINCT MatchID FROM xyz_BestClosingOdds);")
    sql = dbGetQuery(db, query)
    
    return (sql)
}

getSubmatchesTotalQuery = function(db, minMatches, maxMatches) {
    viewName = "Submatches"
    
    return (getSubmatchesQuery(db, viewName, minMatches, maxMatches))
}

getSubmatchesByFieldQuery = function(db, minMatches, maxMatches) {
    viewName = "SubmatchesByField"
    
    return (getSubmatchesQuery(db, viewName, minMatches, maxMatches))
}


### Privaatsena mõeldud meetod

getSubmatchesQuery = function(db, tableName, minMatches, maxMatches) {
    sql = paste0("CREATE TEMP TABLE IF NOT EXISTS tmp_", tableName, " ( ",
                    "'ID' INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL UNIQUE, ",
                    "'MatchID' INTEGER NOT NULL, ",
                    "'TeamA' INTEGER NOT NULL, ",
                    "'TeamB' INTEGER NOT NULL, ",
                    "'SubmatchID' INTEGER NOT NULL, ",
                    "'Winner' INTEGER NOT NULL);")
    dbGetQuery(db, sql)
    sql = paste0("CREATE INDEX IF NOT EXISTS 'temp'.'Index_", tableName, "_MatchID' ON 'tmp_",
                 tableName, "' ('MatchID' DESC);")
    dbGetQuery(db, sql)
    sql = paste0("INSERT OR IGNORE INTO tmp_", tableName, " (",
                        "'MatchID', 'TeamA', 'TeamB', 'SubmatchID', 'Winner') ", 
                    "SELECT * FROM xyz_", tableName, ";")
    dbGetQuery(db, sql)
    sql = paste0("SELECT ", 
                    "xyz_MatchResults.ID AS MatchID, ", 
                    "xyz_MatchResults.Winner AS Class, ", 
                    "HomeOdds.Odds AS HomeOdds, ", 
                    "AwayOdds.Odds AS AwayOdds, ",
                    "Submatches.HomeWins AS HomeWins, ",
                    "Submatches.Matches AS Matches ",
                 "FROM ", 
                    "xyz_MatchResults ", 
                    "INNER JOIN xyz_BestClosingOdds AS HomeOdds ", 
                        "ON (HomeOdds.MatchID = xyz_MatchResults.ID ", 
                        "AND HomeOdds.TeamBundleID = xyz_MatchResults.HomeTeam) ", 
                    "INNER JOIN xyz_BestClosingOdds AS AwayOdds ",
                        "ON (AwayOdds.MatchID = xyz_MatchResults.ID ", 
                        "AND AwayOdds.TeamBundleID = xyz_MatchResults.AwayTeam) ",
                    "INNER JOIN (",
                        "SELECT ",
                            "SubmatchesA.MatchID AS MatchID, ",
                            "SUM(SubmatchesA.Winner) AS HomeWins, ",
                            "COUNT(SubmatchesA.SubmatchID) AS Matches ",
                        "FROM ",
                            "tmp_", tableName, " AS SubmatchesA ",
                        "WHERE ",
                            "MatchID IN (SELECT DISTINCT MatchID FROM xyz_BestClosingOdds) ",
                            "AND SubmatchesA.ID IN (",
                                "SELECT ", 
                                    "SubmatchesB.ID ", 
                                "FROM ", 
                                    "tmp_", tableName, " AS SubmatchesB ",
                                "WHERE ", 
                                    "SubmatchesA.MatchID = SubmatchesB.MatchID ", 
                                "ORDER BY ",
                                    "SubmatchesB.SubmatchID DESC ",
                                "LIMIT :maxMatches",
                            ") ",
                        "GROUP BY ",
                            "SubmatchesA.MatchID ",
                        "HAVING ",
                            "Matches >= :minMatches) ",
                    "AS Submatches ",
                        "ON Submatches.MatchID = xyz_MatchResults.ID;")
    query = dbGetPreparedQuery(db, sql, data.frame(minMatches = minMatches, maxMatches = maxMatches))
    
    sql = paste0("DROP TABLE tmp_", tableName, ";")
    dbGetQuery(db, sql)
    
    return (query)
}
