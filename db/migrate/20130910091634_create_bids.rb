class CreateBids < ActiveRecord::Migration
  def change
    create_table :bids do |t|
      t.integer :market_id
      t.integer :bid
      t.integer :owner

      t.timestamps
    end
  end
end
