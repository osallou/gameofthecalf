class AddElementsToGameConfigs < ActiveRecord::Migration
  def change
    add_column :game_configs, :mean_weight, :text
    add_column :game_configs, :sex_effect, :text
    add_column :game_configs, :heritability, :text

    add_column :game_configs, :heritability_weight, :text
    add_column :game_configs, :covar_weight, :text
    add_column :game_configs, :weight_month, :text
    add_column :game_configs, :covar_envPermanent, :text
  end
end
