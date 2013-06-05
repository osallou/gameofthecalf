class AddStatusToGames < ActiveRecord::Migration
  def change
    add_column :games, :status, :integer
  end
end
