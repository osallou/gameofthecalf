# Define a level in a game
class Level < ActiveRecord::Base
  attr_accessible :level, :status, :game_id

  belongs_to :game
end
