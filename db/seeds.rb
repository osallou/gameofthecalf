# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
GameConfig.where(:default => true).destroy_all
GameConfig.create(default: true, nbtrait: 2, mortality: 0.064, mean_weight: '162,258', sex_effect: '11,28', heritability: '0.30,0.36,0.11,0.09', covar_envPermanent: '34.64,43.53|43.53,60.61', weight_month: '162,258', covar_weight: '94.45,129.92,-21.93,-24.00|129.92,241.57,-26.34,-47.54|-21.93,-26.34,34.67,42.29|-24.00,-47.54,42.29,62.02')
