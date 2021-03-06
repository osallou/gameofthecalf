# Base controller for managing games
class GamesController < ApplicationController

  skip_before_filter :verify_authenticity_token
  before_filter :authenticate_user!
  
     
  # Propose new game or load previous sessions
  def index
   @games = Game.where(:user_id => current_user.id).order("created_at")
   @user = current_user
   if @user[:group_id].nil?
        @group = nil
   else
        @group = Group.find(@user[:group_id])
   end
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
    @game = Game.new(:user_id => current_user.id, :status => Level::STATUS_NEW,
:level => 1, :cattle => 1)
    @game.save!
    # Generate cattle
    Game.generate_new_cattle(1,'game'+@game[:id].to_s)
    @game.load_statistics()
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
    if @game.data.nil? or @game.data.empty?
      @game.data = "{}"
    end
    @levels = Level.where(:game_id => @game.id)

    @user = current_user
    if User.professor?(@user)     
      @user = User.find(@game[:user_id])
    end
    
    
    if @user[:group_id].nil?
        @group = nil
    else
        @group = Group.find(@user[:group_id])
    end

    proposals = Market.where(:group_id => @game[:group_id],
                             :owner => @game[:cattle]).count()
    @bids_opened = true
    if proposals==0
      @bids_opened = false
    end

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
    
    @game.complete_level(params[:matingplan])

    @levels = Level.where(:game_id => @game.id)
    
    respond_to do |format|
      format.html { render :levels } # levels.html.erb
      format.json { render json: @levels }
    end
    
  end  

end
