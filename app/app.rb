require 'sinatra'
require 'sinatra/activerecord'
require 'json'
require 'digest/sha2'
require 'cgi'

set :environment, :production
set :session_store, Rack::Session::Cookie

use Rack::Session::Cookie,
  :key => 'rack.session',
  :expire_after => 60,
  :secret => Digest::SHA256.hexdigest(rand.to_s)

class User < ActiveRecord::Base
end

class App < Sinatra::Base
  enable :sessions

  get '/' do
    @u = session[:username]
    if @u == nil
      erb :index
    else
      erb :index4login
    end
  end
  
  get '/login' do
    erb :login
  end
  
  get '/logout' do
    session.clear
    redirect '/'
  end
  
  get '/failure' do
    session.clear
    erb :failure
  end
  
  get '/contents' do
    if session[:username] != nil
      erb :index4login
    end
  end
  
  post '/auth' do
    name = params[:username]
    passwd = params[:passwd]
    
    begin
      a = User.find_by(username: name)
      ipasswd_hashed = Digest::SHA256.hexdigest(passwd)
      if a.passwd == ipasswd_hashed
        session[:username] = name
        p session[:username]
        redirect '/'
      end
      redirect '/failure'
    end
  end
  
end