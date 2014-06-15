
class DataModifier:
    
    def __init__(self, connection, logger):
        self.connection = connection
        self.logger = logger
    
    def update_lineup_id_data(self, home_lineups, away_lineups, play_events, match_id):
        cur = self.connection.cursor()
        cur.execute("SELECT xyz_Lineup.ID FROM xyz_Lineup ORDER BY xyz_Lineup.ID DESC LIMIT 1;")
        last_lineup_id = cur.fetchone()
        if last_lineup_id is None:
            last_lineup_id = 0
        else:
            last_lineup_id = last_lineup_id["ID"]
        cur.close()
        
        lineup_id_changes = {}
        
        for lineup in home_lineups + away_lineups:
            existing_lineup_ids = self.get_existing_lineup_ids(lineup)
            
            if len(existing_lineup_ids) > 1:
                self.logger.info("TOO many lineups found: " + str(existing_lineup_ids) + ", match id: " + str(match_id))
                lineup.is_existing = True
                lineup_id_changes[lineup.lineup_id] = existing_lineup_ids[0]
            elif len(existing_lineup_ids) == 0:
                last_lineup_id += 1
                lineup_id_changes[lineup.lineup_id] = last_lineup_id
            else:
                lineup.is_existing = True
                lineup_id_changes[lineup.lineup_id] = existing_lineup_ids[0]
            
            lineup.lineup_id = lineup_id_changes[lineup.lineup_id]
                
        for play_event in play_events:
            play_event[2] = lineup_id_changes[play_event[2]]
            play_event[3] = lineup_id_changes[play_event[3]]
            
    def get_existing_lineup_ids(self, lineup):
        where_conditions = []
        
        team_player_count = 0
        for player in lineup.players:
            condition = " xyz_Lineup.Lineup LIKE \"%" + player.last_name + "," + player.first_name + "%"
            if player.player_id == -1:
                team_player_count += 1
                condition_count = 1
                while (condition_count < team_player_count):
                    condition += player.last_name + "," + player.first_name + "%"
                    condition_count += 1
            condition += "\" "
            where_conditions.append(condition)
        where_conditions.append(" LENGTH(xyz_Lineup.Lineup) - LENGTH(REPLACE(xyz_Lineup.Lineup, '-', '')) = " + str(len(lineup.players) - 1))
        
        cur = self.connection.cursor()
        cur.execute("SELECT xyz_Lineup.ID FROM xyz_Lineup WHERE TeamID = (?) AND" + "AND".join(where_conditions), [lineup.team_id])
        existing_lineup_ids = [row["ID"] for row in cur.fetchall()]
        cur.close()
        
        return existing_lineup_ids

