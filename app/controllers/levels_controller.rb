require 'csv'

class LevelsController < ApplicationController

  before_filter :authenticate_user!

  # GET /levels/1
  # GET /levels/1.json
  def show
    @level = Level.find(params[:id])
    
    if @level[:status] == Level::STATUS_COMPLETED
      return redirect_to :controller => "games", :action => "show", :id => @level.game_id     
    end

    @game = Game.find(@level.game_id)

    @maxbulls = Settings.default_bulls
    @maxcows = Settings.default_cowsa
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

    cattle_path = @game.get_cattle_path(user)
    cattle_file = 'bullMate_perfVG_Flock-1_generation-'+@level.level.to_s+'.txt'

    @bulls = []
    @cows = []

    found = false
    CSV.foreach(cattle_path+'/'+cattle_file, col_sep:"\t") do |row|
        if row[0].to_i == @game.cattle
            if row[2].to_i == 0
                @bulls << row
            else
                @cows << row
            found = true
            end
        elsif found
            break
        end
    end

    respond_to do |format|
      format.html
      format.json { render json: @level }
    end

  end

end
