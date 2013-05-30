# Base controller for managing games
class GamesController < ApplicationController

  before_filter :authenticate_user!

  # Propose new game or load previous sessions
  def index
   @games = Game.where(:user_id => current_user.id).order("created_at")
   @user = currebt_user
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
    # TODO Call Game.generate_new_cattle for 1 cattle
    # associate cattle to level

    level.save!
    @levels << level
    respond_to do |format|
      format.html { render :levels } # levels.html.erb
      format.json { render json: @levels }
    end
  end

  # DELETE /games/1
  # DELETE /games/1.json
  def destroy
    @game = Game.find(params[:id])

    authorize! :destroy, @game

    @game.destroy

    respond_to do |format|
      format.html { redirect_to games_url }
      format.json { head :no_content }
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
