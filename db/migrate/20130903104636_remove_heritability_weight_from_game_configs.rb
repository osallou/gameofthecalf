class RemoveHeritabilityWeightFromGameConfigs < ActiveRecord::Migration
  def up
    remove_column :game_configs, :heritability_weight
  end

  def down
    add_column :game_configs, :heritability_weight, :text
  end
end
