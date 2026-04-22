
module Model

  # Attempts to get information from the database
  #
  # @params [String] route , the route to the database
  #
  # @return [Hash] infromation from database
  def data(route)
    db = SQLite3::Database.new(route)
    db.results_as_hash = true
    return db
  end

  # Attempts to get information from the database for a user
  #
  # @params [Integer] user, the users id
  #
  # @return [Hash] infromation from database
  def user_check(user)
    db = data("db/databas.db")
    return db.execute("SELECT * FROM users WHERE u_id=?", user)
  end

  # Attempts to add a user to the database
  #
  # @params [Integer] user, the users id
  # @params [String] pwd, the users password
  #
  # @return [Hash] infromation from database for the users id and admin status
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

  # Attempts to check a password
  #
  # @params [String] l_pwd, the users password
  # @params [String] pwd_digest, the users saved encrypted password
  #
  # @return [Bool] if the password was correct or not
  def password_check(l_pwd,pwd_digest)
    if BCrypt::Password.new(pwd_digest) == l_pwd
      return true
    else 
      return false
    end
  end

  # Attempts to find a person
  #
  # @params [String] user, the users name
  #
  # @return [Hash] the users data
  def find_person(user)
    db = data("db/databas.db")
    return db.execute("SELECT u_id,pwd_digest,admin FROM users WHERE u_name=?",user)
  end

  # Attempts to find all trip data
  #
  # @return [Hash] All trip data
  def get_data
    db = data("db/databas.db")
    return[db.execute("SELECT * FROM resor
    INNER JOIN users ON resor.owner = users.u_id"),db.execute("SELECT id, u_name FROM resor_users
    INNER JOIN users ON resor_users.u_id = users.u_id")]
  end

  # Attempts to insert a trip
  #
  # @params [String] res_name, the trips name
  # @params [String] description, the description
  # @params [Integer] owner, the users id
  #
  def insert_resor(res_name, description, owner)
    db = data("db/databas.db")
    db.execute("INSERT INTO resor (name, description, owner) VALUES (?,?,?)",[res_name, description, owner])
  end

  # Attempts to find a trip
  #
  # @params [Integer] id, the trips id
  #
  # @return [Hash] The trips data
  def select(id)
    db = data("db/databas.db")
    return db.execute("SELECT * FROM resor WHERE id = ?", id).first
  end

  # Attempts to update a trip
  #
  # @params [String] name, the trips new name
  # @params [String] description, the trips new description
  # @params [Integer] id, the trips id
  #
  def updatera(name, description, id)
    db = data("db/databas.db")
    db.execute("UPDATE resor SET name=?, description=? WHERE id=?", [name, description, id])
  end

  # Checks a trips owner
  #
  # @params [Integer] resa, the trips id
  #
  # @return [Integer] The id of the trips owner
  def owner_check(resa)
    db = SQLite3::Database.new("db/databas.db")
    return db.execute("SELECT owner FROM resor WHERE id=?", resa).first[0]
  end

  # Deletes a trip
  #
  # @params [Integer] resa, the trips id
  #
  def delete(resa)
    db = data("db/databas.db")
    db.execute("DELETE FROM resor WHERE id = ?", resa)
  end

  # Deletes a user
  #
  # @params [Integer] user, the users id
  #
  def delete_user(user)
    db = data("db/databas.db")
    db.execute("DELETE FROM users WHERE u_id = ?", user)
  end

  # Edit a user
  #
  # @params [Integer] u_id, the users id
  # @params [String] name, the users name
  # @params [String] pwd, the users password
  #
  def edit_user(u_id, name, pwd)
    db = data("db/databas.db")
    pwd_digest=BCrypt::Password.create(pwd)
    db.execute("UPDATE users SET u_name=?, pwd_digest=? WHERE u_id=?", [name, pwd_digest, u_id])
  end

  # Attempts to find the participants of a trip
  #
  # @params [Integer] id, the trips id
  #
  # @return [Hash] The trips data for participants
  def persons(resa)
    db = data("db/databas.db")
    return db.execute("SELECT id, u_name FROM resor_users
    INNER JOIN users ON resor_users.u_id = users.u_id WHERE id = ?", resa)
  end

  # Attempts to find information to later chekc if a person already has joined a trip
  #
  # @params [Integer] resa, the trips id
  # @params [Integer] user_join, the users id
  #
  # @return [Hash] The realtions tabels data for the user
  def verify(resa, user_join)
    db = data("db/databas.db")
    return db.execute("SELECT * FROM resor_users WHERE id = ? AND u_id = ?", [resa, user_join])
  end

  # inserts a users inte the relations tabel
  #
  # @params [Integer] resa, the trips id
   # @params [Integer] user_join, the users id
  #
  def insert_relation(resa, user_join)
    db = data("db/databas.db")
    db.execute("INSERT INTO resor_users (id, u_id) VALUES (?,?)",[resa, user_join])
  end
end