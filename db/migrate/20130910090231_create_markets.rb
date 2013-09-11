class CreateMarkets < ActiveRecord::Migration
  def change
    create_table :markets do |t|
      t.integer :group
      t.text :animal
      t.integer :owner
      t.integer :status
      t.text :bids

      t.timestamps
    end
  end
end
