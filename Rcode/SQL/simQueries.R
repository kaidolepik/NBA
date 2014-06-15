
source("Analysis/Rcode/SQL/DatabaseHandler.R")

sqlSimMatchesData = function(db) {
    query = paste0("SELECT ", 
                        "xyz_Match.ID AS ID, ", 
                        "xyz_Match.HomeTeamID AS HomeTeamID, ",
                        "xyz_Match.AwayTeamID AS AwayTeamID, ",
                        "xyz_Match.Date AS Date, ",
                        "xyz_MatchResults.Winner AS Class ",
                   "FROM ", 
                        "xyz_Match ",
                        "INNER JOIN xyz_MatchResults ON xyz_MatchResults.ID = xyz_Match.ID ",
                    "WHERE ",
                        "xyz_Match.ID IN (SELECT MatchID FROM xyz_BestClosingOdds);")
    sql = dbGetQuery(db, query)
    
    return (sql)
} 

getSubmatchesDataQuery = function(db, teamID, matches, date) {
    query = paste0("SELECT ",
                        "xyz_Match.ID AS MatchID, ",
                        "((xyz_Match.Periods - 4)*5 + 48)*60 AS Seconds ",
                    "FROM ",
                        "xyz_Match ",
                        "INNER JOIN xyz_Scores ON xyz_Match.ID = xyz_Scores.MatchID ",
                    "WHERE ",
                        "xyz_Scores.TeamID = :teamID ",
                        "AND datetime(xyz_Match.Date) < datetime(:date) ",
                        "AND datetime(xyz_Match.Date) > datetime('2007-10-29') ",
                    "ORDER BY ",
                        "xyz_Match.ID DESC ",
                    "LIMIT :matches;")
    sql = dbGetPreparedQuery(db, query, data.frame(teamID = teamID, date = date, matches = matches))
    
    return (sql)
}

getTeamPlayersDataQuery = function(db, matchID, submatchIDs, teamIDs) {
    submatchIDsString = paste(submatchIDs, collapse = ", ")
    teamIDsString = paste(teamIDs, collapse = ", ")
    query = paste0("SELECT ",
                        "xyz_PlayerScores.TeamPlayerID AS TeamPlayerID, ",
                        "SUM(xyz_PlayerScores.SecondsPlayed) AS Seconds, ",
                        "xyz_TeamPlayer.TeamID AS TeamID ",
                    "FROM ",
                        "xyz_PlayerScores ",
                        "INNER JOIN xyz_TeamPlayer ON xyz_TeamPlayer.ID = xyz_PlayerScores.TeamPlayerID ",
                    "WHERE ",
                        "xyz_PlayerScores.MatchID IN (", submatchIDsString, ") ",
                        "AND xyz_TeamPlayer.TeamID IN (", teamIDsString, ") ",
                        "AND xyz_TeamPlayer.ID IN (",
                            "SELECT ",
                                "xyz_PlayerScores.TeamPlayerID ",
                            "FROM ",
                                "xyz_PlayerScores ",
                            "WHERE ",
                                "xyz_PlayerScores.MatchID = ", matchID, ") ",
                    "GROUP BY ",
                        "TeamID, TeamPlayerID;")
    sql = dbGetQuery(db, query)
    
    return (sql)
}

