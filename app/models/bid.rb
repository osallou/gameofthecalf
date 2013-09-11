class Bid < ActiveRecord::Base
  attr_accessible :bid, :market_id, :owner

  belongs_to :market
end
