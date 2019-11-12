require 'sqlite3'


DB = {:conn => SQLite3::Database.new("db/songs.db")}
DB[:conn].execute("DROP TABLE IF EXISTS songs")

sql = <<-SQL
  CREATE TABLE IF NOT EXISTS songs (
  id INTEGER PRIMARY KEY,
  name TEXT,
  album TEXT
  )
SQL

DB[:conn].execute(sql)
DB[:conn].results_as_hash = true

#STEP ONE: Setting up our database
#creating the database 
#drops songs to avoid an error
#creating the songs table 
#results_as_hash: when a SELECT statement is executed, don't 
#return a database row as an array, return it as a hash with the column names as heys.
#instead of this: [[1, "Hello", "25"]]
#it returns this {"id"=>1, "name"=>"Hello", "album"=>"25", 0 => 1, 1 => "Hello", 2 => "25"}
