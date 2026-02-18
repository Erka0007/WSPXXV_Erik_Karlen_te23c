require 'sinatra'
require 'slim'
require 'sqlite3'
require 'sinatra/reloader'
require 'bcrypt'

def data(route)
  db = SQLite3::Database.new(route)
  db.results_as_hash = true
  return db
end

get("/") do
  db = data("db/databas.db")
  @data = db.execute("SELECT * FROM resor")
  slim(:start)
end  
