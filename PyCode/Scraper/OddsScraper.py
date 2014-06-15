from selenium import webdriver
from selenium.webdriver.common.action_chains import ActionChains
import sqlite3
import time
import logging
import sys

class Game:
    
    def __init__(self, game_data):
        self.time = game_data[0].text
        self.teams = game_data[1].text.strip().split(" - ")
        self.scores = game_data[2].text.split(":")
        if (len(self.scores) > 1):
            self.scores[1] = self.scores[1].split(" OT")[0]
        else:
            self.scores.append(self.scores[0])
        self.date = game_data[3]
        self.type = game_data[4]
        self.url = game_data[1].find_element_by_tag_name("a").get_attribute("href")
        
    def get_attributes(self):
        return [self.type, self.date, self.time] + self.teams + self.scores

class OddsScraper:
    
    def __init__(self):
        self.connection = sqlite3.connect("DataNBA.sqlite")
        self.browser = webdriver.PhantomJS()
        
        self.logger = logging.getLogger("Logger")
        self.file_handler = logging.FileHandler("oddsLogs.log")
        self.formatter = logging.Formatter("%(asctime)s %(levelname)s %(message)s")
        self.file_handler.setFormatter(self.formatter)
        self.logger.addHandler(self.file_handler)
        self.logger.setLevel(logging.INFO)
        
    def destroy(self):
    	self.browser.close()
    	self.connection.close()
        
    def scrape_nba_odds(self, season, start_page, end_page):
        for page in range(start_page, end_page):
            start_time = time.time()
            try:
                self.logger.info("Scraping odds of season " + season + " from page " + str(page))
                url = self.create_odds_url(season, page)
                self.scrape_page_odds(url)
                self.logger.info("Scraped odds of season " + season + " from page " + str(page) + " in " + str(time.time()-start_time) + " seconds")
            except Exception, e:
                self.logger.error("Scraping odds failed: season = " + season + "; page = " + str(page) + "; " + str(e))
                self.destroy()
                sys.exit(0)
        
    def create_odds_url(self, season, page):
        url = "http://www.oddsportal.com/basketball/usa/nba-" + season + "/results/page/" + str(page) + "/"

        return url

    def scrape_page_odds(self, url):
        self.browser.get(url)
        
        page_odds = []
        games = []
        game_type = ""
        game_date = ""

        main_tbody = self.browser.find_element_by_xpath("//table[@id='tournamentTable']/tbody")
        trows = main_tbody.find_elements_by_xpath("tr[contains(@class, 'nob-border') or contains(@class, 'deactivate')]")
        
        for trow in trows:
            if ("nob-border" in trow.get_attribute("class")):
                header_text = trow.find_element_by_xpath("th[1]").text.split(" - ")
                game_date = header_text[0]
                game_type = header_text[1] if (len(header_text) > 1) else "Regular"
            else:
                game_data = trow.find_elements_by_xpath("td[position()<=3]")
                games.append(Game(game_data + [game_date, game_type]))
        
        for game in games:
            try:
                start_time = time.time()
                self.logger.info("Collecting odds of game " + str(game.teams) + " " + str(game.scores))
                game_odds = self.scrape_game_odds(game.url)
                self.logger.info("Collected odds of game " + str(game.teams) + " " + str(game.scores) + " in " + str(time.time()-start_time) + " seconds")
            except Exception, e:
                self.logger.error("Collecting odds of game failed: " + str(game.teams) + " " + str(game.scores) + " " + str(e))
                self.destroy()
                sys.exit(0)
            page_odds.extend([odds + game.get_attributes() for odds in game_odds])

        self.insert_odds(page_odds)
        
    def scrape_game_odds(self, url):
        self.browser.get(url)
        odds_rows = self.browser.find_elements_by_xpath("//div[@id='odds-data-table']/div[1]/table/tbody/tr")
        game_odds = []
        
        for odds_row in odds_rows:
            odds_datas = odds_row.find_elements_by_xpath("td[position()<=3]")
            
            bookie = odds_datas[0].find_element_by_xpath("div/a[@class='name']").text
            home_odds = self.scrape_bookies_odds(odds_datas[1])
            away_odds = self.scrape_bookies_odds(odds_datas[2])
            
            game_odds.extend([odds + [bookie, True] for odds in home_odds])
            game_odds.extend([odds + [bookie, False] for odds in away_odds])
        
        return game_odds
        
    def scrape_bookies_odds(self, odds_td):
        bookies_odds = []
        
        mouseover_element = odds_td.find_element_by_tag_name("div")
        is_activated = False if ("deactivateOdd" in mouseover_element.get_attribute("class")) else True

        td_class = odds_td.get_attribute("class")
        if ("up" in td_class or "down" in td_class):
            hover = ActionChains(self.browser).move_to_element(mouseover_element)
            hover.perform()
            odds_data = self.browser.find_elements_by_xpath("//body/div[@id='tooltipdiv']//span[@id='tooltiptext']/strong")
            
            closing_odds = [odds_data[0].text, "closing", is_activated]
            opening_odds = [odds_data[1].text, "opening", is_activated]
            
            bookies_odds.extend([closing_odds, opening_odds])
        else:
            bookies_odds.append([odds_td.text, "single", is_activated])
            
        return bookies_odds

    def insert_odds(self, data):
        try:
            cur = self.connection.cursor()
            cur.executemany("INSERT INTO Odds (Odds, OddsType, IsActivated, Bookmaker, IsHomeTeam, GameType, " + 
                            "Date, Time, HomeTeamName, AwayTeamName, HomeScore, AwayScore)" +
                            "VALUES (?,?,?,?,?,?,?,?,?,?,?,?)", data)
            self.connection.commit()
            cur.close()
        except Exception, e:
            self.logger.error("Insertion failed in odds: " + str(e))
            self.connection.rollback()
            self.destroy()
            sys.exit(0)
        

oddsScraper = OddsScraper()
#oddsScraper.scrape_nba_odds(sys.argv[1], int(sys.argv[2]), int(sys.argv[3]))
oddsScraper.destroy()

