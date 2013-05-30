class AddCattleIdToGames < ActiveRecord::Migration
  def change
    add_column :games, :cattle, :integer, :default => 1
  end
end
