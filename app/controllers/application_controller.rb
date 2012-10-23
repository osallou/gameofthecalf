class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :set_locale

  def authenticate_admin_user!
   redirect_to new_user_session_path unless User.admin?(current_user) 
  end
 
  def set_locale
    I18n.locale = params[:locale] || session[:locale] || I18n.default_locale
    I18n.locale = current_user.locale if current_user and current_user.locale
  end


end
