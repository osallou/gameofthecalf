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

  # Creates a new game
  # POST /games
  # POST /games.json
  def create
    authorize! :create, Game
    @game = Game.new(:user_id => current_user.id)
    @game.save!
    @levels = []
    level = Level.new(:game_id => @game.id, :status => Level::STATUS_NEW, :level => 1)
    level.save!
    @levels << level
    respond_to do |format|
      format.html { render :levels } # levels.html.erb
      format.json { render json: @levels }
    end
  end

  # GET /games/1
  # GET /games/1.json
  def show
    @game = Game.find(params[:id])
    @levels = Level.where(:game_id => @game.id)
    respond_to do |format|
      format.html { render :levels } # levels.html.erb
      format.json { render json: @levels }
    end

  end

end
