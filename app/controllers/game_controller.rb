class GameController < ApplicationController

  def welcome
  end

  def locale
    locale = params[:id]
    raise 'unsupported locale' unless ['fr', 'en' ].include?(locale)
    if current_user
      current_user.locale = locale
      current_user.save
    else
      session[:locale] = locale
    end
    redirect_to :back
  end

end
