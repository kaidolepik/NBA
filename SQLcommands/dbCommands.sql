-- CONFERENCE
CREATE TABLE "xyz_Conference" (
	"ID" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL UNIQUE, 
	"Name" VARCHAR NOT NULL UNIQUE);
INSERT INTO xyz_Conference ("Name") VALUES ("Eastern");
INSERT INTO xyz_Conference ("Name") VALUES ("Western");
-- // CONFERENCE

-- DIVISION
CREATE TABLE "xyz_Division" (
	"ID" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL UNIQUE, 
	"ConferenceID" INTEGER NOT NULL, 
	"Name" VARCHAR NOT NULL UNIQUE);
INSERT INTO xyz_Division ("ConferenceID", "Name") VALUES (1, "Atlantic");
INSERT INTO xyz_Division ("ConferenceID", "Name") VALUES (1, "Central");
INSERT INTO xyz_Division ("ConferenceID", "Name") VALUES (1, "Southeast");
INSERT INTO xyz_Division ("ConferenceID", "Name") VALUES (2, "Southwest");
INSERT INTO xyz_Division ("ConferenceID", "Name") VALUES (2, "Northwest");
INSERT INTO xyz_Division ("ConferenceID", "Name") VALUES (2, "Pacific");
-- // DIVISION

-- TEAMBUNDLE
CREATE TABLE "xyz_TeamBundle" (
	"ID" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL UNIQUE, 
	"ConferenceID" INTEGER NOT NULL, 
	"DivisionID" INTEGER NOT NULL, 
	"Name" VARCHAR NOT NULL UNIQUE);
INSERT INTO xyz_TeamBundle ("ConferenceID", "DivisionID", "Name") VALUES (1, 1, "Boston Celtics");
INSERT INTO xyz_TeamBundle ("ConferenceID", "DivisionID", "Name") VALUES (1, 1, "Brooklyn Nets");
INSERT INTO xyz_TeamBundle ("ConferenceID", "DivisionID", "Name") VALUES (1, 1, "New York Knicks");
INSERT INTO xyz_TeamBundle ("ConferenceID", "DivisionID", "Name") VALUES (1, 1, "Philadelphia 76ers");
INSERT INTO xyz_TeamBundle ("ConferenceID", "DivisionID", "Name") VALUES (1, 1, "Toronto Raptors");
INSERT INTO xyz_TeamBundle ("ConferenceID", "DivisionID", "Name") VALUES (1, 2, "Chicago Bulls");
INSERT INTO xyz_TeamBundle ("ConferenceID", "DivisionID", "Name") VALUES (1, 2, "Cleveland Cavaliers");
INSERT INTO xyz_TeamBundle ("ConferenceID", "DivisionID", "Name") VALUES (1, 2, "Detroit Pistons");
INSERT INTO xyz_TeamBundle ("ConferenceID", "DivisionID", "Name") VALUES (1, 2, "Indiana Pacers");
INSERT INTO xyz_TeamBundle ("ConferenceID", "DivisionID", "Name") VALUES (1, 2, "Milwaukee Bucks");
INSERT INTO xyz_TeamBundle ("ConferenceID", "DivisionID", "Name") VALUES (1, 3, "Atlanta Hawks");
INSERT INTO xyz_TeamBundle ("ConferenceID", "DivisionID", "Name") VALUES (1, 3, "Charlotte Bobcats");
INSERT INTO xyz_TeamBundle ("ConferenceID", "DivisionID", "Name") VALUES (1, 3, "Miami Heat");
INSERT INTO xyz_TeamBundle ("ConferenceID", "DivisionID", "Name") VALUES (1, 3, "Orlando Magic");
INSERT INTO xyz_TeamBundle ("ConferenceID", "DivisionID", "Name") VALUES (1, 3, "Washington Wizards");
INSERT INTO xyz_TeamBundle ("ConferenceID", "DivisionID", "Name") VALUES (2, 4, "Dallas Mavericks");
INSERT INTO xyz_TeamBundle ("ConferenceID", "DivisionID", "Name") VALUES (2, 4, "Houston Rockets");
INSERT INTO xyz_TeamBundle ("ConferenceID", "DivisionID", "Name") VALUES (2, 4, "Memphis Grizzlies");
INSERT INTO xyz_TeamBundle ("ConferenceID", "DivisionID", "Name") VALUES (2, 4, "New Orleans Pelicans");
INSERT INTO xyz_TeamBundle ("ConferenceID", "DivisionID", "Name") VALUES (2, 4, "San Antonio Spurs");
INSERT INTO xyz_TeamBundle ("ConferenceID", "DivisionID", "Name") VALUES (2, 5, "Denver Nuggets");
INSERT INTO xyz_TeamBundle ("ConferenceID", "DivisionID", "Name") VALUES (2, 5, "Minnesota Timberwolves");
INSERT INTO xyz_TeamBundle ("ConferenceID", "DivisionID", "Name") VALUES (2, 5, "Portland Trail Blazers");
INSERT INTO xyz_TeamBundle ("ConferenceID", "DivisionID", "Name") VALUES (2, 5, "Oklahoma City Thunder");
INSERT INTO xyz_TeamBundle ("ConferenceID", "DivisionID", "Name") VALUES (2, 5, "Utah Jazz");
INSERT INTO xyz_TeamBundle ("ConferenceID", "DivisionID", "Name") VALUES (2, 6, "Golden State Warriors");
INSERT INTO xyz_TeamBundle ("ConferenceID", "DivisionID", "Name") VALUES (2, 6, "Los Angeles Clippers");
INSERT INTO xyz_TeamBundle ("ConferenceID", "DivisionID", "Name") VALUES (2, 6, "Los Angeles Lakers");
INSERT INTO xyz_TeamBundle ("ConferenceID", "DivisionID", "Name") VALUES (2, 6, "Phoenix Suns");
INSERT INTO xyz_TeamBundle ("ConferenceID", "DivisionID", "Name") VALUES (2, 6, "Sacramento Kings");
-- // TEAMBUNDLE

