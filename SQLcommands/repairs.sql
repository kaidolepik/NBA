
-- Some problems were logged in Python, correct them here

INSERT INTO helper_LineupData (MatchID, Period, TeamName, PlayerName,MIN) VALUES (21100542, 2, "Memphis Grizzlies", "Rudy Gay - F", "0:02");
INSERT INTO helper_LineupData (MatchID, Period, TeamName, PlayerName,MIN) VALUES (21100542, 2, "Memphis Grizzlies", "Marreese Speights - F", "0:02");
INSERT INTO helper_LineupData (MatchID, Period, TeamName, PlayerName,MIN) VALUES (21100542, 2, "Memphis Grizzlies", "Tony Allen - G", "0:02");
INSERT INTO helper_LineupData (MatchID, Period, TeamName, PlayerName,MIN) VALUES (21100542, 2, "Memphis Grizzlies", "O.J. Mayo", "0:02");
INSERT INTO helper_LineupData (MatchID, Period, TeamName, PlayerName,MIN) VALUES (21100542, 2, "Memphis Grizzlies", "Dante Cunningham", "0:02");

INSERT INTO helper_LineupData (MatchID, Period, TeamName, PlayerName,MIN) VALUES (21100542, 2, "Detroit Pistons", "Rodney Stuckey - G", "0:02");
INSERT INTO helper_LineupData (MatchID, Period, TeamName, PlayerName,MIN) VALUES (21100542, 2, "Detroit Pistons", "Jonas Jerebko", "0:02");
INSERT INTO helper_LineupData (MatchID, Period, TeamName, PlayerName,MIN) VALUES (21100542, 2, "Detroit Pistons", "Ben Gordon", "0:02");
INSERT INTO helper_LineupData (MatchID, Period, TeamName, PlayerName,MIN) VALUES (21100542, 2, "Detroit Pistons", "Damien Wilkins", "0:02");
INSERT INTO helper_LineupData (MatchID, Period, TeamName, PlayerName,MIN) VALUES (21100542, 2, "Detroit Pistons", "Ben Wallace", "0:02");


INSERT INTO helper_LineupData (MatchID, Period, TeamName, PlayerName,MIN) VALUES (21000238, 2, "Minnesota Timberwolves", "Darko Milicic - C", "0:02");
INSERT INTO helper_LineupData (MatchID, Period, TeamName, PlayerName,MIN) VALUES (21000238, 2, "Minnesota Timberwolves", "Wayne Ellington", "0:02");
INSERT INTO helper_LineupData (MatchID, Period, TeamName, PlayerName,MIN) VALUES (21000238, 2, "Minnesota Timberwolves", "Anthony Tolliver", "0:02");
INSERT INTO helper_LineupData (MatchID, Period, TeamName, PlayerName,MIN) VALUES (21000238, 2, "Minnesota Timberwolves", "Corey Brewer", "0:02");
INSERT INTO helper_LineupData (MatchID, Period, TeamName, PlayerName,MIN) VALUES (21000238, 2, "Minnesota Timberwolves", "Sebastian Telfair", "0:02");

INSERT INTO helper_LineupData (MatchID, Period, TeamName, PlayerName,MIN) VALUES (21000238, 2, "Golden State Warriors", "Dorell Wright - F", "0:02");
INSERT INTO helper_LineupData (MatchID, Period, TeamName, PlayerName,MIN) VALUES (21000238, 2, "Golden State Warriors", "David Lee - F", "0:02");
INSERT INTO helper_LineupData (MatchID, Period, TeamName, PlayerName,MIN) VALUES (21000238, 2, "Golden State Warriors", "Monta Ellis - G", "0:02");
INSERT INTO helper_LineupData (MatchID, Period, TeamName, PlayerName,MIN) VALUES (21000238, 2, "Golden State Warriors", "Reggie Williams", "0:02");
INSERT INTO helper_LineupData (MatchID, Period, TeamName, PlayerName,MIN) VALUES (21000238, 2, "Golden State Warriors", "Jeff Adrien", "0:02");


