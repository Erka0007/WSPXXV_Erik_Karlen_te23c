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
  result = db.execute("SELECT * FROM users WHERE u_id=?", user)

  if result.empty?
    if pwd==pwd_confirm
      pwd_digest=BCrypt::Password.create(pwd)
      db.execute("INSERT INTO users (u_name, pwd_digest) VALUES (?,?)",[user, pwd_digest])

      result2 = db.execute("SELECT u_id,pwd_digest FROM users WHERE u_name=?",user)
  
      if result2.empty?
        redirect('/error')
      end
      user_id = result2.first["u_id"]
      session[:user_id] = user_id      
    
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
  result = db.execute("SELECT u_id,pwd_digest FROM users WHERE u_name=?",l_user)
  
  if result.empty?
    redirect('/error')
  end

  user_id = result.first["u_id"]
  pwd_digest = result.first["pwd_digest"]

  if BCrypt::Password.new(pwd_digest) == l_pwd
    p "test #{user_id}"
    session[:user_id] = user_id
    p "login #{session[:user_id]}"
    redirect('/welcome')
  else
    redirect('/error')
  end
end

get("/welcome") do
  db = data("db/databas.db")
  @data = db.execute("SELECT * FROM resor
  INNER JOIN users ON resor.owner = users.u_id")
  @persons = db.execute("SELECT resor.id, users.u_id FROM resor_users")
  @owner = session[:user_id]
  p "hej #{session[:user_id]}"
  slim(:start)
end  

post("/resor/new") do
  res_name = params[:res_name] # Hämta datan ifrån formuläret
  tag = params[:tag]
  owner = session[:user_id]
  db = data("db/databas.db")
  db.execute("INSERT INTO resor (name, tags, owner) VALUES (?,?,?)",[res_name, tag, owner])
  redirect('/welcome') # Hoppa till routen som visar upp alla frukter
 
end

get("/resor/:id/edit") do
  id = params[:id].to_i
  db = data("db/databas.db")
  @selected_resor = db.execute("SELECT * FROM resor WHERE id = ?", id).first
  slim(:"resor/edit")

end

post("/resor/:id/update") do
  db = data("db/databas.db")
  id = params[:id].to_i
  name = params[:name]
  tags = params[:tags]
  db.execute("UPDATE resor SET name=?, tags=? WHERE id=?", [name, tags, id])
  redirect("/welcome")
end

post("/resor/:id/delete") do
  db = data("db/databas.db")
  denna_ska_bort = params[:id].to_i
  db.execute("DELETE FROM resor WHERE id = ?", denna_ska_bort)
  redirect('/welcome')
end

get("/resor/:id/join") do
  db = data("db/databas.db")
  resa = params[:id].to_i
  user_join = session[:user_id]
  db.execute("INSERT INTO resor_users (id, u_id) VALUES (?,?)",[resa, user_join])
  redirect('/welcome')
end