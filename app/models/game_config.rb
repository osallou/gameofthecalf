class GameConfig < ActiveRecord::Base
  attr_accessible :mortality, :nbtrait, :mean_weight, :sex_effect, :heritability, :covar_envPermanent, :weight_month, :covar_weight, :heritability_weight, :default

  has_one :group
end
