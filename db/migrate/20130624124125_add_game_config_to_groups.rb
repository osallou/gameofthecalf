class AddGameConfigToGroups < ActiveRecord::Migration
  def up
    add_column :groups, :config_id, :integer
  end

  def down
    remove_column :groups, :config_id
  end

end
