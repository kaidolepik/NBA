#!/usr/bin/env python
# -*- coding: utf-8 -*- 

import sqlite3
import calendar

class MatchFiller:

    def __init__(self):
        self.connection = sqlite3.connect("DataNBA.sqlite")
        self.months = {v: k for k,v in enumerate(calendar.month_name)}
        
    def fill_matches(self):
        cur = self.connection.cursor()
        cur.execute("SELECT TS1.MatchID AS MatchID, TS1.DateInfo AS DateInfo, TS1.Periods AS Periods, " +
                        "TS1.TeamName AS HomeTeam, TS2.TeamName AS AwayTeam " +
                    "FROM raw_TeamScores AS TS1, raw_TeamScores AS TS2 " +
                    "WHERE TS1.IsHome =1 AND TS2.IsHome=0 AND TS1.MatchID = TS2.MatchID;")
        matches = []
        for row in cur:
            if (not self.do_teams_match(str(row[1]), str(row[3]), str(row[4]))):
                return
            match_ID = str(row[0])
            home_team_ID = self.get_team_ID(str(row[3]))
            away_team_ID = self.get_team_ID(str(row[4]))
            date = self.get_date(str(row[1]))
            periods = str(row[2])
            season_ID = self.get_season_ID(str(row[0]))
            
            matches.append([match_ID, season_ID, home_team_ID, away_team_ID, periods, date])
            
        cur.close()
        self.insert_matches(matches)
        
    def destroy(self):
        self.connection.close()
        
    def get_team_ID(self, team_name):
        cur = self.connection.cursor()
        cur.execute("SELECT ID FROM xyz_Team WHERE Name = (?);", [team_name])
        team_ID = cur.fetchone()[0]
        cur.close()
        
        return (team_ID)
    
    def get_date(self, dateinfo):
        datetext = dateinfo[str.index(dateinfo, "-") + 2:]
        dateparts = datetext.split(", ")
        month_day = dateparts[1].split(" ")
        
        year = dateparts[2]
        month = self.months[month_day[0]]
        day = month_day[1][:-2]
        
        return (str(year) + "-" + ("0" + str(month) if int(month) < 10 else str(month)) + "-" + ("0" + str(day) if int(day) < 10 else str(day)))

    def get_season_ID(self, match_ID):
        year = int(match_ID[1:3]) + 2000
        season_name = str(year) + "-" + str(year+1)[-2:]

        cur = self.connection.cursor()
        cur.execute("SELECT ID FROM xyz_Season WHERE Name = (?);", [season_name])
        season_ID = cur.fetchone()[0]
        cur.close()
        
        return (season_ID)
    
    def do_teams_match(self, dateinfo, home_team, away_team):
        extracted_away = dateinfo[:str.index(dateinfo, "@")-1]
        extracted_home = dateinfo[str.index(dateinfo, "@")+2 : str.index(dateinfo, "-")-1]
        if (extracted_home == home_team and extracted_away == away_team):
            return True
        return False
    
    def insert_matches(self, matches):
        cur = self.connection.cursor()
        cur.executemany("INSERT INTO xyz_Match (ID, SeasonID, HomeTeamID, AwayTeamID, Periods, Date) " + 
                            "VALUES (?,?,?,?,?,?);", (matches))
        self.connection.commit()
        cur.close()
    
matchFiller = MatchFiller()
#matchFiller.fill_matches()
matchFiller.destroy()

