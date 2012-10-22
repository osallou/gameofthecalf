class Group < ActiveRecord::Base
  attr_accessible :description, :name, :email

  has_many :users

end
