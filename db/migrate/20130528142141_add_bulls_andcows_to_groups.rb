class AddBullsAndcowsToGroups < ActiveRecord::Migration
  def change
    add_column :groups, :bulls, :integer, :default => Settings.default_bulls
    add_column :groups, :cows, :integer, :default => Settings.default_cows
  end
end