-- TEAM
CREATE TABLE "xyz_Team" (
	"ID" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL UNIQUE, 
	"TeamBundleID" INTEGER NOT NULL, 
	"Name" VARCHAR NOT NULL UNIQUE);
INSERT INTO xyz_Team ("TeamBundleID", "Name") VALUES (1, "Boston Celtics");
INSERT INTO xyz_Team ("TeamBundleID", "Name") VALUES (2, "New Jersey Nets");
INSERT INTO xyz_Team ("TeamBundleID", "Name") VALUES (2, "Brooklyn Nets");
INSERT INTO xyz_Team ("TeamBundleID", "Name") VALUES (3, "New York Knicks");
INSERT INTO xyz_Team ("TeamBundleID", "Name") VALUES (4, "Philadelphia 76ers");
INSERT INTO xyz_Team ("TeamBundleID", "Name") VALUES (5, "Toronto Raptors");
INSERT INTO xyz_Team ("TeamBundleID", "Name") VALUES (6, "Chicago Bulls");
INSERT INTO xyz_Team ("TeamBundleID", "Name") VALUES (7, "Cleveland Cavaliers");
INSERT INTO xyz_Team ("TeamBundleID", "Name") VALUES (8, "Detroit Pistons");
INSERT INTO xyz_Team ("TeamBundleID", "Name") VALUES (9, "Indiana Pacers");
INSERT INTO xyz_Team ("TeamBundleID", "Name") VALUES (10, "Milwaukee Bucks");
INSERT INTO xyz_Team ("TeamBundleID", "Name") VALUES (11, "Atlanta Hawks");
INSERT INTO xyz_Team ("TeamBundleID", "Name") VALUES (12, "Charlotte Bobcats");
INSERT INTO xyz_Team ("TeamBundleID", "Name") VALUES (13, "Miami Heat");
INSERT INTO xyz_Team ("TeamBundleID", "Name") VALUES (14, "Orlando Magic");
INSERT INTO xyz_Team ("TeamBundleID", "Name") VALUES (15, "Washington Wizards");
INSERT INTO xyz_Team ("TeamBundleID", "Name") VALUES (16, "Dallas Mavericks");
INSERT INTO xyz_Team ("TeamBundleID", "Name") VALUES (17, "Houston Rockets");
INSERT INTO xyz_Team ("TeamBundleID", "Name") VALUES (18, "Memphis Grizzlies");
INSERT INTO xyz_Team ("TeamBundleID", "Name") VALUES (18, "Vancouver Grizzlies");
INSERT INTO xyz_Team ("TeamBundleID", "Name") VALUES (19, "New Orleans Hornets");
INSERT INTO xyz_Team ("TeamBundleID", "Name") VALUES (19, "Charlotte Hornets");
INSERT INTO xyz_Team ("TeamBundleID", "Name") VALUES (19, "New Orleans Pelicans");
INSERT INTO xyz_Team ("TeamBundleID", "Name") VALUES (20, "San Antonio Spurs");
INSERT INTO xyz_Team ("TeamBundleID", "Name") VALUES (21, "Denver Nuggets");
INSERT INTO xyz_Team ("TeamBundleID", "Name") VALUES (22, "Minnesota Timberwolves");
INSERT INTO xyz_Team ("TeamBundleID", "Name") VALUES (23, "Portland Trail Blazers");
INSERT INTO xyz_Team ("TeamBundleID", "Name") VALUES (24, "Oklahoma City Thunder");
INSERT INTO xyz_Team ("TeamBundleID", "Name") VALUES (24, "Seattle SuperSonics");
INSERT INTO xyz_Team ("TeamBundleID", "Name") VALUES (25, "Utah Jazz");
INSERT INTO xyz_Team ("TeamBundleID", "Name") VALUES (26, "Golden State Warriors");
INSERT INTO xyz_Team ("TeamBundleID", "Name") VALUES (27, "Los Angeles Clippers");
INSERT INTO xyz_Team ("TeamBundleID", "Name") VALUES (28, "Los Angeles Lakers");
INSERT INTO xyz_Team ("TeamBundleID", "Name") VALUES (29, "Phoenix Suns");
INSERT INTO xyz_Team ("TeamBundleID", "Name") VALUES (30, "Sacramento Kings");
-- // TEAM

-- SEASON
CREATE TABLE "xyz_Season" (
	"ID" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL UNIQUE, 
	"Name" VARCHAR NOT NULL UNIQUE,
	"StartYear" INTEGER NOT NULL UNIQUE, 
	"EndYear" INTEGER NOT NULL UNIQUE);
