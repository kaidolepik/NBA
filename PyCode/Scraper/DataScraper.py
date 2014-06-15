from selenium import webdriver
import sqlite3
import time
import logging
import sys

class DataScraper:

    def __init__(self):
        self.connection = sqlite3.connect("DataNBA.sqlite")
        self.cursor = self.connection.cursor()
        self.browser = webdriver.PhantomJS()
        
        self.logger = logging.getLogger("Logger")
        self.file_handler = logging.FileHandler("logs.log")
        self.formatter = logging.Formatter("%(asctime)s %(levelname)s %(message)s")
        self.file_handler.setFormatter(self.formatter)
        self.logger.addHandler(self.file_handler)
        self.logger.setLevel(logging.INFO)
        
    def destroy(self):
    	self.browser.close()
    	self.cursor.close()
    	self.connection.close()

    def scrape_nba_playbyplay(self, start_id, end_id):
        for game_id in range(end_id, start_id, -1):
            nba_game_id = "00" + str(game_id)
            start_time = time.time()
            try:
                self.logger.info("Scraping playbyplay of game " + nba_game_id)
                self.scrape_playbyplay(nba_game_id)
                self.logger.info("Scraped playbyplay of game " + nba_game_id + " in " + str(time.time()-start_time) + " seconds")
            except Exception, e:
                self.logger.error("Scraping playbyplay failed, GameID = " + nba_game_id + "; " + str(e))
                self.destroy()
                sys.exit(0)

    def scrape_nba_boxscores(self, start_id, end_id):
        for game_id in range(end_id, start_id, -1):
            nba_game_id = "00" + str(game_id)
            start_time = time.time()
            try:
                self.logger.info("Scraping boxscores of game " + nba_game_id)
                self.scrape_boxscores(nba_game_id)
                self.logger.info("Scraped boxscores of game " + nba_game_id + " in " + str(time.time()-start_time) + " seconds")
            except Exception, e:
                self.logger.error("Scraping boxscores failed, GameID = " + nba_game_id + "; " + str(e))
                self.destroy()
                sys.exit(0)

    def create_playbyplay_url(self, game_id):
        url = "http://stats.nba.com/gameDetail.html?GameID=" + game_id + "&tabView=playbyplay"

        return url

    def scrape_playbyplay(self, game_id):
        url = self.create_playbyplay_url(game_id)
        self.browser.get(url)
        data = []

        period_tables = self.browser.find_elements_by_class_name("period-table")
        if (len(period_tables) == 0):
            self.logger.info("Couldn't find playbyplay period tables for GameID = " + game_id + "; Continuing with next game")
            return
        teams = self.find_teams(period_tables[0])
        for i in range(0, len(period_tables)):
            period = i + 1
            events = self.find_events(period_tables[i])
            data.append([[game_id, period]+teams, events])

        self.insert_playbyplay(data)

    def find_teams(self, first_period_table):
        theads = first_period_table.find_elements_by_xpath("thead/tr/th")

        home_team = theads[0].text
        away_team = theads[2].text

        return [home_team, away_team]

    def find_events(self, period_table):
        events = []
        
        try:
            trows = period_table.find_elements_by_xpath("tbody/tr")
            for trow in trows:
                home_event = ""
                away_event = ""
                event_id = -1
                time = ""
                score = ""
                neutral = ""
                
                tdatas = trow.find_elements_by_tag_name("td")
                for tdata in tdatas:
                    attribute_text = tdata.get_attribute("class")
                    if (attribute_text == "neutral"):
                        neutral = tdata.text
                    elif (attribute_text == "gametime"):
                        divs = tdata.find_elements_by_tag_name("div")
                        time = divs[0].text
                        score = divs[1].text if len(divs) >= 2 else ""
                    else:
                        event_text = tdata.text
                        if (event_text != ""):
                            if (attribute_text == "htm"):
                                home_event = event_text
                            elif (attribute_text == "vtm"):
                                away_event = event_text
                            ahref = tdata.find_element_by_tag_name("a").get_attribute("href")
                            event_id = ahref.split("GameEventID=")[1]
                events.append([home_event, away_event, event_id, time, score, neutral])
        except Exception, e:
            self.logger.error("Scraping event failed: " + [home_event, away_event, event_id, time, score, neutral] + "; " + str(e))
            self.destroy()
            sys.exit(0)

        return events
                
    def insert_playbyplay(self, data):
        try:
            for period_table in data:
                events = period_table[1]
                for event in events:
                    data_row = period_table[0] + event
                    self.cursor.execute("INSERT INTO raw_PlayByPlay (MatchID, Period, HomeTeam, " +
                                        "AwayTeam, HomeEvent, AwayEvent, EventID, Time, Score, Neutral)" +
                                        "VALUES (?,?,?,?,?,?,?,?,?,?)", data_row)
            self.connection.commit()
        except Exception, e:
            self.logger.error("Insertion failed in PlayByPlay: " + str(e))
            self.connection.rollback()
            self.destroy()
            sys.exit(0)
            
    def create_team_scores_url(self, game_id):
        url = "http://stats.nba.com/gameDetail.html?GameID=" + game_id + "&tabView=boxscore"

        return url
            
    def create_player_scores_url(self, game_id, start_range, end_range):
        url = self.create_team_scores_url(game_id) + "&StartRange=" + str(start_range) + "&EndRange=" + str(end_range) + "&RangeType=2"

        return url

    def scrape_boxscores(self, game_id):
        team_data = []
        url = self.create_team_scores_url(game_id)
        self.browser.get(url)
        
        home_team = self.browser.find_element_by_id("homeTeamTitle").text
        away_team = self.browser.find_element_by_id("visitTeamTitle").text
        date_info = self.browser.find_element_by_id("matchup-header").text
        overtimes = len(self.browser.find_elements_by_xpath("//li[@class='ot' and @style]"))
        time_periods = [12, 12, 12, 7, 5] + [5]*overtimes
        
        scores_section = self.browser.find_element_by_id("gridSection")
        home_stats = scores_section.find_elements_by_xpath("//table[@id='gameDetailBoxscoreHomeGridContainer']/tr[@class]")
        away_stats = scores_section.find_elements_by_xpath("//table[@id='gameDetailBoxscoreVisitGridContainer']/tr[@class]")
        
        team_data.append([game_id, date_info, 4+overtimes, home_team, True] + home_stats[-1].text.split(" "))
        team_data.append([game_id, date_info, 4+overtimes, away_team, False] + away_stats[-1].text.split(" "))
        self.insert_team_scores(team_data)
        
        collected_home_not_played = self.collect_scores(home_team, home_stats[:-1])
        collected_away_not_played = self.collect_scores(away_team, away_stats[:-1])
        players_not_played = [[game_id, collected_home_not_played], [game_id, collected_away_not_played]]
        self.insert_players_not_played(players_not_played)
        
        self.scrape_player_scores(game_id, time_periods, date_info, home_team, away_team)
        
        home_link = self.browser.find_element_by_xpath("//div[@id='main-details']/div[starts-with(@class, 'team htm')]//h4[@class='lineups']/a").get_attribute("href")
        away_link = self.browser.find_element_by_xpath("//div[@id='main-details']/div[starts-with(@class, 'team vtm')]//h4[@class='lineups']/a").get_attribute("href")
        self.scrape_lineups(game_id, home_team, home_link)
        self.scrape_lineups(game_id, away_team, away_link)
        
    def scrape_player_scores(self, game_id, time_periods, date_info, home_team, away_team):
        player_data = []
        start_range = 0
        end_range = sum(time_periods)*60*10
        
        scores_section = self.browser.find_element_by_id("gridSection")
        home_player_scores = scores_section.find_elements_by_xpath("//table[@id='gameDetailBoxscoreHomeGridContainer']/tbody/tr[position()>1]")
        away_player_scores = scores_section.find_elements_by_xpath("//table[@id='gameDetailBoxscoreVisitGridContainer']/tbody/tr[position()>1]")
        collected_home_scores = self.collect_scores(home_team, home_player_scores)
        collected_away_scores = self.collect_scores(away_team, away_player_scores)
        player_data.append([[game_id, date_info, start_range, end_range], collected_home_scores+collected_away_scores])
        
        self.insert_player_scores(player_data)
        
    def scrape_lineups(self, game_id, team, team_link):
        if (team_link != "#"):
            self.browser.get(team_link)
            team_lineup_scores = self.browser.find_elements_by_xpath("//table[@id='teamLineUpsGridContainer']/tbody/tr[position()>1]")
            collected_lineup_scores = self.collect_scores(team, team_lineup_scores)
            self.insert_lineup_scores([game_id, collected_lineup_scores])
            
    def collect_scores(self, team, trows):
        collected_scores = []
        
        for trow in trows:
            collected_score = [team]
            tdatas = trow.find_elements_by_tag_name("td")
            for tdata in tdatas:
                collected_score.append(tdata.text)
            collected_scores.append(collected_score)
        
        return collected_scores

    def insert_team_scores(self, data):
        try:
            for data_row in data:
                self.cursor.execute("INSERT INTO raw_TeamScores (MatchID, DateInfo, Periods, TeamName, IsHome, Totals, " +
                                    "MIN, FGM, FGA, 'FG%', '3FGM', '3FGA', '3FG%', FTM, FTA, 'FT%', OREB, DREB, REB, AST, TOV, " +
                                    "STL, BLK, PF, PTS, PlusMinus) " +
                                    "VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)", data_row)
            self.connection.commit()
        except Exception, e:
            self.logger.error("Insertion failed in TeamScores: " + str(e))
            self.connection.rollback()
            self.destroy()
            sys.exit(0)
    
    def insert_player_scores(self, data):
        try:
            for period_data in data:
                scores = period_data[1]
                for player_scores in scores:
                    data_row = period_data[0] + player_scores
                    self.cursor.execute("INSERT INTO raw_PlayerScores (MatchID, DateInfo, StartRange, EndRange, TeamName, PlayerName, " +
                                        "MIN, FGM, FGA, 'FG%', '3FGM', '3FGA', '3FG%', FTM, FTA, 'FT%', OREB, DREB, REB, AST, TOV, " +
                                        "STL, BLK, PF, PTS, PlusMinus) " +
                                        "VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)", data_row)
            self.connection.commit()
        except Exception, e:
            self.logger.error("Insertion failed in PlayerScores: " + str(e))
            self.connection.rollback()
            self.destroy()
            sys.exit(0)
            
    def insert_players_not_played(self, data):
        try:
            for team_data in data:
                players_not_played = team_data[1]
                for player_data in players_not_played:
                    data_row = [team_data[0]] + player_data
                    self.cursor.execute("INSERT INTO raw_PlayersNotPlayed (MatchID, TeamName, PlayerName, Reason) " +
                                        "VALUES (?,?,?,?)", data_row)
            self.connection.commit()
        except Exception, e:
            self.logger.error("Insertion failed in PlayersNotPlayed: " + str(e))
            self.connection.rollback()
            sys.exit(0)

    def insert_lineup_scores(self, data):
        try:
            for lineup_data in data[1]:
                data_row = [data[0]] + lineup_data
                self.cursor.execute("INSERT INTO raw_LineupScores (MatchID, TeamName, Lineup, GP, MIN, FGM, FGA, 'FG%', '3FGM', '3FGA', " +
                                    "'3FG%', FTM, FTA, 'FT%', OREB, DREB, REB, AST, TOV, STL, BLK, BLKA, PF, PFD, PTS, PlusMinus) " +
                                    "VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)", data_row)
            self.connection.commit()
        except Exception, e:
            self.logger.error("Insertion failed in LineupScores: " + str(e))
            self.connection.rollback()
            self.destroy()
            sys.exit(0)


scraper = DataScraper()

if (sys.argv[3] == "playbyplay"):
    scraper.scrape_nba_playbyplay(int(sys.argv[1]), int(sys.argv[2]))
elif (sys.argv[3] == "boxscores"):
    scraper.scrape_nba_boxscores(int(sys.argv[1]), int(sys.argv[2]))
    
scraper.destroy()

