class Group < ActiveRecord::Base
  attr_accessible :description, :name, :owner

  has_many :users

end
