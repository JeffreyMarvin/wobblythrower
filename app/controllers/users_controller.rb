class UsersController < ApplicationController
  
  def index
    @users = User.all
  end
  
  def register
  end
  
  def create_user
    if(params[:user][:password] == params[:user][:confirm])
        @user = User.new({:username => params[:user][:username], :password => params[:user][:password]})
        if @user.save
          flash[:notice] = 'User ' + @user.username + ' successfully created.'
          session[:id] = User.first(:conditions => {:username => params[:user][:username], :password => params[:user][:password]}).id
          redirect_to '/'
        else
          flash[:error] = 'Failed to create user: ' + params[:user][:username] + " with password: " + params[:user][:password] + "..."
          redirect_to :action => 'register', :username => params[:user][:username]
      end
    else
      flash[:error] = 'Passwords do not match.'
      redirect_to :action => 'register', :username => params[:user][:username]
    end
  end
  
  def login
    @user = User.new
    @user.username = params[:username]
  end

  def process_login
    
    if user = User.first(:conditions => {:username => params[:user][:username], :password => params[:user][:password]})
      session[:id] = user.id # Remember the user's id during this session
      redirect_to session[:return_to] || '/'
    else
      flash[:error] = 'Invalid login.'
      redirect_to :action => 'login', :username => params[:user][:username]
    end
  end

  def logout
    reset_session
    flash[:message] = 'Logged out.'
    redirect_to :action => 'login'
  end

end
