class AddMarketToGroups < ActiveRecord::Migration
  def change
    add_column :groups, :market, :integer, :default => 0
  end
end
