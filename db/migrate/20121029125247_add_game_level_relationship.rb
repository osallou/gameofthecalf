class AddGameLevelRelationship < ActiveRecord::Migration
  def up
    add_column :levels, :game_id, :integer
  end

  def down
    remove_column :levels, :game_id
  end

end
