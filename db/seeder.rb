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
  db.execute('DROP TABLE IF EXISTS tags')
  db.execute('DROP TABLE IF EXISTS resor_users')
end

def create_tables(db)
  db.execute('CREATE TABLE resor (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              name TEXT NOT NULL, 
              description TEXT,
              owner INTEGER)')

  db.execute('CREATE TABLE users (
                u_id INTEGER PRIMARY KEY AUTOINCREMENT,
                u_name TEXT NOT NULL,
                pwd_digest TEXT NOT NULL,
                admin BOOLEAN
            )')

  db.execute('CREATE TABLE resor_users (
            id INTEGER,
            u_id INTEGER,
            PRIMARY KEY (id, u_id),

            FOREIGN KEY (id) REFERENCES resor(id)
                ON DELETE CASCADE,
            FOREIGN KEY (u_id) REFERENCES users(u_id)
                ON DELETE CASCADE
            
              )') 
end

def populate_tables(db)


  
end


seed!(db)