INSERT INTO xyz_Season ("Name", "StartYear", "EndYear") VALUES ("2012-13", 2012, 2013);
INSERT INTO xyz_Season ("Name", "StartYear", "EndYear") VALUES ("2011-12", 2011, 2012);
INSERT INTO xyz_Season ("Name", "StartYear", "EndYear") VALUES ("2010-11", 2010, 2011);
INSERT INTO xyz_Season ("Name", "StartYear", "EndYear") VALUES ("2009-10", 2009, 2010);
INSERT INTO xyz_Season ("Name", "StartYear", "EndYear") VALUES ("2008-09", 2008, 2009);
INSERT INTO xyz_Season ("Name", "StartYear", "EndYear") VALUES ("2007-08", 2007, 2008);
INSERT INTO xyz_Season ("Name", "StartYear", "EndYear") VALUES ("2006-07", 2006, 2007);
INSERT INTO xyz_Season ("Name", "StartYear", "EndYear") VALUES ("2005-06", 2005, 2006);
INSERT INTO xyz_Season ("Name", "StartYear", "EndYear") VALUES ("2004-05", 2004, 2005);
INSERT INTO xyz_Season ("Name", "StartYear", "EndYear") VALUES ("2003-04", 2003, 2004);
INSERT INTO xyz_Season ("Name", "StartYear", "EndYear") VALUES ("2002-03", 2002, 2003);
INSERT INTO xyz_Season ("Name", "StartYear", "EndYear") VALUES ("2001-02", 2001, 2002);
INSERT INTO xyz_Season ("Name", "StartYear", "EndYear") VALUES ("2000-01", 2000, 2001);
-- // SEASON

-- MATCH (use Python to fill)
CREATE TABLE "xyz_Match" (
	"ID" INTEGER PRIMARY KEY NOT NULL UNIQUE, 
	"SeasonID" INTEGER NOT NULL, 
	"HomeTeamID" INTEGER NOT NULL, 
	"AwayTeamID" INTEGER NOT NULL, 
	"Periods" INTEGER NOT NULL, 
	"Date" DATETIME NOT NULL);
-- // MATCH

-- SCORES
CREATE TABLE "xyz_Scores" (
	"ID" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL UNIQUE, 
	"MatchID" INTEGER NOT NULL, 
	"TeamID" INTEGER NOT NULL, 
	"FGM" INTEGER NOT NULL, 
	"FGA" INTEGER NOT NULL, 
	"3FGM" INTEGER NOT NULL, 
	"3FGA" INTEGER NOT NULL, 
	"FTM" INTEGER NOT NULL, 
	"FTA" INTEGER NOT NULL, 
	"OREB" INTEGER NOT NULL, 
	"DREB" INTEGER NOT NULL, 
	"AST" INTEGER NOT NULL, 
	"TOV" INTEGER NOT NULL, 
	"STL" INTEGER NOT NULL, 
	"BLK" INTEGER NOT NULL, 
	"PF" INTEGER NOT NULL, 
	"PTS" INTEGER NOT NULL);
INSERT INTO xyz_Scores (
		"MatchID", "TeamID", "FGM", "FGA", "3FGM", "3FGA", 
		"FTM", "FTA", "OREB", "DREB", "AST", "TOV", "STL", "BLK", "PF", "PTS") 
    SELECT 
		MatchID, xyz_Team.ID, FGM, FGA, "3FGM", "3FGA", 
		FTM, FTA, OREB, DREB, AST, TOV, STL, BLK, PF, PTS
    FROM 
		raw_TeamScores 
		INNER JOIN xyz_Team ON xyz_Team.Name = raw_TeamScores.TeamName;
-- // SCORES	
	
-- BOOKIE
CREATE TABLE "xyz_Bookie" (
	"ID" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL UNIQUE, 
	"Name" VARCHAR NOT NULL UNIQUE);
INSERT INTO xyz_Bookie ("Name") VALUES ("bet-at-home");
INSERT INTO xyz_Bookie ("Name") VALUES ("bet365");
INSERT INTO xyz_Bookie ("Name") VALUES ("BetVictor");
INSERT INTO xyz_Bookie ("Name") VALUES ("bwin");
INSERT INTO xyz_Bookie ("Name") VALUES ("MarathonBet");
INSERT INTO xyz_Bookie ("Name") VALUES ("Pinnacle Sports");
INSERT INTO xyz_Bookie ("Name") VALUES ("Titanbet");
INSERT INTO xyz_Bookie ("Name") VALUES ("TonyBet");
INSERT INTO xyz_Bookie ("Name") VALUES ("Unibet");
INSERT INTO xyz_Bookie ("Name") VALUES ("William Hill");
INSERT INTO xyz_Bookie ("Name") VALUES ("youwin");
INSERT INTO xyz_Bookie ("Name") VALUES ("10Bet");
-- // BOOKIE

-- ODDS
UPDATE raw_Odds 
	SET GameType = "All Stars" 
	WHERE 
		GameType = "Regular" 
		AND (AwayTeamName IN ("East", "Rookies") OR HomeTeamName IN ("West", "Sophomores"));
CREATE TABLE "xyz_Odds" (
	"ID" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL UNIQUE, 
	"MatchID" INTEGER NOT NULL, 
	"TeamBundleID" INTEGER NOT NULL, 
	"BookieID" INTEGER NOT NULL, 
	"Odds" DOUBLE NOT NULL, 
	"IsOpening" BOOL, 
	"IsClosing" BOOL);
