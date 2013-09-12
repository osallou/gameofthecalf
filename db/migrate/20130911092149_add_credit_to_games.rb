class AddCreditToGames < ActiveRecord::Migration
  def change
    add_column :games, :credit, :integer
  end
end
