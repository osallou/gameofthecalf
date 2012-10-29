class AddGroupsMaxLevels < ActiveRecord::Migration
  def change
    add_column :groups, :levels, :integer, :default => Settings.max_levels
  end
end
