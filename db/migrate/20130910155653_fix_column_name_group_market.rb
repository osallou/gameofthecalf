class FixColumnNameGroupMarket < ActiveRecord::Migration
  def up
    rename_column :markets, :group, :group_id
  end

  def down
    rename_column :markets, :group_id, :group
  end
end
