# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  before_filter :set_user

  protected
    def set_user
      @user = User.find(session[:id]) if @user.nil? && session[:id]
    end

    def login_required
      return true if @user
      access_denied
      return false
    end

    def access_denied
      session[:return_to] = request.request_uri
      flash[:error] = 'Oops. You need to login before you can view that page.'
      redirect_to :controller => 'users', :action => 'login'
    end

  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password
end
