# Main game class. A game represent a complete player game.
# It is composed of a set of levels up to final level.
# It gathers statistics, interactions etc... with the player
# as well as global rules.
class Game < ActiveRecord::Base
  attr_accessible :user_id
  
  scope :recent, order("created_at desc")
  
  belongs_to :user
  
end
