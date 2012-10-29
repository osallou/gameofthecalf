# Define a level in a game
class Level < ActiveRecord::Base
  attr_accessible :level, :status, :game_id

  belongs_to :game

  # New level status
  STATUS_NEW = 0
  # Completed level status
  STATUS_COMPLETED = 1

end