CREATE VIEW helper_Info AS
	SELECT 
		xyz_Match.ID,
		HomeBundle.Name AS HomeName,
		AwayBundle.Name AS AwayName,
		HomeScores.PTS AS HomeScore,
		AwayScores.PTS AS AwayScore,
		strftime('%d ', Date)
			|| CASE WHEN (  strftime('%m', Date)   = '01') THEN ('Jan') ELSE '' END
			|| CASE WHEN (  strftime('%m', Date)   = '02') THEN ('Feb') ELSE '' END
			|| CASE WHEN (  strftime('%m', Date)   = '03') THEN ('Mar') ELSE '' END
			|| CASE WHEN (  strftime('%m', Date)   = '04') THEN ('Apr') ELSE '' END
			|| CASE WHEN (  strftime('%m', Date)   = '05') THEN ('May') ELSE '' END
			|| CASE WHEN (  strftime('%m', Date)   = '06') THEN ('Jun') ELSE '' END
			|| CASE WHEN (  strftime('%m', Date)   = '07') THEN ('Jul') ELSE '' END
			|| CASE WHEN (  strftime('%m', Date)   = '08') THEN ('Aug') ELSE '' END
			|| CASE WHEN (  strftime('%m', Date)   = '09') THEN ('Sep') ELSE '' END
			|| CASE WHEN (  strftime('%m', Date)   = '10') THEN ('Oct') ELSE '' END
			|| CASE WHEN (  strftime('%m', Date)   = '11') THEN ('Nov') ELSE '' END
			|| CASE WHEN (  strftime('%m', Date)   = '12') THEN ('Dec') ELSE '' END
			|| strftime(' %Y', Date) 
		AS Date1,
		strftime('%d ', datetime(Date, "-1 days"))
			|| CASE WHEN (  strftime('%m', datetime(Date, "-1 days"))   = '01') THEN ('Jan') ELSE '' END
			|| CASE WHEN (  strftime('%m', datetime(Date, "-1 days"))   = '02') THEN ('Feb') ELSE '' END
			|| CASE WHEN (  strftime('%m', datetime(Date, "-1 days"))   = '03') THEN ('Mar') ELSE '' END
			|| CASE WHEN (  strftime('%m', datetime(Date, "-1 days"))   = '04') THEN ('Apr') ELSE '' END
			|| CASE WHEN (  strftime('%m', datetime(Date, "-1 days"))   = '05') THEN ('May') ELSE '' END
			|| CASE WHEN (  strftime('%m', datetime(Date, "-1 days"))   = '06') THEN ('Jun') ELSE '' END
			|| CASE WHEN (  strftime('%m', datetime(Date, "-1 days"))   = '07') THEN ('Jul') ELSE '' END
			|| CASE WHEN (  strftime('%m', datetime(Date, "-1 days"))   = '08') THEN ('Aug') ELSE '' END
			|| CASE WHEN (  strftime('%m', datetime(Date, "-1 days"))   = '09') THEN ('Sep') ELSE '' END
			|| CASE WHEN (  strftime('%m', datetime(Date, "-1 days"))   = '10') THEN ('Oct') ELSE '' END
			|| CASE WHEN (  strftime('%m', datetime(Date, "-1 days"))   = '11') THEN ('Nov') ELSE '' END
			|| CASE WHEN (  strftime('%m', datetime(Date, "-1 days"))   = '12') THEN ('Dec') ELSE '' END
			|| strftime(' %Y', datetime(Date, "-1 days")) 
		AS Date2,
		strftime('%d ', datetime(Date, "+1 days"))
			|| CASE WHEN (  strftime('%m', datetime(Date, "+1 days"))   = '01') THEN ('Jan') ELSE '' END
			|| CASE WHEN (  strftime('%m', datetime(Date, "+1 days"))   = '02') THEN ('Feb') ELSE '' END
			|| CASE WHEN (  strftime('%m', datetime(Date, "+1 days"))   = '03') THEN ('Mar') ELSE '' END
			|| CASE WHEN (  strftime('%m', datetime(Date, "+1 days"))   = '04') THEN ('Apr') ELSE '' END
			|| CASE WHEN (  strftime('%m', datetime(Date, "+1 days"))   = '05') THEN ('May') ELSE '' END
			|| CASE WHEN (  strftime('%m', datetime(Date, "+1 days"))   = '06') THEN ('Jun') ELSE '' END
			|| CASE WHEN (  strftime('%m', datetime(Date, "+1 days"))   = '07') THEN ('Jul') ELSE '' END
			|| CASE WHEN (  strftime('%m', datetime(Date, "+1 days"))   = '08') THEN ('Aug') ELSE '' END
			|| CASE WHEN (  strftime('%m', datetime(Date, "+1 days"))   = '09') THEN ('Sep') ELSE '' END
			|| CASE WHEN (  strftime('%m', datetime(Date, "+1 days"))   = '10') THEN ('Oct') ELSE '' END
			|| CASE WHEN (  strftime('%m', datetime(Date, "+1 days"))   = '11') THEN ('Nov') ELSE '' END
			|| CASE WHEN (  strftime('%m', datetime(Date, "+1 days"))   = '12') THEN ('Dec') ELSE '' END
			|| strftime(' %Y', datetime(Date, "+1 days")) 
		AS Date3
	FROM 
		xyz_Match
		INNER JOIN xyz_Team AS HomeTeam ON xyz_Match.HomeTeamID = HomeTeam.ID
		INNER JOIN xyz_TeamBundle AS HomeBundle ON HomeTeam.TeamBundleID = HomeBundle.ID
		INNER JOIN xyz_Scores AS HomeScores ON (xyz_Match.HomeTeamID = HomeScores.TeamID AND xyz_Match.ID = HomeScores.MatchID)
		INNER JOIN xyz_Team AS AwayTeam ON xyz_Match.AwayTeamID = AwayTeam.ID
		INNER JOIN xyz_TeamBundle AS AwayBundle ON AwayTeam.TeamBundleID = AwayBundle.ID
		INNER JOIN xyz_Scores AS AwayScores ON (xyz_Match.AwayTeamID = AwayScores.TeamID AND xyz_Match.ID = AwayScores.MatchID);
