
class Team:
    
    def __init__(self, team_id, name):
        self.team_id = team_id
        self.name = name
        self.active_lineup = Lineup(str(team_id) + "0" + "1", self.team_id)
        self.lineups = [self.active_lineup]
        self.players = []
        self.team_as_player = Player(-1, self.name, self.name, "All")
        
    def add_player(self, player):
        self.players.append(player)
        if (player.starting_position != "B"):
            self.active_lineup.add_player(player, player.starting_position)
            
    def update_lineups(self, lineup):
        for existing_lineup in self.lineups:
            if existing_lineup.is_same_as(lineup):
                self.active_lineup = existing_lineup
                return
        self.active_lineup = lineup
        self.lineups.append(lineup)
            
    def get_players_by_name(self, name, event_key):
        name_list = name.split(". ")
        players = []
        
        for player in self.players:
            if (len(name_list) > 1 and player.last_name == name_list[1] and player.first_name.startswith(name_list[0]) 
            or len(name_list) == 1 and player.last_name == name_list[0]):
                players.append(player)
                
        if len(players) == 0:
            if len(name_list) == 1 and name_list[0].lower() in self.name.lower():
                #print "TEAM found as player in " + event_key + "! " + str(name_list) + " " + self.name
                players = [self.team_as_player]
            #else:
                #print "NO player found in " + event_key + "! " + str(name_list) + " " + self.name
        if len(players) > 1:
            #print "MORE than 1 player found in " + event_key + "! " + str(name_list) + " " + self.name
            players = [self.team_as_player]
            
        return players;
    
    def get_player_by_id(self, player_id):
        if player_id == "" or player_id == -1:
            return self.team_as_player
        
        for player in self.players:
            if player.player_id == player_id:
                return player
        
        return None;
    
    def set_name_as_team_player_in_active_lineup(self, name):
        self.active_lineup.change_name_to_player(name, self.team_as_player)
    
    def get_next_lineup_id(self):
        return str(self.team_id) + "0" + str(len(self.lineups) + 1)
    
    def get_non_existing_lineup_data(self):
        return [[lineup.lineup_id, self.team_id, lineup.get_lineup_code_string()] for lineup in self.lineups if not lineup.is_existing]
    
    def get_non_existing_lineup_player_data(self):
        return [lineup_player for lineup in self.lineups if not lineup.is_existing for lineup_player in lineup.get_lineup_player_data()]
            
    def __str__(self):
        output = ("Team name: " + str(self.name) + ", id: " + str(self.team_id) +
                  ", starting lineup: " + str(self.starting_lineup) + ", bench lineup: " + str(self.bench_lineup))
        
        return output
    
class Lineup:
    
    def __init__(self, lineup_id, team_id):
        self.lineup_id = lineup_id
        self.team_id = team_id
        self.players = []
        self.positions = []
        self.is_existing = False
        
    def add_player(self, player, position):
        self.players.append(player)
        self.positions.append(position)
        
    def is_same_as(self, lineup):
        if (len(self.players) != len(lineup.players)
            or self.teams_as_players_in_lineup() != lineup.teams_as_players_in_lineup()):
            return False
        for i in range(0, len(self.players)):
            if lineup.players[i] not in self.players:
                return False
        return True
    
    def teams_as_players_in_lineup(self):
        count = 0
        for player in self.players:
            if player.player_id == -1:
                count += 1
        return count
        
    def get_lineup_code_string(self):
        return " - ".join([player.get_code_string() for player in self.players])
    
    def get_lineup_player_data(self):
        return [[self.lineup_id, player.player_id] for player in self.players]
    
    def change_name_to_player(self, name, player):
        for i in range(len(self.players)):
            if self.players[i].last_name == name:
                self.players[i] = player
    
    def __str__(self):
        text = ""
        for player, position in zip(self.players, self.positions):
            text += " " + str(player) + ", " + str(position)
        return text

class Player:
    
    def __init__(self, player_id, first_name, last_name, position):
        self.player_id = player_id
        self.first_name = first_name
        self.starting_position = position
        self.offensive_rebounds = 0
        self.defensive_rebounds = 0
        if last_name == "Ayres":
            self.last_name = "Pendergraph"
        elif last_name == "Jianlian":
            self.last_name = "Yi"
        elif last_name == "Ming":
            self.last_name = "Yao"
        else:
            self.last_name = last_name
        
    def get_code_string(self):
        return self.last_name + "," + self.first_name
        
    def __str__(self):
        return str([self.player_id, self.first_name, self.last_name, self.starting_position])