getTeamPlayersNonHomogeneousDataQuery = function(db, matchID, submatchIDs, teamIDs) {
    submatchIDsString = paste(submatchIDs, collapse = ", ")
    teamIDsString = paste(teamIDs, collapse = ", ")
    query = paste0("SELECT ",
                        "PlayTimes.TeamID AS TeamID, ",
                        "PlayTimes.TeamPlayerID AS TeamPlayerID, ",
                        "(CASE WHEN PlayTimes.Period < 4 THEN PlayTimes.Period ELSE 4 END) AS Period, ",
                        "SUM(PlayTimes.PossessionTime) AS PossessionTime ",
                   "FROM (",
                        "SELECT ",
                            "xyz_PlayByPlay.ID AS PlayByPlayID, ",
                            "xyz_PlayByPlay.Period AS Period, ",
                            "xyz_PlayByPlay.PossessionTime AS PossessionTime, ",
                            "xyz_Lineup.TeamID AS TeamID, ",
                            "xyz_LineupPlayer.TeamPlayerID AS TeamPlayerID ",
                        "FROM ",
                            "xyz_PlayByPlay ",
                            "INNER JOIN xyz_PlayEvent ON xyz_PlayEvent.PlayByPlayID = xyz_PlayByPlay.ID ",
                            "INNER JOIN xyz_Lineup ON xyz_Lineup.ID = xyz_PlayEvent.HomeLineupID ",
                            "INNER JOIN xyz_LineupPlayer ON xyz_LineupPlayer.LineupID = xyz_Lineup.ID ",
                        "WHERE ",
                            "xyz_LineupPlayer.TeamPlayerID IN (",
                                "SELECT ", 
                                    "xyz_PlayerScores.TeamPlayerID ",
                                "FROM ",
                                    "xyz_PlayerScores ",
                                "WHERE ",
                                    "xyz_PlayerScores.MatchID = ", matchID, ") ",
                            "AND xyz_Lineup.TeamID IN (", teamIDsString, ") ",
                            "AND xyz_PlayByPlay.MatchID IN (", submatchIDsString, ") ",
                            "AND xyz_PlayEvent.INFO != 'IN' ",
                        "UNION SELECT ",
                            "xyz_PlayByPlay.ID AS PlayByPlayID, ",
                            "xyz_PlayByPlay.Period AS Period, ",
                            "xyz_PlayByPlay.PossessionTime AS PossessionTime, ",
                            "xyz_Lineup.TeamID AS TeamID, ",
                            "xyz_LineupPlayer.TeamPlayerID AS TeamPlayerID ",
                        "FROM ",
                            "xyz_PlayByPlay ",
                            "INNER JOIN xyz_PlayEvent ON xyz_PlayEvent.PlayByPlayID = xyz_PlayByPlay.ID ",
                            "INNER JOIN xyz_Lineup ON xyz_Lineup.ID = xyz_PlayEvent.AwayLineupID ",
                            "INNER JOIN xyz_LineupPlayer ON xyz_LineupPlayer.LineupID = xyz_Lineup.ID ",
                        "WHERE ",
                            "xyz_LineupPlayer.TeamPlayerID IN (",
                                "SELECT ", 
                                    "xyz_PlayerScores.TeamPlayerID ",
                                "FROM ",
                                    "xyz_PlayerScores ",
                                "WHERE ",
                                    "xyz_PlayerScores.MatchID = ", matchID, ") ",
                            "AND xyz_Lineup.TeamID IN (", teamIDsString, ") ",
                            "AND xyz_PlayByPlay.MatchID IN (", submatchIDsString, ") ",
                            "AND xyz_PlayEvent.INFO != 'IN') AS PlayTimes ",
                    "GROUP BY ",
                        "(CASE WHEN Period < 4 THEN Period ELSE 4 END), TeamID, TeamPlayerID;")
    sql = dbGetQuery(db, query)
    
    return (sql)
}

getBasketsQuery = function(db, teamPlayerIDs, submatchIDs) {
    teamPlayerIDsString = paste(teamPlayerIDs, collapse = ", ")
    submatchIDsString = paste(submatchIDs, collapse = ", ")
    query = paste0("SELECT ",
                        "xyz_PlayByPlay.ID AS PlayByPlayID, ",
                        "xyz_PlayEvent.EventID AS EventID, ",
                        "xyz_PlayEvent.InvolvedTeamID AS InvolvedTeamID, ",
                        "xyz_LineupPlayer.TeamPlayerID AS TeamPlayerID, ",
                        "(COUNT(*) * (CASE WHEN EventID = 8 THEN 3 ",
                            "ELSE (CASE WHEN EventID = 11 THEN 1 ELSE 2 END) END)) AS Points, ",
                        "COUNT(*) AS Baskets ",
                   "FROM ",
                        "xyz_PlayByPlay ",
                        "INNER JOIN xyz_PlayEvent ON xyz_PlayEvent.PlayByPlayID = xyz_PlayByPlay.ID ",
                        "INNER JOIN xyz_Lineup ON xyz_Lineup.ID = xyz_PlayEvent.HomeLineupID ",
                        "INNER JOIN xyz_LineupPlayer ON xyz_LineupPlayer.LineupID = xyz_Lineup.ID ",
                   "WHERE ",
                        "xyz_LineupPlayer.TeamPlayerID IN (", teamPlayerIDsString, ") ",
                        "AND xyz_PlayByPlay.MatchID IN (", submatchIDsString, ") ",
                        "AND xyz_PlayEvent.EventID IN (7, 8, 9, 10, 11, 21) ",
                        "AND xyz_PlayEvent.ShotInfo IS NULL ",
                   "GROUP BY ",
                        "EventID, InvolvedTeamID, TeamPlayerID ",
                   "UNION SELECT ",
                        "xyz_PlayByPlay.ID AS PlayByPlayID, ",
                        "xyz_PlayEvent.EventID AS EventID, ",
                        "xyz_PlayEvent.InvolvedTeamID AS InvolvedTeamID, ",
                        "xyz_LineupPlayer.TeamPlayerID AS TeamPlayerID, ",
                        "(COUNT(*) * (CASE WHEN EventID = 8 THEN 3 ",
                            "ELSE (CASE WHEN EventID = 11 THEN 1 ELSE 2 END) END)) AS Points, ",
                        "COUNT(*) AS Baskets ",
                   "FROM ",
                        "xyz_PlayByPlay ",
                        "INNER JOIN xyz_PlayEvent ON xyz_PlayEvent.PlayByPlayID = xyz_PlayByPlay.ID ",
                        "INNER JOIN xyz_Lineup ON xyz_Lineup.ID = xyz_PlayEvent.AwayLineupID ",
                        "INNER JOIN xyz_LineupPlayer ON xyz_LineupPlayer.LineupID = xyz_Lineup.ID ",
                   "WHERE ",
                        "xyz_LineupPlayer.TeamPlayerID IN (", teamPlayerIDsString, ") ",
                        "AND xyz_PlayByPlay.MatchID IN (", submatchIDsString, ") ",
                        "AND xyz_PlayEvent.EventID IN (7, 8, 9, 10, 11, 21) ",
                        "AND xyz_PlayEvent.ShotInfo IS NULL ",
                   "GROUP BY ",
                        "EventID, InvolvedTeamID, TeamPlayerID;")
    sql = dbGetQuery(db, query)
    
    return (sql)
}