INSERT INTO "xyz_Odds" (
		MatchID, TeamBundleID, BookieID, Odds, IsOpening, IsClosing) 
    SELECT
    	Info.ID, Bundle.ID, Bookie.ID, Odds.Odds,
        CASE WHEN ( Odds.OddsType IN ("opening", "single") ) THEN 1 ELSE 0 END AS IsOpening,
        CASE WHEN ( Odds.OddsType IN ("closing", "single") ) THEN 1 ELSE 0 END AS IsClosing
    FROM 
        raw_Odds AS Odds 
        INNER JOIN helper_Info AS Info
            ON (
                Info.HomeName = Odds.HomeTeamName 
                AND Info.AwayName = Odds.AwayTeamName
                AND Info.HomeScore = Odds.HomeScore
                AND Info.AwayScore = Odds.AwayScore
                AND (Info.Date1 = Odds.Date OR Info.Date2 = Odds.Date OR Info.Date3 = Odds.Date)
			)
        INNER JOIN xyz_TeamBundle AS Bundle
            ON (
                (Bundle.Name = Odds.HomeTeamName AND IsHomeTeam = 1)
                OR (Bundle.Name = Odds.AwayTeamName AND IsHomeTeam = 0)
			)
        INNER JOIN xyz_Bookie AS Bookie
            ON Bookie.Name = Odds.Bookmaker
    WHERE
        Odds.GameType = "Regular"
        AND Odds.IsActivated = 1;
-- // ODDS

-- // PLAYER
CREATE TABLE "xyz_Player" (
	"ID" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL UNIQUE, 
	"FirstName" VARCHAR NOT NULL,
	"LastName" VARCHAR NOT NULL,
	"FullName" VARCHAR NOT NULL);
CREATE TABLE IF NOT EXISTS "helper_Positions" (
	"ID" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL UNIQUE, 
	"Position" INTEGER NOT NULL);
CREATE TRIGGER "helper_Positions_initialization_trigger" AFTER INSERT ON helper_Positions
    WHEN NEW.Position < 100 BEGIN
        INSERT INTO helper_Positions ("Position") VALUES (NEW.Position + 1);
	END;
PRAGMA RECURSIVE_TRIGGERS = 1;
INSERT INTO helper_Positions ("Position") VALUES (1);

CREATE VIEW helper_DistinctNames AS
	SELECT 
		CASE WHEN (substr(PlayerName, length(PlayerName)-3, 4) IN  (" - F", " - G", " - C")) 
			THEN substr(PlayerName, 1, length(PlayerName)-4) ELSE PlayerName END
		AS Name
	FROM
		raw_PlayerScores
	UNION SELECT 
		CASE WHEN (substr(PlayerName, length(PlayerName)-3, 4) IN  (" - F", " - G", " - C")) 
			THEN substr(PlayerName, 1, length(PlayerName)-4) ELSE PlayerName END
		AS Name
	FROM
		raw_PlayersNotPlayed
	ORDER BY Name;

INSERT INTO "xyz_Player" (
		FirstName, LastName, FullName)
	SELECT
			substr(Name, 1, Position - 1) AS FirstName,
			substr(Name, Position + 1) AS LastName,
			Name
		FROM (
			SELECT
				DistinctNames.Name,
				Positions.Position
			FROM 
				helper_DistinctNames AS DistinctNames
				INNER JOIN helper_Positions AS Positions
			WHERE 
				substr(DistinctNames.Name, Positions.Position, 1) = " "
				AND Positions.position = (
					SELECT 
						MIN(Positions2.Position) 
					FROM 
						helper_DistinctNames AS DistinctNames2
						INNER JOIN helper_Positions AS Positions2
					WHERE
						substr(DistinctNames2.Name, Positions2.Position, 1) = " "
						AND DistinctNames2.Name = DistinctNames.Name
				)
			GROUP BY 
				DistinctNames.Name
		)
		UNION SELECT 
				DISTINCT PlayerName, PlayerName, PlayerName 
			FROM raw_PlayerScores 
			WHERE PlayerName NOT LIKE "% %"
		ORDER BY LastName;
-- // PLAYER

-- Name updates
UPDATE xyz_Player
SET FirstName = "Jose Juan", LastName = "Barea"
WHERE FullName = "Jose Juan Barea";

UPDATE xyz_Player
SET FirstName = "Juan Carlos", LastName = "Navarro"
WHERE FullName = "Juan Carlos Navarro";

UPDATE xyz_Player
SET FirstName = "Roko Leni", LastName = "Ukic"
WHERE FullName = "Roko Leni Ukic";
-- // Name updates

-- TEAMPLAYER
CREATE TABLE "xyz_TeamPlayer" (
	"ID" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL UNIQUE, 
	"TeamID" INTEGER NOT NULL,
	"PlayerID" INTEGER NOT NULL);
