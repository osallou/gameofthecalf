class AddUserGroupRelationship < ActiveRecord::Migration
  def up
    add_column :users, :group_id, :integer
  end

  def down
    remove_column :users, :group_id
  end

end
