#!/usr/bin/env python
# -*- coding: utf-8 -*- 

import re
import sys
import sqlite3
from MatchData import Team, Player, Lineup
from Processor import Processor
from DataModifier import DataModifier
import logging

class Simulator:
    
    def __init__(self):
        self.connection = sqlite3.connect("DataNBA.sqlite")
        self.connection.row_factory = sqlite3.Row
        
        self.logger = logging.getLogger("Logger")
        self.file_handler = logging.FileHandler("playbyplayLogs.log")
        self.formatter = logging.Formatter("%(asctime)s %(levelname)s %(message)s")
        self.file_handler.setFormatter(self.formatter)
        self.logger.addHandler(self.file_handler)
        self.logger.setLevel(logging.INFO)
        
        self.processor = Processor(self.logger)
        self.data_modifier = DataModifier(self.connection, self.logger)
        
    def destroy(self):
        self.connection.close()
        
    def initialize_simulation(self, match_id):
        self.period_time = 12*60
        self.period = 1
        self.initialize_teams(match_id)
        self.initialize_playbyplay(match_id)
        
    def initialize_teams(self, match_id):
        # "HomeTeamID", "HomeTeamName", "AwayTeamID", "AwayTeamName"
        teams = self.connection.cursor()
        teams.execute("SELECT HomeTeam.ID AS HomeTeamID, HomeTeam.Name AS HomeTeamName, " +
                        "AwayTeam.ID AS AwayTeamID, AwayTeam.Name AS AwayTeamName " +
                      "FROM xyz_Match " +
                        "INNER JOIN xyz_Team AS HomeTeam ON xyz_Match.HomeTeamID = HomeTeam.ID " +
                        "INNER JOIN xyz_Team AS AwayTeam ON xyz_Match.AwayTeamID = AwayTeam.ID " +
                      "WHERE xyz_Match.ID = (?);", [match_id])
        team_data = teams.fetchone()
        
        self.home_team = Team(team_data["HomeTeamID"], team_data["HomeTeamName"])
        self.away_team = Team(team_data["AwayTeamID"], team_data["AwayTeamName"])
        
        teams.close()
        self.initialize_team_player_info(match_id)
        
    def initialize_team_player_info(self, match_id):
        # "MatchID", "TeamID", "Team", "TeamPlayerID", "PlayerFirstName", "PlayerLastName", "PlayerPosition"
        team_player_info = self.connection.cursor()
        team_player_info.execute("SELECT * FROM helper_TeamPlayerInfo WHERE MatchID = (?);", [match_id])
        
        for row in team_player_info:
            player = Player(row["TeamPlayerID"], row["PlayerFirstName"], row["PlayerLastName"], row["PlayerPosition"])
            if (row["TeamID"] == self.home_team.team_id):
                self.home_team.add_player(player)
            elif (row["TeamID"] == self.away_team.team_id):
                self.away_team.add_player(player)
            else:
                print "TeamID doesn't match!"
                sys.exit(0)

        team_player_info.close()
        
    def initialize_playbyplay(self, match_id):
        # "ID", "MatchID", "Period", "HomeTeam", "AwayTeam", "HomeEvent", "AwayEvent", "EventID", "Time", "Score", "Neutral"
        playbyplay = self.connection.cursor()
        playbyplay.execute("SELECT * FROM raw_PlayByPlay WHERE MatchID = (?);", [match_id])
        
        self.playbyplay = playbyplay.fetchall()
        playbyplay.close()
        
    def initialize_period_starting_lineups(self, match_id, period):
        # "MatchID", "Period", "TeamID", "Team", "TeamPlayerID", "PlayerFirstName", "PlayerLastName"
        lineup_players = self.connection.cursor()
        lineup_players.execute("SELECT * FROM helper_LineupPlayerInfo WHERE MatchID = (?) AND Period = (?);", [match_id, period])
        
        home_lineup = Lineup(self.home_team.get_next_lineup_id(), self.home_team.team_id)
        away_lineup = Lineup(self.away_team.get_next_lineup_id(), self.away_team.team_id)
        for row in lineup_players:
            if (row["TeamID"] == self.home_team.team_id):
                home_lineup.add_player(self.home_team.get_player_by_id(row["TeamPlayerID"]), "U")
            elif (row["TeamID"] == self.away_team.team_id):
                away_lineup.add_player(self.away_team.get_player_by_id(row["TeamPlayerID"]), "U")
            else:
                print "TeamID doesn't match!"
                sys.exit(0)
        self.home_team.update_lineups(home_lineup)
        self.away_team.update_lineups(away_lineup)
        
        lineup_players.close()
        
    def simulate_match(self, match_id):
        self.initialize_simulation(match_id)
        self.processor.set_match(match_id, self.home_team, self.away_team)
        
        playbyplay_data = []
        play_events = []
        
        if len(self.playbyplay) == 0:
            print "Match " + str(match_id) + " doesn't exist!"
            return
        for play in self.playbyplay:
            if play["Period"] != self.period:
                self.period = play["Period"]
                self.period_time = 12*60 if self.period <= 4 else 5*60
                self.initialize_period_starting_lineups(match_id, self.period)
            event_clock = play["Time"].split(":")
            event_time = self.period_time - (int(event_clock[0])*60 + int(event_clock[1])) if len(event_clock) > 1 else 0
            self.period_time -= event_time
            
            playbyplay_data.append([play["ID"], play["MatchID"], play["Period"], self.period_time, event_time])
            play_events.extend(self.processor.process(play))
        # Correct the duration and end-time of the game's last possession
        playbyplay_data[-1][4] = playbyplay_data[-1][3]
        playbyplay_data[-1][3] = 0
        self.data_modifier.update_lineup_id_data(self.home_team.lineups, self.away_team.lineups, play_events, match_id)
        
        lineup_data = self.home_team.get_non_existing_lineup_data() + self.away_team.get_non_existing_lineup_data()
        match_lineup_data = [[match_id, lineup.lineup_id] for lineup in self.home_team.lineups + self.away_team.lineups if not lineup.is_existing]
        lineup_player_data = self.home_team.get_non_existing_lineup_player_data() + self.away_team.get_non_existing_lineup_player_data()
        
        self.insert(lineup_data, match_lineup_data, lineup_player_data, playbyplay_data, play_events)
        
        print "Inserted match " + str(match_id)
            
    def insert(self, lineups, match_lineups, lineup_players, playbyplay_data, play_events):
        cur = self.connection.cursor()
        
        cur.executemany("INSERT INTO xyz_Lineup (ID, TeamID, Lineup) VALUES (?,?,?);", (lineups))
        cur.executemany("INSERT INTO xyz_MatchLineup (MatchID, LineupID) VALUES (?,?);", (match_lineups))
        cur.executemany("INSERT INTO xyz_LineupPlayer (LineupID, TeamPlayerID) VALUES (?,?);", (lineup_players))
        cur.executemany("INSERT INTO xyz_PlayByPlay (ID, MatchID, Period, PeriodTimeLeft, PossessionTime) " +
                        "VALUES (?,?,?,?,?);", (playbyplay_data))
        cur.executemany("INSERT INTO xyz_PlayEvent (PlayByPlayID, EventID, HomeLineupID, AwayLineupID, InvolvedTeamID, " +
                        "InvolvedTeamPlayerID, Info) VALUES (?,?,?,?,?,?,?);", (play_events))
        
        self.connection.commit()
        cur.close()


simulator = Simulator()

#for match_id in range(21201230, 21201214, -1):
#    simulator.simulate_match(str(match_id))
#for match_id in range(21201213, 21200000, -1):
#    simulator.simulate_match(str(match_id))
#for match_id in range(21100990, 21100000, -1):
#    simulator.simulate_match(str(match_id))
#for match_id in range(21001230, 21000000, -1):
#    simulator.simulate_match(str(match_id))
#for match_id in range(20901230, 20900000, -1):
#    simulator.simulate_match(str(match_id))
#for match_id in range(20801230, 20800000, -1):
#    simulator.simulate_match(str(match_id))
#for match_id in range(20701230, 20700000, -1):
#    simulator.simulate_match(str(match_id))

simulator.destroy()
