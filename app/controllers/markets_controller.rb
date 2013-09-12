require 'uri'

class MarketsController < InheritedResources::Base

  # POST /markets/1/vote
  # POST /markets/1/vote.json
  def vote
    @group = Group.find(params[:id])
    user = current_user
    game = Game.where(:group_id => params[:id], :user_id => user[:id]).first
    proposals = Market.where(:group_id => game[:group_id],
                             :owner => game[:cattle]).count()
    bids_opened = true
    if proposals==0
      flash[:alert] = "you did not propose bulls to the market, bids are not
accessible."
      redirect_to :action => "closed", :id => params[:id]
      bids_opened = false
    else
      # Reset bids
      Bid.delete_all("group_id = "+params[:id].to_s+" AND owner ="+user[:id].to_s)
      bids = JSON.parse(URI.unescape(params[:bids]))
      credit = 0
      bids.each do |bid|
          user_bid = Bid.new(market_id: bid["market"],
                            group_id: params[:id].to_i,
                            owner: user[:id], bid: bid["bid"].to_s)
          delta = bid["oldbid"] - bid["bid"]
          credit += delta
          if bid["bid"] > 0
              user_bid.save!
          end
      end
      game[:credit] += credit
      game.save!
      flash[:notice] = "Bids taken into account"
      redirect_to :action => "bids", :id => params[:id]
    end
  end

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

  # GET /markets/1/bids
  # GET /markets/1/bids.json
  def bids
    @group = Group.find(params[:id])
    user = current_user
    @is_prof = false
    if User.admin?(user) or User.professor?(user)
      @is_prof = true
    end
    @credit = -1
    @game = nil
    @cattle = -1
    markets = Market.where(:group_id => params[:id])
    user_bids = nil
    if @is_prof
      user_bids = Bid.select("market_id, sum(bid) as bids").where(:group_id => params[:id]).group("market_id")
    else
      @game = Game.where(:group_id => params[:id], :user_id => user[:id]).first
      user_bids = Bid.select("market_id, sum(bid) as bids").where(:group_id => params[:id], :owner => user[:id]).group("market_id")
      @credit = @game.credit
      @cattle = @game[:cattle]
    end
    @animals = []
    markets.each do |market|
      if ! market[:values].nil? and ! market[:values].empty?
          animal = {}
          animal[:values] = JSON.parse(market[:values])
          animal[:bid] = 0
          animal[:oldbid] = 0
          animal[:market] = market[:id]
          user_bids.each do |user_bid|
              if user_bid[:market_id] == market[:id]
                  animal[:bid] = user_bid[:bids].to_i
                  animal[:oldbid] = animal[:bid]
                  break
              end
          end
          @animals << animal
      end
    end
    @animals = @animals.to_json
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
      game.credit = Settings.credit_default
      game.save!
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
        flash[:alert] = "Market is closed"
        format.html { render :closed }
      end
      format.json { render json: @markets }
    end
  end

end
