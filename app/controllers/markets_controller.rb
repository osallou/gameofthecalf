require 'uri'

class MarketsController < InheritedResources::Base

  # POST /markets/1/selection
  # POST /markets/1/selection.json
  def selection
    group = Group.find(params[:id])
    if group.market != Market::STATUS_OPEN
        redirect_to :action => "show", :id => params[:id]
        return
    end
    
    market = Market.new()
    market[:group_id] = params[:id]
    authorize! :create, market
    selection = JSON.parse(URI.unescape(params[:selection]))
    if selection.empty? or selection.length == 0
      flash[:alert] = "Selection empty"
      redirect_to :action => "show", :id => params[:id]
    else
      cattle = selection[0][0]
      Market.delete_all("group_id = "+params[:id].to_s+" AND owner = "+cattle.to_s)
      selection.each do |selected|
        market = Market.new(:group_id => params[:id], :owner => cattle.to_i,
                            :status => Market::ANIMAL_PROPOSED,
                            :animal => selected[1],
                            :values => JSON.dump(selected))
        market.save!
      end
      flash[:notice] = "Selection updated"
      redirect_to :action => "show", :id => params[:id]
    end

  end

  # GET /markets/1
  # GET /markets/1.json
  def show
    @group = Group.find(params[:id])
    user = current_user
    @selected = []
    @is_prof = false
    if User.admin?(user) or User.professor?(user)
      @is_prof = true
      markets = Market.where(:group_id => params[:id]) 
    else
      game = Game.where(:group_id => params[:id], :user_id => user[:id]).first
      markets = Market.where(:group_id => params[:id], :owner => game[:cattle])
    end
    markets.each do |market|
      if ! market[:values].nil? and ! market[:values].empty?
          @selected << JSON.parse(market[:values])
      end
    end

    respond_to do |format|
      if @group.market == Market::STATUS_OPEN
        if User.admin?(user) or User.professor?(user)
            @bulls = []
        else
            game = Game.where(:group_id => params[:id], :user_id => user[:id]).first
            @bulls, cows = game.get_cattle(user, game[:level]) 
        end
        @max = Settings.market_max_user
        format.html { render :proposals }
      elsif @group.market == Market::STATUS_BIDS
        @max = Settings.market_max_final
        format.html { render :bids }
      else
        format.html { render :closed }
      end
      format.json { render json: @markets }
    end
  end

end