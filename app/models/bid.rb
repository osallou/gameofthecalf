class Bid < ActiveRecord::Base
  attr_accessible :bid, :market_id, :owner, :group_id

  belongs_to :market
end
