class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :set_locale
 
  def set_locale
    I18n.locale = params[:locale] || session[:locale] || I18n.default_locale
    I18n.locale = current_user.locale if current_user and current_user.locale
  end


end