INSERT INTO "xyz_TeamPlayer" (
		TeamID, PlayerID)
	SELECT
		xyz_Team.ID, 
		xyz_Player.ID
	FROM
		raw_PlayerScores
		INNER JOIN xyz_Team ON raw_PlayerScores.TeamName = xyz_Team.Name
		INNER JOIN xyz_Player ON xyz_Player.FullName = 
			CASE WHEN (substr(PlayerName, length(PlayerName)-3, 4) IN  (" - F", " - G", " - C")) 
				THEN substr(PlayerName, 1, length(PlayerName)-4) ELSE PlayerName END
	UNION SELECT
		xyz_Team.ID,
		xyz_Player.ID
	FROM
		raw_PlayersNotPlayed
		INNER JOIN xyz_Team ON raw_PlayersNotPlayed.TeamName = xyz_Team.Name
		INNER JOIN xyz_Player ON xyz_Player.FullName = raw_PlayersNotPlayed.PlayerName;
-- // TEAMPLAYER

-- PLAYERSCORES
CREATE TABLE "xyz_PlayerScores" (
	"ID" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL UNIQUE,
	"TeamPlayerID" INTEGER NOT NULL,
	"MatchID" INTEGER NOT NULL, 
	"StartRange" INTEGER NOT NULL,
	"EndRange" INTEGER NOT NULL,
	"StartingPosition" INTEGER NOT NULL,
	"SecondsPlayed" INTEGER NOT NULL,
	"FGM" INTEGER NOT NULL, 
	"FGA" INTEGER NOT NULL, 
	"3FGM" INTEGER NOT NULL, 
	"3FGA" INTEGER NOT NULL, 
	"FTM" INTEGER NOT NULL, 
	"FTA" INTEGER NOT NULL, 
	"OREB" INTEGER NOT NULL, 
	"DREB" INTEGER NOT NULL, 
	"AST" INTEGER NOT NULL, 
	"TOV" INTEGER NOT NULL, 
	"STL" INTEGER NOT NULL, 
	"BLK" INTEGER NOT NULL, 
	"PF" INTEGER NOT NULL, 
	"PTS" INTEGER NOT NULL,
	"PlusMinus" INTEGER NOT NULL);
INSERT INTO xyz_PlayerScores (
		"TeamPlayerID", "MatchID", "StartRange", "EndRange", "StartingPosition", "SecondsPlayed",
		"FGM", "FGA", "3FGM", "3FGA", "FTM", "FTA", "OREB", "DREB", "AST", "TOV", "STL", "BLK", "PF", "PTS", "PlusMinus") 
	SELECT
		xyz_TeamPlayer.ID,
		raw_PlayerScores.MatchID,
		raw_PlayerScores.StartRange,
		raw_PlayerScores.EndRange/10,
		(CASE WHEN (substr(PlayerName, length(PlayerName)-3, 4) IN  (" - F", " - G", " - C")) 
			THEN substr(PlayerName, length(PlayerName), length(PlayerName)) ELSE "B" END) AS Position,
		(CASE WHEN MIN = "" THEN -1 ELSE (
				CASE WHEN length(MIN) = 4 THEN substr(MIN, 1, 1)*60 + substr(MIN, 3, 2) ELSE substr(MIN, 1, 2)*60 + substr(MIN, 4, 2) END)
			END) AS Minutes,
		"FGM", "FGA", "3FGM", "3FGA", "FTM", "FTA", "OREB", "DREB", "AST", "TOV", "STL", "BLK", "PF", "PTS", "PlusMinus"
	FROM
		raw_PlayerScores
		INNER JOIN xyz_Team ON xyz_Team.Name = raw_PlayerScores.TeamName
		INNER JOIN xyz_Player ON xyz_Player.FullName = 
			CASE WHEN (substr(PlayerName, length(PlayerName)-3, 4) IN  (" - F", " - G", " - C")) 
				THEN substr(PlayerName, 1, length(PlayerName)-4) ELSE PlayerName END
		INNER JOIN xyz_TeamPlayer ON xyz_TeamPlayer.TeamID = xyz_Team.ID AND xyz_Player.ID = xyz_TeamPlayer.PlayerID;
-- // PLAYERSCORES	

-- PLAYERSNOTPLAYED
CREATE TABLE "xyz_PlayersNotPlayed" (
	"ID" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL UNIQUE,
	"TeamPlayerID" INTEGER NOT NULL,
	"MatchID" INTEGER NOT NULL, 
	"Reason" VARCHAR);
INSERT INTO xyz_PlayersNotPlayed (
		"TeamPlayerID", "MatchID", "Reason")
	SELECT
		xyz_TeamPlayer.ID,
		raw_PlayersNotPlayed.MatchID,
		raw_PlayersNotPlayed.Reason
	FROM
		raw_PlayersNotPlayed
		INNER JOIN xyz_Team ON xyz_Team.Name = raw_PlayersNotPlayed.TeamName
		INNER JOIN xyz_Player ON xyz_Player.FullName = raw_PlayersNotPlayed.PlayerName
		INNER JOIN xyz_TeamPlayer ON xyz_TeamPlayer.TeamID = xyz_Team.ID AND xyz_Player.ID = xyz_TeamPlayer.PlayerID;
-- // PLAYERSNOTPLAYED

