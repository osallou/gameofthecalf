class AddLevelToGames < ActiveRecord::Migration
  def change
        add_column :games, :level, :integer, :default => 1
  end
end
