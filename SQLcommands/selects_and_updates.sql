-- Get scores and number of baskets
SELECT
    xyz_PlayEvent.EventID,
    xyz_PlayEvent.InvolvedTeamID,
    xyz_LineupPlayer.TeamPlayerID,
    (COUNT(*) * (CASE WHEN EventID = 8 THEN 3 ELSE (CASE WHEN EventID = 11 THEN 1 ELSE 2 END) END)) AS Points,
    COUNT(*) AS Baskets
FROM
    xyz_PlayByPlay
    INNER JOIN xyz_PlayEvent ON xyz_PlayEvent.PlayByPlayID = xyz_PlayByPlay.ID
    INNER JOIN xyz_Lineup ON xyz_Lineup.ID = xyz_PlayEvent.HomeLineupID
    INNER JOIN xyz_LineupPlayer ON xyz_LineupPlayer.LineupID = xyz_Lineup.ID
WHERE
    xyz_LineupPlayer.TeamPlayerID IN (3577)
    AND xyz_PlayByPlay.MatchID IN (21000055)
    AND xyz_PlayEvent.EventID IN (7, 8, 9, 10, 11, 21)
    AND xyz_PlayEvent.ShotInfo IS NULL
GROUP BY
    EventID, InvolvedTeamID, TeamPlayerID;
-- // Get scores and number of baskets
	
-- Get MatchIDs and play times
SELECT
    xyz_Match.ID AS MatchID,
    (xyz_Match.Periods - 4)*5 + 48 AS Minutes
FROM
    xyz_Match
    INNER JOIN xyz_Scores ON xyz_Match.ID = xyz_Scores.MatchID
WHERE
    xyz_Scores.TeamID = 1
    AND datetime(xyz_Match.Date) < datetime("2010-11-05")
    AND datetime(xyz_Match.Date) > datetime("2007-05-05")
ORDER BY
    xyz_Match.ID DESC
LIMIT 30;
-- // Get MatchIDs and play times

-- Get TeamPlayerIDs and playing times
SELECT
    xyz_PlayerScores.TeamPlayerID AS TeamPlayerID,
    SUM(xyz_PlayerScores.SecondsPlayed) AS PlayingTime,
    xyz_TeamPlayer.TeamID AS TeamID
FROM
    xyz_PlayerScores
    INNER JOIN xyz_TeamPlayer ON xyz_TeamPlayer.ID = xyz_PlayerScores.TeamPlayerID
WHERE
    xyz_PlayerScores.MatchID IN (21000058, 21000057)
    AND xyz_TeamPlayer.TeamID IN (1, 11)
GROUP BY
    TeamPlayerID, TeamID
-- // Get TeamPlayerIDs and playing times

-- Updating PlayEvent table to create faster queries later
UPDATE xyz_PlayEvent SET ShotInfo = "MISS"
WHERE 
    xyz_PlayEvent.EventID IN (7, 8, 9, 10, 11, 21)
    AND xyz_PlayEvent.PlayByPlayID IN ( 
SELECT xyz_PlayByPlay.ID FROM xyz_PlayByPlay INNER JOIN xyz_PlayEvent ON xyz_PlayEvent.PlayByPlayID = xyz_PlayByPlay.ID WHERE xyz_PlayEvent.EventID = 12)

UPDATE xyz_PlayEvent SET ShotInfo = (CASE WHEN ( ShotInfo IS NULL ) THEN "3PT" ELSE ShotInfo || " 3PT" END)
WHERE 
    xyz_PlayEvent.EventID IN (7, 9, 10, 11, 12, 21)
    AND xyz_PlayEvent.PlayByPlayID IN ( 
SELECT xyz_PlayByPlay.ID FROM xyz_PlayByPlay INNER JOIN xyz_PlayEvent ON xyz_PlayEvent.PlayByPlayID = xyz_PlayByPlay.ID WHERE xyz_PlayEvent.EventID = 8)
-- // Updating PlayEvent table to create faster queries later


