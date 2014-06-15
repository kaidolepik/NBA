
getDatabase = function() {
    library(RSQLite)
    
    db = dbConnect(SQLite(), "DataNBA.sqlite")
    
    return (db)
}

closeDatabase = function(db) {
    dbDisconnect(db)
}
