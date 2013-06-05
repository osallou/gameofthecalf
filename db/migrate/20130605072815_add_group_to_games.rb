class AddGroupToGames < ActiveRecord::Migration
  def up
    add_column :games, :group_id, :integer
  end

  def down
    remove_column :games, :group_id
  end

end
