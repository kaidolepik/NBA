
import re
import sys
from MatchData import Lineup

class Processor:
    
    def __init__(self, logger):
        self.events = {"Foul": 1, "Rebound" : 2, "Turnover" : 3, "Steal" : 4, "Block" : 5, "Goaltending" : 6, "Shot" : 7, 
                       "3PT" : 8, "Dunk" : 9, "Layup" : 10, "Free Throw" : 11, "Miss" : 12, "Sub" : 13,"Jump Ball" : 14, 
                       "Timeout" : 15, "Support Ruling" : 16, "Start of" : 17, "End of" : 18, "Violation" : 19, "Ast" : 20, "Jumper" : 21}
        self.logger = logger
        
    def set_match(self, match_id, home_team, away_team):
        self.match_id = match_id
        self.home_team = home_team
        self.away_team = away_team
    
    def process(self, play):
        if (play["eventID"] == -1):
            return self.process_neutral(play["Neutral"], play["ID"])
        else:
            home_events = [event for event in self.events.keys() if event.lower() in play["HomeEvent"].lower()]
            away_events = [event for event in self.events.keys() if event.lower() in play["AwayEvent"].lower()]
            home_event_data = self.process_not_neutral(self.home_team, home_events, play["HomeEvent"], play["ID"])
            away_event_data = self.process_not_neutral(self.away_team, away_events, play["AwayEvent"], play["ID"])
            
            return home_event_data + away_event_data
            
    def process_neutral(self, event_text, play_id):
        relevant_events = [event for event in self.events.keys() if event.lower() in event_text.lower()]
        
        play_data = []
        for event in relevant_events:
            play_data.append(self.aggregate_neutral_data(play_id, event))
            
        return play_data
        
    def process_not_neutral(self, team, play_events, event_text, play_id):
        play_data = []
        
        for event in play_events:
            event_lower_case = event.lower()
            if event_lower_case == "sub":
                play_data.extend(self.sub(team, event_text, play_id))
            elif event_lower_case == "jump ball":
                play_data.extend(self.jump_ball(event_text, play_id))
            elif event_lower_case == "miss":
                play_data.extend(self.miss(team, event_text, play_id))
            elif event_lower_case == "steal":
                play_data.extend(self.steal(team, event_text, play_id))
            elif event_lower_case == "rebound":
                play_data.extend(self.rebound(team, event_text, play_id))
            elif event_lower_case == "foul":
                play_data.extend(self.foul(team, event_text, play_id))
            elif event_lower_case == "turnover":
                play_data.extend(self.turnover(team, event_text, play_id))
            elif event_lower_case == "block":
                play_data.extend(self.block(team, event_text, play_id))
            elif event_lower_case == "goaltending":
                play_data.extend(self.goaltending(team, event_text, play_id))
            elif event_lower_case == "timeout":
                play_data.extend(self.timeout(team, event_text, play_id))
            elif event_lower_case == "violation":
                play_data.extend(self.violation(team, event_text, play_id))
            elif event_lower_case == "ast":
                play_data.extend(self.assist(team, event_text, play_id))
            elif event_lower_case == "free throw":
                play_data.extend(self.free_throw(team, event_text, play_id))
            elif event_lower_case == "layup":
                play_data.extend(self.layup(team, event_text, play_id))
            elif event_lower_case == "dunk":
                play_data.extend(self.dunk(team, event_text, play_id))
            elif event_lower_case == "3pt":
                play_data.extend(self.threePT(team, event_text, play_id))
            elif event_lower_case == "shot":
                play_data.extend(self.shot(team, event_text, play_id))
            elif event_lower_case == "jumper":
                play_data.extend(self.jumper(team, event_text, play_id))
        if "turnaround fadeaway" in event_text.lower():
            play_data.extend(self.turnaround_fadeaway(team, event_text, play_id))
        
        return play_data

    def sub(self, team, play_text, play_id):
        in_search_text = "SUB: (.*) FOR "
        out_search_text = " FOR (.*)$"
        
        in_event_data = self.extract_event_data_without_info(play_id, team, in_search_text, play_text, "Sub", info_text = "IN")
        out_event_data = self.extract_event_data_without_info(play_id, team, out_search_text, play_text, "Sub", info_text = "OUT")
        
        in_player = team.get_player_by_id(in_event_data[0][5])
        out_player = team.get_player_by_id(out_event_data[0][5])
        
        lineup = Lineup(team.get_next_lineup_id(), team.team_id)
        for player in team.active_lineup.players:
            if player != out_player:
                lineup.add_player(player, "U")
                
        if len(lineup.players) >= 5:
            #team.set_name_as_team_player_in_active_lineup(self.extract_name_from_event(" FOR (.*)$", play_text))
            lineup.change_name_to_player(self.extract_name_from_event(" FOR (.*)$", play_text), team.team_as_player)
            lineup2 = lineup
            lineup = Lineup(team.get_next_lineup_id(), team.team_id)
            for player in lineup2.players:
                if player != out_player:
                    lineup.add_player(player, "U")
            if len(lineup.players) > 5:
                print "Lineup is too big!"
                sys.exit(0)
                
        lineup.add_player(in_player, "U")
        while len(lineup.players) < 5:
            lineup.add_player(team.team_as_player, "All")
        team.update_lineups(lineup)
        
        for in_event in in_event_data:
            in_event[2] = self.home_team.active_lineup.lineup_id
            in_event[3] = self.away_team.active_lineup.lineup_id
        
        return in_event_data + out_event_data
    
    def jump_ball(self, play_text, play_id):
        if "Violation" in play_text:
            return []
        
        home_jumper_text = "Jump Ball (.*) vs."
        away_jumper_text = " vs. (.*): Tip to"
        catcher_text = ": Tip to (.*)$"
        
        event_data = (self.extract_event_data_without_info(play_id, self.home_team, home_jumper_text, play_text, "Jump Ball", "Jumper") + 
                      self.extract_event_data_without_info(play_id, self.away_team, away_jumper_text, play_text, "Jump Ball", "Jumper") +
                      self.extract_event_data_without_info(play_id, self.home_team, catcher_text, play_text, "Jump Ball", "Catcher") + 
                      self.extract_event_data_without_info(play_id, self.away_team, catcher_text, play_text, "Jump Ball", "Catcher"))
        
        return event_data
        
    def steal(self, team, play_text, play_id):
        search_text = "(.*) STEAL"
        
        return self.extract_event_data_without_info(play_id, team, search_text, play_text, "Steal", info_text = "")
    
    def rebound(self, team, play_text, play_id):
        players = team.get_players_by_name(self.extract_name_from_event("(.*) R[Ee][Bb][Oo][Uu][Nn][Dd]", play_text), "Rebound")
        
        event_data = []
        rebound_type = "Team"
        
        if len(players) == 1 and players[0].player_id == -1:
            event_data.append(self.aggregate_not_neutral_data(play_id, team, players[0], "Rebound", rebound_type))
        else:
            off_def = re.findall(".*REBOUND \(Off:(\d\d?) Def:(\d\d?)\)", play_text)[0]
            for player in players:
                if int(off_def[0]) == player.offensive_rebounds+1 and int(off_def[1]) == player.defensive_rebounds:
                    player.offensive_rebounds += 1
                    rebound_type = "Off"
                elif int(off_def[1]) == player.defensive_rebounds+1 and int(off_def[0]) == player.offensive_rebounds:
                    player.defensive_rebounds += 1
                    rebound_type = "Def"
                else:
                    rebound_type = "Error"
                    self.logger.error("REBOUND count doesn't match! " + play_text + " " + str(play_id) + " " + team.name)
                event_data.append(self.aggregate_not_neutral_data(play_id, team, player, "Rebound", rebound_type))
            
        return event_data
    
    def foul(self, team, play_text, play_id):
        search_text = ("(.*) (\S*)\.F[Oo][Uu][Ll](\S*)?" if ".foul" in play_text.lower() else
                       "(.*(?<!Personal)(?<!Take)(?<!Block)(?<!Shooting)(?<!Offensive)(?<!Charge)) (.*\w)? ?Foul ?(Turnover)?")
        
        return self.extract_event_data_with_info(play_id, team, search_text, play_text, "Foul")
    
    def turnover(self, team, play_text, play_id):
        search_text = ("([^\d]*(?<!Bad)(?<!Pass)(?<!Poss)(?<!Lost)(?<!Ball)(?<!Kicked)(?<!Out)(?<!of)(?<!Of)(?<!Bounds)(?<!Foul)(?<!Palming)"
                       "(?<!Violation)(?<!Traveling)(?<!Step)(?<!Offensive)(?<!Goaltending)(?<!Illegal)(?<!Assist)(?<!Lane))(?<!Backcourt)"
                       "(?<!Inbound)(?<!Illegal)(?<!Screen)(?<!Discontinue)(?<!Dribble)(?<!No)(?<!Double)(?<!Personal)(?<!Swinging)(?<!Elbows)(?<!Unknown)"
                       "(?<!Jump)(?<!Opposite)(?<!Basket)(?<!Punched)(?<!from)(?<!Below) (.*\S)? ?Turnover:? ?(Shot Clock|Backcourt|\d Second Violation|.*Goaltending)?.*")
        
        return self.extract_event_data_with_info(play_id, team, search_text, play_text, "Turnover")
    
    def block(self, team, play_text, play_id):
        if "BLOCK" not in play_text:
            return []
        
        search_text = "(.*) BLOCK"
        
        return self.extract_event_data_without_info(play_id, team, search_text, play_text, "Block")
    
    def goaltending(self, team, play_text, play_id):
        info_text = "Offensive Turnover" if " Offensive " in play_text else "Defensive Violation"
        search_text = "([^:]*):? \S+ Goaltending.*"
            
        return self.extract_event_data_without_info(play_id, team, search_text, play_text, "Goaltending", info_text)
    
    def timeout(self, team, play_text, play_id):
        search_text = "(.*) Timeout: ?(\S*).*"
        
        return self.extract_event_data_with_info(play_id, team, search_text, play_text, "Timeout")
    
    def violation(self, team, play_text, play_id):
        search_text = ("([^\d]*) Violation: ?(.*)" if "violation:" in play_text.lower() else
                       "([^\d]*(?<!Kicked)(?<!Jump)(?<!Ball)(?<!Turnover:)) (.*) Violation( Turnover)?.*")
        
        return self.extract_event_data_with_info(play_id, team, search_text, play_text, "Violation")
    
    def assist(self, team, play_text, play_id):
        if "Baston" in play_text:
            return []
        
        search_text = ".* \(([^\d]*) \d\d? AST\)"
        
        return self.extract_event_data_without_info(play_id, team, search_text, play_text, "Ast")
    
    def free_throw(self, team, play_text, play_id):
        search_text = ("MISS " if "MISS" in play_text else "") + "(.*) Free Throw ([^\(\)]*\w).*"
        
        return self.extract_event_data_with_info(play_id, team, search_text, play_text, "Free Throw")
    
    def layup(self, team, play_text, play_id):
        search_text = (("MISS " if "MISS" in play_text else "") + "([^\d]*(?<!Finger)(?<!Roll)(?<!Putback)"
                       "(?<!Alley)(?<!Oop)(?<!Driving)(?<!Reverse)(?<!Running)) (.*\S| ?) ?Layup.*")
        
        return self.extract_event_data_with_info(play_id, team, search_text, play_text, "Layup")
    
    def dunk(self, team, play_text, play_id):
        search_text = (("MISS " if "MISS" in play_text else "") + "([^\d]*(?<!Driving)(?<!Alley)(?<!Oop)"
                       "(?<!Slam)(?<!Putback)(?<!Reverse)(?<!Running)) (.*\S| ?) ?Dunk.*")
    
        return self.extract_event_data_with_info(play_id, team, search_text, play_text, "Dunk")
    
    def threePT(self, team, play_text, play_id):
        search_text = ("MISS " if "MISS" in play_text else "") + "([^\d]*) (\d\d?' )?3PT ([^\(\)]*\w).*"
    
        return self.extract_event_data_with_info(play_id, team, search_text, play_text, "3PT")
    
    def shot(self, team, play_text, play_id):
        if "Shot Clock" in play_text:
            return []
        
        search_text = (("MISS " if "MISS" in play_text else "") + "([^\d]*(?<!Floating)(?<!Turnaround)" + 
                       "(?<!Tip)(?<!Jump)(?<!Hook)(?<!Running)(?<!Bank)(?<!Driving)(?<!Pullup)(?<!Fadeaway)"
                       "(?<!Step)(?<!Back)) (.*\S)? ?Shot.*")
    
        return self.extract_event_data_with_info(play_id, team, search_text, play_text, "Shot")
    
    def miss(self, team, play_text, play_id):
        search_text = ("MISS ([^\d]*(?<!Driving)(?<!Reverse)(?<!Tip)(?<!Slam)(?<!Running)(?<!Putback)(?<!Alley)(?<!Oop)" + 
                       "(?<!Finger)(?<!Roll)(?<!Floating)(?<!Turnaround)(?<!Bank)(?<!Pullup)(?<!Fadeaway)(?<!Step)(?<!Back)" +
                       "(?<!Jump)(?<!Hook)) (\d+'.*|Free Throw.*|3PT.*|.*Layup|.*Shot|.*Dunk|.*Jumper)")
        
        return self.extract_event_data_with_info(play_id, team, search_text, play_text, "Miss")
    
    def jumper(self, team, play_text, play_id):
        search_text = (("MISS " if "MISS" in play_text else "") + "([^\d]*(?<!Fadeaway)) (.*\S)? ?Jumper.*")
    
        return self.extract_event_data_with_info(play_id, team, search_text, play_text, "Jumper")
    
    def turnaround_fadeaway(self, team, play_text, play_id):
        if "shot" in play_text.lower() or "MISS" in play_text:
            return []
        search_text = "([^\d]*) (\d\d?')? ?(3PT)? ?(Turnaround Fadeaway).*"
    
        return self.extract_event_data_with_info(play_id, team, search_text, play_text, event_key = "Shot")
        
        
        
        
    def aggregate_neutral_data(self, play_id, event_key, info = "Neutral"):
        playbyplay_id = play_id
        event_id = self.events[event_key]
        home_lineup_id = self.home_team.active_lineup.lineup_id
        away_lineup_id = self.away_team.active_lineup.lineup_id
        
        return [playbyplay_id, event_id, home_lineup_id, away_lineup_id, "", "", info]
            
    def aggregate_not_neutral_data(self, play_id, team, player, event_key, info):
        playbyplay_id = play_id
        event_id = self.events[event_key]
        home_lineup_id = self.home_team.active_lineup.lineup_id
        away_lineup_id = self.away_team.active_lineup.lineup_id
        involved_team_id = team.team_id
        involved_teamplayer_id = player.player_id if player.player_id != -1 else ""
        
        return [playbyplay_id, event_id, home_lineup_id, away_lineup_id, involved_team_id, involved_teamplayer_id, info]
    
    
    
    
    def extract_name_from_event(self, search_text, play_text):
        try:
            return re.findall(search_text, play_text)[0]
        except:
            self.logger.error("ERROR in name extraction: " + str(self.match_id) + " : " + search_text + " : " + play_text)
            return "Error"
        
    def extract_event_data_with_info(self, play_id, team, search_text, play_text, event_key):
        try:
            event_extracts = re.findall(search_text, play_text)
            if len(event_extracts) == 0 and event_key == "Free Throw":
                event_extracts = [[team.name]]
            players = team.get_players_by_name(event_extracts[0][0], event_key)
            info_text = "".join(event_extracts[0][1:])
            if len(players) == 0:
                players.append(team.team_as_player)
                info_text = play_text
                self.logger.info("NO player found in " + event_key + "! " + str(event_extracts[0]) + " " + team.name + " " + str(play_id))
        except:
            self.logger.error("ERROR in " + event_key + "! " + play_text + " " + " " + str(play_id) + " " + team.name + " " + str(self.match_id))
            return []
        
        return [self.aggregate_not_neutral_data(play_id, team, player, event_key, info_text) for player in players]
    
    def extract_event_data_without_info(self, play_id, team, search_text, play_text, event_key, info_text = ""):
        try:
            player_name = re.findall(search_text, play_text)
            if len(player_name) == 0 and event_key == "Steal":
                player_name = [team.name]
            players = team.get_players_by_name(player_name[0], event_key)
            if len(players) == 0:
                players.append(team.team_as_player)
                info_text = play_text
                if event_key != "Jump Ball":
                    self.logger.info("NO player found in " + event_key + "! " + str(player_name) + " " + team.name + " " + str(play_id))
        except:
            if event_key != "Jump Ball":
                self.logger.error("ERROR in " + event_key + "! " + play_text + " " + " " + str(play_id) + " " + team.name + " " + str(self.match_id))
            return []
        
        return [self.aggregate_not_neutral_data(play_id, team, player, event_key, info_text) for player in players]

