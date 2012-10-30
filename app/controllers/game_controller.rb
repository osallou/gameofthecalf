# Base controller for the game.
# It manages main pages and game.
class GameController < ApplicationController

  #before_filter :authenticate_user!

  # Welcome page, main entry
  def welcome
  end

  # Credits of the application
  def credits
  end
  
  # Manage users and groups
  def admin
  end

  # Tutorial of the game
  def tutorial
  end

  # Sets up locale for current user or session
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
