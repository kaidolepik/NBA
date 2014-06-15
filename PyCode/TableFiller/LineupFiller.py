#!/usr/bin/env python
# -*- coding: utf-8 -*- 

import sqlite3

class LineupFiller:

    def __init__(self):
        self.connection = sqlite3.connect("DataNBA.sqlite")
        
    def fill_lineups(self):
        cur = self.connection.cursor()
        cur.execute("SELECT ID, TeamID, Lineup FROM xyz_Lineup;")
        
        lineup_dict = self.build_lineup_dict()
        counter = 0
        lineup_players = []
        for row in cur:
            players = self.parse_players(row[2], row[1])
            for player in players:
                lineup_players.append([row[0], lineup_dict[player]])
                
            counter += 1
            if (counter % 100 == 0):
                print counter
                
        cur.close()
        self.insert_lineup_players(lineup_players)
        
    def destroy(self):
        self.connection.close()
    
    def build_lineup_dict(self):
        cur = self.connection.cursor()
        cur.execute("SELECT xyz_TeamPlayer.ID, xyz_TeamPlayer.TeamID, xyz_Player.FullName " +
                    "FROM xyz_TeamPlayer INNER JOIN xyz_Player ON xyz_Player.ID = xyz_TeamPlayer.PlayerID;")
        
        lineup_dict = {}
        for row in cur:
            lineup_dict[str(row[2]) + " ; " + str(row[1])] = row[0]
            
        cur.close()
        return lineup_dict
    
    def parse_players(self, lineup, teamID):
        players = []
        
        for player in lineup.split(" - "):
            full_name = " ".join(player.split(",")[::-1])
            if (full_name == "Jeff Pendergraph"):
                full_name = "Jeff Ayres"
            if (full_name == "Nene Hilario"):
                full_name = "Nene"
            if (full_name == "J.J. Hickson"):
                full_name = "JJ Hickson"
            if (full_name == "Christapher Johnson"):
                full_name = "Chris Johnson"
            if (full_name == "Patrick Beverly"):
                full_name = "Patrick Beverley"
            if (full_name == "John Lucas"):
                full_name = "John Lucas III"
            if (full_name == "Jianlian Yi"):
                full_name = "Yi Jianlian"
            if (full_name == "Bill Walker"):
                full_name = "Henry Walker"
            if (full_name == "Hamady N'Diaye"):
                full_name = "Hamady Ndiaye"
            if (full_name == "Ming Yao"):
                full_name = "Yao Ming"
            if (full_name == "Marcus E. Williams"):
                full_name = "Marcus Williams"
            if (full_name == "Daniel Brown"):
                full_name = "Dee Brown"
            players.append(full_name + " ; " + str(teamID))
    
        return players
    
    def insert_lineup_players(self, lineup_players):
        cur = self.connection.cursor()
        cur.executemany("INSERT INTO xyz_LineupPlayer (LineupID, TeamPlayerID) " + 
                            "VALUES (?,?);", (lineup_players))
        self.connection.commit()
        cur.close()
    
lineupFiller = LineupFiller()
#lineupFiller.fill_lineups()
lineupFiller.destroy()

