require 'sqlite3'

db = SQLite3::Database.new("databas.db")


def seed!(db)
  puts "Using db file: db/todos.db"
  puts "🧹 Dropping old tables..."
  drop_tables(db)
  puts "🧱 Creating tables..."
  create_tables(db)
  puts "🍎 Populating tables..."
  populate_tables(db)
  puts "✅ Done seeding the database!"
end

def drop_tables(db)
  db.execute('DROP TABLE IF EXISTS resor')
  db.execute('DROP TABLE IF EXISTS users')
end

def create_tables(db)
  db.execute('CREATE TABLE resor (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              name TEXT NOT NULL, 
              tags TEXT,
              owner INTEGER)')

   db.execute('CREATE TABLE users (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                u_name TEXT NOT NULL,
                pwd_digest TEXT NOT NULL
            )')
         
end

def populate_tables(db)
  db.execute('INSERT INTO resor (name, tags, owner) VALUES ("Camping", "skogen", 1)')

  
end


seed!(db)





