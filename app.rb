require 'sinatra'
require 'slim'
require 'sqlite3'
require 'sinatra/reloader'
require 'bcrypt'
enable :sessions

def data(route)
  db = SQLite3::Database.new(route)
  db.results_as_hash = true
  return db
end

get("/") do
  db = data("db/databas.db")
  @data = db.execute("SELECT * FROM resor")
  slim(:user)
end  

post("/user") do
  user = params["user"]
  pwd = params["pwd"]
  pwd_confirm = params["pwd_confirm"]
  db = data("db/databas.db")
  result = db.execute("SELECT * FROM users WHERE id=?", user)

  if result.empty?
    if pwd==pwd_confirm
      pwd_digest=BCrypt::Password.create(pwd)
      db.execute("INSERT INTO users (u_name, pwd_digest) VALUES (?,?)",[user, pwd_digest])
      redirect('/welcome')
    else
      redirect('/error')
    end
  else
    redirect('/login')
  end
end

post("/login") do

  l_user = params["l_user"]
  l_pwd = params["l_pwd"]
  db = data("db/databas.db")
  result = db.execute("SELECT id,pwd_digest FROM users WHERE u_name=?",l_user)
  
  if result.empty?
    redirect('/error')
  end

  user_id = result.first["id"]
  pwd_digest = result.first["pwd_digest"]

  if BCrypt::Password.new(pwd_digest) == l_pwd
    session[:user_id] = user_id
    p "hej #{session[:user_id]}"
    redirect('/welcome')
  else
    redirect('/error')
  end
end

get("/welcome") do
  db = data("db/databas.db")
  @data = db.execute("SELECT * FROM resor
  INNER JOIN users ON resor.owner = users.id")
  p "hej #{session[:user_id]}"
  slim(:start)
end  