INSERT INTO helper_LineupData (MatchID, Period, TeamName, PlayerName,MIN) VALUES (20700880, 4, "Charlotte Bobcats", "Jason Richardson - F", "0:18");
INSERT INTO helper_LineupData (MatchID, Period, TeamName, PlayerName,MIN) VALUES (20700880, 4, "Charlotte Bobcats", "Nazr Mohammed - C", "0:18");
INSERT INTO helper_LineupData (MatchID, Period, TeamName, PlayerName,MIN) VALUES (20700880, 4, "Charlotte Bobcats", "Raymond Felton - G", "0:18");
INSERT INTO helper_LineupData (MatchID, Period, TeamName, PlayerName,MIN) VALUES (20700880, 4, "Charlotte Bobcats", "Jermareo Davidson", "0:18");
INSERT INTO helper_LineupData (MatchID, Period, TeamName, PlayerName,MIN) VALUES (20700880, 4, "Charlotte Bobcats", "Earl Boykins", "0:18");

INSERT INTO helper_LineupData (MatchID, Period, TeamName, PlayerName,MIN) VALUES (20700880, 4, "Toronto Raptors", "Anthony Parker - G", "0:18");
INSERT INTO helper_LineupData (MatchID, Period, TeamName, PlayerName,MIN) VALUES (20700880, 4, "Toronto Raptors", "T.J. Ford", "0:18");
INSERT INTO helper_LineupData (MatchID, Period, TeamName, PlayerName,MIN) VALUES (20700880, 4, "Toronto Raptors", "Carlos Delfino", "0:18");
INSERT INTO helper_LineupData (MatchID, Period, TeamName, PlayerName,MIN) VALUES (20700880, 4, "Toronto Raptors", "Jason Kapono", "0:18");
INSERT INTO helper_LineupData (MatchID, Period, TeamName, PlayerName,MIN) VALUES (20700880, 4, "Toronto Raptors", "Primoz Brezec", "0:18");


UPDATE xyz_LineupPlayer SET LineupID = 13123 WHERE LineupID = 23799;
UPDATE xyz_MatchLineup SET LineupID = 13123 WHERE LineupID = 23799;
DELETE FROM xyz_Lineup WHERE ID = 23799;

UPDATE xyz_LineupPlayer SET LineupID = 16352 WHERE LineupID = 25367;
UPDATE xyz_MatchLineup SET LineupID = 16352 WHERE LineupID = 25367;
DELETE FROM xyz_Lineup WHERE ID = 25367;

UPDATE xyz_LineupPlayer SET LineupID = 16555 WHERE LineupID = 22652;
UPDATE xyz_MatchLineup SET LineupID = 16555 WHERE LineupID = 22652;
DELETE FROM xyz_Lineup WHERE ID = 22652;

UPDATE xyz_LineupPlayer SET LineupID = 16560 WHERE LineupID = 28762;
UPDATE xyz_MatchLineup SET LineupID = 16560 WHERE LineupID = 28762;
DELETE FROM xyz_Lineup WHERE ID = 28762;

UPDATE xyz_LineupPlayer SET LineupID = 16558 WHERE LineupID = 23795;
UPDATE xyz_MatchLineup SET LineupID = 16558 WHERE LineupID = 23795;
DELETE FROM xyz_Lineup WHERE ID = 23795;

UPDATE xyz_LineupPlayer SET LineupID = 21024 WHERE LineupID = 31007;
UPDATE xyz_MatchLineup SET LineupID = 21024 WHERE LineupID = 31007;
DELETE FROM xyz_Lineup WHERE ID = 31007;

UPDATE xyz_LineupPlayer SET LineupID = 21110 WHERE LineupID = 31133;
UPDATE xyz_MatchLineup SET LineupID = 21110 WHERE LineupID = 31133;
DELETE FROM xyz_Lineup WHERE ID = 31133;

