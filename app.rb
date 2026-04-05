require 'sinatra'
require 'slim'
require 'sqlite3'
require 'sinatra/reloader'
require 'bcrypt'
also_reload 'model'
enable :sessions
require_relative'./model.rb'

 
before do
  guest_routes = ['/', '/login', '/user', '/error']
  if (session[:user_id] ==  nil) && !guest_routes.include?(request.path_info)
    redirect('/error')
  end
end



get("/") do  
  slim(:"user/add_user")
end  

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
get("/user/delete") do
  user = session[:user_id]
  delete_user(user)
  redirect('/')
end
get("/user/update") do
  slim(:"user/edit_user")
end
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
get("/error") do
  slim(:error)
end

get("/welcome") do
  result = get_data()
  @data = result[0]
  @persons = result[1]
  @admin = session[:admin]
  @owner = session[:user_id]
  p "hej #{session[:user_id]}"
  slim(:start)
end  

post("/resor/new") do
  res_name = params[:res_name] 
  description = params[:description]
  owner = session[:user_id]
  insert_resor(res_name, description, owner)
  redirect('/welcome') 
 
end

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

get("/resor/:id/info") do
  resa = params[:id].to_i
  @persons = persons(resa)
  slim(:"resor/info")
end

get("/resor/:id/join") do
  resa = params[:id].to_i
  user_join = session[:user_id]

  verify = verify(resa, user_join)
  if verify.empty?
    insert_relation(resa, user_join)
  end

  redirect('/welcome')
end