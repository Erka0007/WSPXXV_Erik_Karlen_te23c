def data(route)
  db = SQLite3::Database.new(route)
  db.results_as_hash = true
  return db
end

def user_check(user)
  db = data("db/databas.db")
  return db.execute("SELECT * FROM users WHERE u_id=?", user)
end

def add_user(user,pwd)
  db = data("db/databas.db")
  pwd_digest=BCrypt::Password.create(pwd)
  
  if BCrypt::Password.new(pwd_digest) == "admin123"
      db.execute("INSERT INTO users (u_name, pwd_digest, admin) VALUES (?,?,?)",[user, pwd_digest, 1])
      admin = 1 
  else
      db.execute("INSERT INTO users (u_name, pwd_digest, admin) VALUES (?,?,?)",[user, pwd_digest, 0])
      admin = 0      
  end
  return [db.execute("SELECT u_id,pwd_digest FROM users WHERE u_name=?",user), admin]
end

def password_check(l_pwd,pwd_digest)
  if BCrypt::Password.new(pwd_digest) == l_pwd
    return true
  else 
    return false
  end
end

def find_person(user)
  db = data("db/databas.db")
  return db.execute("SELECT u_id,pwd_digest,admin FROM users WHERE u_name=?",user)
end


def get_data
  db = data("db/databas.db")
  return[db.execute("SELECT * FROM resor
  INNER JOIN users ON resor.owner = users.u_id"),db.execute("SELECT id, u_name FROM resor_users
  INNER JOIN users ON resor_users.u_id = users.u_id")]
end

def insert_resor(res_name, description, owner)
  db = data("db/databas.db")
  db.execute("INSERT INTO resor (name, description, owner) VALUES (?,?,?)",[res_name, description, owner])
end

def select(id)
  db = data("db/databas.db")
  return db.execute("SELECT * FROM resor WHERE id = ?", id).first
end

def updatera(name, description, id)
  db = data("db/databas.db")
  db.execute("UPDATE resor SET name=?, description=? WHERE id=?", [name, description, id])
end

def owner_check(resa)
  db = SQLite3::Database.new("db/databas.db")
  return db.execute("SELECT owner FROM resor WHERE id=?", resa).first[0]
end

def delete(resa)
  db = data("db/databas.db")
  db.execute("DELETE FROM resor WHERE id = ?", resa)
end

def delete_user(user)
  db = data("db/databas.db")
  db.execute("DELETE FROM users WHERE u_id = ?", user)
end

def edit_user(u_id, name, pwd)
  db = data("db/databas.db")
  pwd_digest=BCrypt::Password.create(pwd)
  db.execute("UPDATE users SET u_name=?, pwd_digest=? WHERE u_id=?", [name, pwd_digest, u_id])
end

def persons(resa)
  db = data("db/databas.db")
  return db.execute("SELECT id, u_name FROM resor_users
  INNER JOIN users ON resor_users.u_id = users.u_id WHERE id = ?", resa)
end

def verify(resa, user_join)
  db = data("db/databas.db")
  return db.execute("SELECT * FROM resor_users WHERE id = ? AND u_id = ?", [resa, user_join])
end

def insert_relation(resa, user_join)
  db = data("db/databas.db")
  db.execute("INSERT INTO resor_users (id, u_id) VALUES (?,?)",[resa, user_join])
end