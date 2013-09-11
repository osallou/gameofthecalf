require 'csv'

class LevelsController < ApplicationController

  before_filter :authenticate_user!

  # GET /levels/1
  # GET /levels/1.json
  def show
    @level = Level.find(params[:id])

    authorize! :read, @level
    
    if @level[:status] == Level::STATUS_COMPLETED
      return redirect_to :controller => "games", :action => "show", :id => @level.game_id     
    end

    @game = Game.find(@level.game_id)

    @maxbulls = Settings.default_bulls
    @maxcows = Settings.default_cows
    if @game[:group_id] != nil
        group = Group.find(@game[:group_id])
        @maxbulls = group[:bulls]
        @maxcows = group[:cows]
    end

    if @level[:status] == Level::STATUS_NEW
        @level[:status] = Level::STATUS_IN_PROGRESS
        @level.save
        @game[:status] = Level::STATUS_IN_PROGRESS
        @game.save
    end

    user = User.find(@game[:user_id])        
    @bulls, @cows = @game.get_cattle(user, @level.level)

    respond_to do |format|
      format.html
      format.json { render json: @level }
    end

  end

end
