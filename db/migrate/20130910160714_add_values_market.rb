class AddValuesMarket < ActiveRecord::Migration
  def up
    add_column :markets, :values, :text
  end

  def down
    remove_column  :markets, :values
  end
end
