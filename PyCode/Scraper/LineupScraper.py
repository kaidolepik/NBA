from selenium import webdriver
import sqlite3
import time
import logging
import sys

class LineupScraper:

    def __init__(self, table_name):
        self.connection = sqlite3.connect("DataNBA.sqlite")
        self.table_name = table_name
        self.browser = webdriver.PhantomJS()
        
        self.logger = logging.getLogger("Logger")
        self.file_handler = logging.FileHandler("lineupLogs.log")
        self.formatter = logging.Formatter("%(asctime)s %(levelname)s %(message)s")
        self.file_handler.setFormatter(self.formatter)
        self.logger.addHandler(self.file_handler)
        self.logger.setLevel(logging.INFO)
        
    def destroy(self):
    	self.browser.close()
    	self.connection.close()

    def find_matches_with_too_big_lineups(self):
        cur = self.connection.cursor()
        cur.execute("SELECT "
                        "T.MatchID "
                    "FROM ("
                        "SELECT MatchID, COUNT(*) AS C FROM raw_LineupData_1 GROUP BY MatchID, Period, TeamName HAVING C > 5 "
                        "UNION SELECT MatchID, COUNT(*) AS C FROM raw_LineupData_2 GROUP BY MatchID, Period, TeamName HAVING C > 5 "
                        "UNION SELECT MatchID, COUNT(*) AS C FROM raw_LineupData_3 GROUP BY MatchID, Period, TeamName HAVING C > 5"
                        ") AS T "
                    "WHERE NOT EXISTS (SELECT * FROM raw_LineupData_4 WHERE raw_LineupData_4.MatchID = T.MatchID)")
        
        match_ids = cur.fetchall()
        cur.close()
        
        return match_ids


    def scrape_nba_lineups(self, start_id, end_id):
        for game_id in range(end_id, start_id, -1):
            nba_game_id = "00" + str(game_id)
            start_time = time.time()
            try:
                self.logger.info("Scraping lineup of game " + nba_game_id)
                self.scrape_lineup(nba_game_id)
                self.logger.info("Scraped lineup of game " + nba_game_id + " in " + str(time.time()-start_time) + " seconds")
            except Exception, e:
                self.logger.error("Scraping lineup failed, GameID = " + nba_game_id + "; " + str(e))
                self.destroy()
                sys.exit(0)

    def create_lineup_url(self, game_id, start_range, end_range):
        url = ("http://stats.nba.com/gameDetail.html?GameID=" + game_id + 
               "&tabView=boxscore&StartRange=" + start_range + "&EndRange=" + end_range + "&RangeType=2")

        return url

    def scrape_lineup(self, game_id):
        url = self.create_lineup_url(game_id, "7201", "7301")
        self.browser.get(url)
        data = []

        overtimes = len(self.browser.find_elements_by_xpath("//li[@class='ot' and @style]"))
        time_periods = [12, 12, 12, 12] + [5]*overtimes
        
        for i in range(1, len(time_periods)):
            start_range = sum(time_periods[:i])*60*10 + 1
            end_range = start_range + 200
            count = 0
            while count < 10:
                if not (count == 0 and i == 1):
                    url = self.create_lineup_url(game_id, str(start_range), str(end_range))
                    self.browser.get(url)
                
                scores_section = self.browser.find_element_by_id("gridSection")
                home_player_scores = scores_section.find_elements_by_xpath("//table[@id='gameDetailBoxscoreHomeGridContainer']/tbody/tr[position()>1]")
                away_player_scores = scores_section.find_elements_by_xpath("//table[@id='gameDetailBoxscoreVisitGridContainer']/tbody/tr[position()>1]")
                
                if (len(home_player_scores) >= 5 and len(away_player_scores) >= 5):
                    home_team = self.browser.find_element_by_id("homeTeamTitle").text
                    away_team = self.browser.find_element_by_id("visitTeamTitle").text
                    collected_home_scores = self.collect_scores(home_player_scores)
                    collected_away_scores = self.collect_scores(away_player_scores)
                    data.extend([[game_id, i+1, home_team] + home_data for home_data in collected_home_scores])
                    data.extend([[game_id, i+1, away_team] + away_data for away_data in collected_away_scores])
                    break
                else:
                    count += 1
                    end_range += 20
            if count == 10:
                self.logger.error("Scraping lineup of game " + str(game_id) + " from period " + str(i+1) + " unsuccessfully!")
                    
        self.insert_data(data)
        
    def collect_scores(self, trows):
        collected_scores = []
        
        for trow in trows:
            tdatas = trow.find_elements_by_xpath("td[position() <= 2]")
            collected_scores.append([tdata.text for tdata in tdatas])
        
        return collected_scores
    
    def insert_data(self, data):
        try:
        	cur = self.connection.cursor()
            cur.executemany("INSERT INTO " + self.table_name + " (MatchID, Period, TeamName, PlayerName, MIN) " +
            				"VALUES (?,?,?,?,?)", data)
            self.connection.commit()
            cur.close()
        except Exception, e:
            self.logger.error("Insertion failed: " + str(e))
            self.connection.rollback()
            self.destroy()
            sys.exit(0)
        

#lineupScraper = LineupScraper(sys.argv[1])
#lineupScraper.scrape_nba_lineups(int(sys.argv[2]), int(sys.argv[3]))
#lineupScraper.destroy()

#lineupScraper = LineupScraper("raw_LineupData_tmp")
#data = lineupScraper.find_matches_with_too_big_lineups()
#for match_id in data:
#    m_id = match_id[0]
#    lineupScraper.scrape_nba_lineups(m_id-1, m_id)
#lineupScraper.destroy()

