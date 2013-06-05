# Base controller for managing games
class GamesController < ApplicationController

  skip_before_filter :verify_authenticity_token
  before_filter :authenticate_user!
  

  # Propose new game or load previous sessions
  def index
   @games = Game.where(:user_id => current_user.id).order("created_at")
   @user = current_user
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
    @game = Game.new(:user_id => current_user.id, :status => Level::STATUS_NEW, :level => 1)
    @game.save!
    # Generate cattle
    Game.generate_new_cattle(1,'game'+@game[:id].to_s)

    @levels = []
    level = Level.new(:game_id => @game.id, :status => Level::STATUS_NEW, :level => 1)
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


  # Move to next level
  # POST /games/1/nextlevel
  # POST /games/1/nextlevel.json
  def nextlevel
    authorize! :create, Game
    @game = Game.find(params[:id])
    level = Level.where(:game_id => @game.id, :level => @game[:level]).first
    level[:matingplan] = params[:matingplan]
    level.status = Level::STATUS_COMPLETED
    level.save
    max_levels = Settings.max_levels
    
    if @game[:group_id]!=nil
        @game[:status] = Level::STATUS_COMPLETED
        @game.save
    else
      Game.writeMatingPlan("game"+@game[:id].to_s, level[:level]+1,{ @game[:cattle] => JSON.parse(level[:matingplan]) })
      Game.mate("game"+@game[:id])
      if @game[level]< max_levels
        # Go to next level
        @game[:level] += 1
        @game[:status] = Level::STATUS_NEW

        level = Level.new(:game_id => @game.id, :status => Level::STATUS_NEW, :level => @game[:level])
        level.save!
      else
        @game[:status] = Level::STATUS_COMPLETED
      end
      @game.save
    end

    @levels = Level.where(:game_id => @game.id)
    
    respond_to do |format|
      format.html { render :levels } # levels.html.erb
      format.json { render json: @levels }
    end
    
  end  

end