-- Helper for Python
CREATE TABLE helper_TeamPlayerInfo AS
	SELECT 
        raw_PlayerScores.MatchID AS MatchID,
		xyz_Team.ID AS TeamID,
		xyz_Team.Name AS Team,
		xyz_TeamPlayer.ID AS TeamPlayerID,
		xyz_Player.FirstName AS PlayerFirstName,
		xyz_Player.LastName AS PlayerLastName,
		(CASE WHEN (substr(PlayerName, length(PlayerName)-3, 4) IN  (" - F", " - G", " - C")) 
			THEN substr(PlayerName, length(PlayerName), length(PlayerName)) ELSE "B" END) AS PlayerPosition
	FROM 
		raw_PlayerScores
		INNER JOIN xyz_Player ON xyz_Player.FullName =  (CASE WHEN (substr(PlayerName, length(PlayerName)-3, 4) IN  (" - F", " - G", " - C")) 
			THEN substr(PlayerName, 1, length(PlayerName)-4) ELSE PlayerName END)
		INNER JOIN xyz_Team ON xyz_Team.Name = raw_PlayerScores.TeamName
		INNER JOIN xyz_TeamPlayer ON (xyz_TeamPlayer.PlayerID = xyz_Player.ID AND xyz_TeamPlayer.TeamID = xyz_Team.ID);
INSERT INTO helper_TeamPlayerInfo (MatchID, TeamID, Team, TeamPlayerID, PlayerFirstName, PlayerLastName, PlayerPosition)
    VALUES (20700880, 6, "Toronto Raptors", 3952, "Primoz", "Brezec", "B")
-- // Helper for Python

-- LINEUP
CREATE TABLE "xyz_Lineup" (
	"ID" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL UNIQUE, 
	"TeamID" INTEGER NOT NULL,
	"Lineup" VARCHAR NOT NULL UNIQUE);
INSERT INTO "xyz_Lineup" (
		TeamID, Lineup)
	SELECT DISTINCT
			xyz_Team.ID, 
			raw_LineupScores.Lineup
		FROM
			raw_LineupScores
			INNER JOIN xyz_Team ON raw_LineupScores.TeamName = xyz_Team.Name;
-- // LINEUP

-- LINEUPPLAYER (use Python to fill)
CREATE TABLE "xyz_LineupPlayer" (
	"ID" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL UNIQUE, 
	"LineupID" INTEGER NOT NULL,
	"TeamPlayerID" INTEGER NOT NULL);
-- // LINEUPPLAYER

-- MATCHLINEUP
CREATE TABLE "xyz_MatchLineup" (
	"ID" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL UNIQUE, 
	"MatchID" INTEGER NOT NULL,
	"LineupID" INTEGER NOT NULL);
INSERT INTO xyz_MatchLineup (
		MatchID, LineupID)
	SELECT
		xyz_Match.ID,
		xyz_Lineup.ID
	FROM
		raw_LineupScores
		INNER JOIN xyz_Match ON xyz_Match.ID = raw_LineupScores.MatchID
		INNER JOIN xyz_Lineup ON xyz_Lineup.Lineup = raw_LineupScores.Lineup
		INNER JOIN xyz_Team AS LineupTeam ON LineupTeam.Name = raw_LineupScores.TeamName
	WHERE
		xyz_Lineup.TeamID = LineupTeam.ID;
-- // MATCHLINEUP

-- MATCHRESULTS
CREATE VIEW xyz_MatchResults AS
	SELECT 
		xyz_Match.ID, 
		xyz_Season.Name AS Season,
		xyz_Match.Date,
		HomeBundle.ID AS HomeTeam, 
		AwayBundle.ID AS AwayTeam, 
		(HomeScores.PTS >= AwayScores.PTS) AS Winner
	FROM xyz_Match
		INNER JOIN xyz_Scores AS HomeScores ON (xyz_Match.ID = HomeScores.MatchID AND xyz_Match.HomeTeamID = HomeScores.TeamID)
		INNER JOIN xyz_Team AS HomeTeam ON HomeTeam.ID = HomeScores.TeamID
		INNER JOIN xyz_TeamBundle AS HomeBundle ON HomeBundle.ID = HomeTeam.TeamBundleID
		INNER JOIN xyz_Scores AS AwayScores ON (xyz_Match.ID = AwayScores.MatchID AND xyz_Match.AwayTeamID = AwayScores.TeamID)
		INNER JOIN xyz_Team AS AwayTeam ON AwayTeam.ID = AwayScores.TeamID
		INNER JOIN xyz_TeamBundle AS AwayBundle ON AwayBundle.ID = AwayTeam.TeamBundleID
		INNER JOIN xyz_Season ON xyz_Season.ID = xyz_Match.SeasonID
	ORDER BY
		xyz_Match.ID ASC;
-- // MATCHRESULTS

-- BESTCLOSINGODDS
CREATE VIEW xyz_BestClosingOdds AS
   SELECT 
        xyz_Odds.MatchID, 
        xyz_Odds.TeamBundleID, 
        xyz_Odds.BookieID,
        MAX(xyz_Odds.Odds) AS Odds
    FROM 
        xyz_Odds
    WHERE 
        xyz_Odds.IsClosing = 1 
        AND xyz_Odds.Odds <> ""
		AND xyz_Odds.BookieID IN (2, 5, 6, 7, 10)
    GROUP BY 
        xyz_Odds.MatchID, 
        xyz_Odds.TeamBundleID
-- // BESTCLOSINGODDS

