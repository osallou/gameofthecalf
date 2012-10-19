class GameController < ApplicationController

  before_filter :authenticate_user!

  def welcome
  end

  def credits
  end

  def locale
    locale = params[:id]
    raise 'unsupported locale' unless Settings.languages.include?(locale)
    if current_user
      current_user.locale = locale
      current_user.save
    else
      session[:locale] = locale
    end
    redirect_to :back
  end

end
