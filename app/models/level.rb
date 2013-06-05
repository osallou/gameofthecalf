# Define a level in a game
class Level < ActiveRecord::Base
  attr_accessible :level, :status, :game_id, :matingplan

  belongs_to :game

  # New level status
  STATUS_NEW = 0
  # In progress
  STATUS_IN_PROGRESS = 1
  # Completed level status
  STATUS_COMPLETED = 2

end
