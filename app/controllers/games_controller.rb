# Base controller for managing games
class GamesController < ApplicationController

  before_filter :authenticate_user!

  # Propose new game or load previous sessions
  def index
   @games = Game.where(:user_id => current_user.id).order("created_at")
   respond_to do |format|
     format.html # index.html.erb
     format.json { render json: @games }
   end
  end

end
