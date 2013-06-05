class AddMatingplanToLevels < ActiveRecord::Migration
  def change
    add_column :levels, :matingplan, :text
  end
end
