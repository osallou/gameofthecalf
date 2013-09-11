class RemoveBidsFromMarket < ActiveRecord::Migration
  def up
    remove_column :markets, :bids
  end

  def down
    add_column :markets, :bids, :text
  end
end
