class AddDataToGames < ActiveRecord::Migration
  def change
    add_column :games, :data, :text
  end
end
