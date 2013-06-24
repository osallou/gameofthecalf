class CreateGameConfigs < ActiveRecord::Migration
  def change
    create_table :game_configs do |t|
      t.boolean :default
      t.integer :nbtrait
      t.float :mortality
      t.timestamps
    end
  end
end