-- SUBMATCHES
CREATE VIEW xyz_Submatches AS
    SELECT 
        ResultsA.ID AS MatchID,
        ResultsA.HomeTeam AS TeamA,
        ResultsA.AwayTeam AS TeamB,
        ResultsB.ID AS SubmatchID,
        ResultsB.Winner AS Winner
    FROM
        xyz_MatchResults AS ResultsA
        INNER JOIN xyz_MatchResults AS ResultsB 
            ON (TeamA = ResultsB.HomeTeam AND TeamB = ResultsB.AwayTeam AND datetime(ResultsA.Date) > datetime(ResultsB.Date))
    UNION SELECT 
        ResultsA.ID AS MatchID,
        ResultsA.AwayTeam AS TeamA,
        ResultsA.HomeTeam AS TeamB,
        ResultsB.ID AS SubmatchID,
        1 - ResultsB.Winner AS Winner
    FROM
        xyz_MatchResults AS ResultsA
        INNER JOIN xyz_MatchResults AS ResultsB 
            ON (TeamB = ResultsB.AwayTeam AND TeamA = ResultsB.HomeTeam AND datetime(ResultsA.Date) > datetime(ResultsB.Date))
    ORDER BY MatchID DESC;
-- // SUBMATCHES

-- SUBMATCHESBYFIELD
CREATE VIEW xyz_SubmatchesByField AS
    SELECT 
        ResultsA.ID AS MatchID,
        ResultsA.HomeTeam AS TeamA,
        ResultsA.AwayTeam AS TeamB,
        ResultsB.ID AS SubmatchID,
        ResultsB.Winner AS Winner
    FROM
        xyz_MatchResults AS ResultsA
        INNER JOIN xyz_MatchResults AS ResultsB 
            ON (TeamA = ResultsB.HomeTeam AND TeamB = ResultsB.AwayTeam AND datetime(ResultsA.Date) > datetime(ResultsB.Date))
    ORDER BY MatchID DESC;
-- // SUBMATCHESBYFIELD

-- EVENT
CREATE TABLE "xyz_Event" (
	"ID" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL UNIQUE,
	"Name" VARCHAR NOT NULL);
INSERT INTO xyz_Event ("Name") VALUES ("Foul");
INSERT INTO xyz_Event ("Name") VALUES ("Rebound");
INSERT INTO xyz_Event ("Name") VALUES ("Turnover");
INSERT INTO xyz_Event ("Name") VALUES ("Steal");
INSERT INTO xyz_Event ("Name") VALUES ("Block");
INSERT INTO xyz_Event ("Name") VALUES ("Goaltending");
INSERT INTO xyz_Event ("Name") VALUES ("Shot");
INSERT INTO xyz_Event ("Name") VALUES ("3PT");
INSERT INTO xyz_Event ("Name") VALUES ("Dunk");
INSERT INTO xyz_Event ("Name") VALUES ("Layup");
INSERT INTO xyz_Event ("Name") VALUES ("Free Throw");
INSERT INTO xyz_Event ("Name") VALUES ("Miss");
INSERT INTO xyz_Event ("Name") VALUES ("Sub");
INSERT INTO xyz_Event ("Name") VALUES ("Jump ball");
INSERT INTO xyz_Event ("Name") VALUES ("Timeout");
INSERT INTO xyz_Event ("Name") VALUES ("Support Ruling");
INSERT INTO xyz_Event ("Name") VALUES ("Start");
INSERT INTO xyz_Event ("Name") VALUES ("End");
-- // EVENT

-- PLAYEVENT
CREATE TABLE "xyz_PlayEvent" (
	"ID" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL UNIQUE,
	"PlayByPlayID" INTEGER NOT NULL,
	"EventID" INTEGER NOT NULL,
    "HomeLineupID" INTEGER NOT NULL,
    "AwayLineupID" INTEGER NOT NULL,
	"InvolvedTeamID" INTEGER,
	"InvolvedTeamPlayerID" INTEGER,
	"Info" VARCHAR,
	"ShotInfo" VARCHAR);
-- // PLAYEVENT

-- LINEUPPLAYERINFO
CREATE TABLE helper_LineupPlayerInfo AS
	SELECT 
        helper_LineupData.MatchID AS MatchID,
        helper_LineupData.Period AS Period,
		xyz_Team.ID AS TeamID,
		xyz_Team.Name AS Team,
		xyz_TeamPlayer.ID AS TeamPlayerID,
		xyz_Player.FirstName AS PlayerFirstName,
		xyz_Player.LastName AS PlayerLastName
	FROM 
		helper_LineupData
		INNER JOIN xyz_Player ON xyz_Player.FullName =  (CASE WHEN (substr(PlayerName, length(PlayerName)-3, 4) IN  (" - F", " - G", " - C")) 
			THEN substr(PlayerName, 1, length(PlayerName)-4) ELSE PlayerName END)
		INNER JOIN xyz_Team ON xyz_Team.Name = helper_LineupData.TeamName
		INNER JOIN xyz_TeamPlayer ON (xyz_TeamPlayer.PlayerID = xyz_Player.ID AND xyz_TeamPlayer.TeamID = xyz_Team.ID);
-- // LINEUPPLAYERINFO

-- INDEXES
CREATE INDEX "Index_Scores_MatchID" ON "xyz_Scores" ("MatchID" DESC);
CREATE INDEX "Index_LineupPlayer_TeamPlayerID" ON "xyz_LineupPlayer" ("TeamPlayerID" ASC);
CREATE INDEX "Index_PlayEvent_AwayLineupID" ON "xyz_PlayEvent" ("AwayLineupID" ASC);
CREATE INDEX "Index_PlayEvent_HomeLineupID" ON "xyz_PlayEvent" ("HomeLineupID" ASC);
CREATE INDEX "Index_PlayEvent_PlayByPlayID" ON "xyz_PlayEvent" ("PlayByPlayID" ASC);
CREATE INDEX "Index_PlayerScores_TeamPlayerID" ON "xyz_PlayerScores" ("TeamPlayerID" ASC);
-- // INDEXES
