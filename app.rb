require 'sinatra'
require 'slim'
require 'sqlite3'
require 'sinatra/reloader'
require 'bcrypt'
also_reload 'model'
enable :sessions
require_relative'./model.rb'

include Model

before do
  guest_routes = ['/', '/login', '/user', '/error']
  if (session[:user_id] ==  nil) && !guest_routes.include?(request.path_info)
    redirect('/error')
  end
end


# Displays a login form
#
get("/") do  
  slim(:"user/new")
end  

# Lets the user login, and redirects to welcome, error or login
#
# @param [String] user, The name of the user
# @param [String] pwd, password
# @param [String] pwd_confirm, password confirm
#
# @see Model#user_check
# @see Model#add_user
post("/user") do
  user = params["user"]
  pwd = params["pwd"]
  pwd_confirm = params["pwd_confirm"]
  
  result = user_check(user)
  
  if result.empty?
    if pwd==pwd_confirm
      
      result2 = add_user(user,pwd)
      session[:admin] = result2[1]    

      if result2[0].empty?
        redirect('/error')
      end
      user_id = result2[0].first["u_id"]
      session[:user_id] = user_id    
       
    
      redirect('/welcome')
    else
      redirect('/error')
    end
  else
    redirect('/login')
  end
end

# Attempts login and updates the session
#
# @param [String] l_user, The username
# @param [String] l_pwd, The password
#
# @see Model#find:person
# @see Model#find:password_check
# @see Model#find:delete_user
post("/login") do

  l_user = params["l_user"]
  l_pwd = params["l_pwd"]
  result = find_person(l_user)
  if result.empty?
    redirect('/error')
  end

  

  user_id = result.first["u_id"]
  pwd_digest = result.first["pwd_digest"]
  admin = result.first["admin"]

  if password_check(l_pwd,pwd_digest)
    p "test #{user_id}"
    session[:user_id] = user_id
    session[:admin] = admin.to_i
    p "login #{session[:user_id]}"
    redirect('/welcome')
  else
    redirect('/error')
  end
end

# Displays a delete form
#
# @param [Integer] :user_id, The users id
#
# @see Model#delete_user
get("/user/delete") do
  user = session[:user_id]
  delete_user(user)
  redirect('/')
end

# shows an update form
#
get("/user/update") do
  slim(:"user/edit")
end

# lets the user update its user, redirets to /
#
# @param [Integer] :user_id, The users id
# @param [String] :name, The users name
# @param [String] :pwd, The users password
# @param [String] :pwd_confirm, The users password confirmed
#
# @see Model#edit_user
post("/user/update") do
  u_id = session[:user_id]
  name = params[:name]
  pwd = params[:pwd]
  pwd_confirm= params[:pwd_confirm]
  if pwd==pwd_confirm
    edit_user(u_id, name, pwd)
    redirect('/')
  else
    redirect('/error')
  end
end

# shows the error page
#
get("/error") do
  slim(:error)
end

# shows all information
#
# @param [Integer] :user_id, The users id
# @param [Bool] :admin, if the user is admin or not
#
# @see Model#get_data
get("/welcome") do
  result = get_data()
  @data = result[0]
  @persons = result[1]
  @admin = session[:admin]
  @owner = session[:user_id]
  p "hej #{session[:user_id]}"
  slim(:index)
end  

# Add a trip, redirects to /welcome
#
# @param [String] :res_name, The trips name
# @param [String] :description, The description
# @param [Integer] :user_id, the id of the owner
#
# @see Model#insert_resor
post("/resor/new") do
  res_name = params[:res_name] 
  description = params[:description]
  owner = session[:user_id]
  insert_resor(res_name, description, owner)
  redirect('/welcome') 
end

# Edit a trip
#
# @param [Integer] :id, The trips id
# @param [Integer] :user_id, the id of the user
#
# @see Model#select
# @see Model#owner_check
get("/resor/:id/edit") do
  user = session[:user_id].to_i
  id = params[:id].to_i
  @selected_resor = select(id)
  owner = owner_check(id)

  if owner == user || session[:admin]==1
    slim(:"resor/edit")
  else
    redirect('/error')
  end

end

# Update a trip, redirects to welcome
#
# @param [Integer] :id, The trips id
# @param [Integer] :user_id, the id of the user
# @param [String] :name, the name of the trip
# @param [String] :description, the descritpion
#
# @see Model#updatera
# @see Model#owner_check
post("/resor/:id/update") do
  user = session[:user_id].to_i
  id = params[:id].to_i
  name = params[:name]
  description = params[:description]
  owner = owner_check(id)

  if owner == user || session[:admin]==1
    updatera(name, description, id)
    redirect("/welcome")
  else
    redirect('/error')
  end

end

# Delete a trip, redirects to welcome
#
# @param [Integer] :id, The trips id
# @param [Integer] :user_id, the id of the user
#
# @see Model#delete
# @see Model#owner_check
post("/resor/:id/delete") do
  user = session[:user_id].to_i
  resa = params[:id].to_i
  owner = owner_check(resa)

  if owner == user || session[:admin]==1
    delete(resa)
    redirect('/welcome')
  else
    redirect('/error')
  end
  
end

# Shows a trips participents
#
# @param [Integer] :id, The trips id
#
# @see Model#persons
get("/resor/:id/show") do
  resa = params[:id].to_i
  @persons = persons(resa)
  slim(:"resor/show")
end

# Lets a user join a trip, redirects to welcome
#
# @param [Integer] :id, The trips id
# @param [Integer] :user_id, The users id
#
# @see Model#verify
# @see Model#insert_relation
get("/resor/:id/join") do
  resa = params[:id].to_i
  user_join = session[:user_id]

  verify = verify(resa, user_join)
  if verify.empty?
    insert_relation(resa, user_join)
  end

  redirect('/welcome')
end