getBasketsQueryNonHomogeneous = function(db, teamPlayerIDs, submatchIDs) {
    teamPlayerIDsString = paste(teamPlayerIDs, collapse = ", ")
    submatchIDsString = paste(submatchIDs, collapse = ", ")
    query = paste0("SELECT ",
                        "xyz_PlayByPlay.ID AS PlayByPlayID, ",
                        "xyz_PlayEvent.EventID AS EventID, ",
                        "xyz_PlayEvent.InvolvedTeamID AS InvolvedTeamID, ",
                        "xyz_LineupPlayer.TeamPlayerID AS TeamPlayerID, ",
                        "(CASE WHEN Period < 4 THEN Period ELSE 4 END) AS Period, ",
                        "(COUNT(*) * (CASE WHEN EventID = 8 THEN 3 ",
                            "ELSE (CASE WHEN EventID = 11 THEN 1 ELSE 2 END) END)) AS Points, ",
                        "COUNT(*) AS Baskets ",
                   "FROM ",
                        "xyz_PlayByPlay ",
                        "INNER JOIN xyz_PlayEvent ON xyz_PlayEvent.PlayByPlayID = xyz_PlayByPlay.ID ",
                        "INNER JOIN xyz_Lineup ON xyz_Lineup.ID = xyz_PlayEvent.HomeLineupID ",
                        "INNER JOIN xyz_LineupPlayer ON xyz_LineupPlayer.LineupID = xyz_Lineup.ID ",
                   "WHERE ",
                        "xyz_LineupPlayer.TeamPlayerID IN (", teamPlayerIDsString, ") ",
                        "AND xyz_PlayByPlay.MatchID IN (", submatchIDsString, ") ",
                        "AND xyz_PlayEvent.EventID IN (7, 8, 9, 10, 11, 21) ",
                        "AND xyz_PlayEvent.ShotInfo IS NULL ",
                   "GROUP BY ",
                        "EventID, InvolvedTeamID, TeamPlayerID, (CASE WHEN Period < 4 THEN Period ELSE 4 END) ",
                   "UNION SELECT ",
                        "xyz_PlayByPlay.ID AS PlayByPlayID, ",
                        "xyz_PlayEvent.EventID AS EventID, ",
                        "xyz_PlayEvent.InvolvedTeamID AS InvolvedTeamID, ",
                        "xyz_LineupPlayer.TeamPlayerID AS TeamPlayerID, ",
                        "(CASE WHEN Period < 4 THEN Period ELSE 4 END) AS Period, ",
                        "(COUNT(*) * (CASE WHEN EventID = 8 THEN 3 ",
                            "ELSE (CASE WHEN EventID = 11 THEN 1 ELSE 2 END) END)) AS Points, ",
                        "COUNT(*) AS Baskets ",
                   "FROM ",
                        "xyz_PlayByPlay ",
                        "INNER JOIN xyz_PlayEvent ON xyz_PlayEvent.PlayByPlayID = xyz_PlayByPlay.ID ",
                        "INNER JOIN xyz_Lineup ON xyz_Lineup.ID = xyz_PlayEvent.AwayLineupID ",
                        "INNER JOIN xyz_LineupPlayer ON xyz_LineupPlayer.LineupID = xyz_Lineup.ID ",
                   "WHERE ",
                        "xyz_LineupPlayer.TeamPlayerID IN (", teamPlayerIDsString, ") ",
                        "AND xyz_PlayByPlay.MatchID IN (", submatchIDsString, ") ",
                        "AND xyz_PlayEvent.EventID IN (7, 8, 9, 10, 11, 21) ",
                        "AND xyz_PlayEvent.ShotInfo IS NULL ",
                   "GROUP BY ",
                        "EventID, InvolvedTeamID, TeamPlayerID, (CASE WHEN Period < 4 THEN Period ELSE 4 END);")
    sql = dbGetQuery(db, query)
    
    return (sql)
}
