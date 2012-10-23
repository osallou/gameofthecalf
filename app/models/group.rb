class Group < ActiveRecord::Base
  attr_accessible :description, :name, :email

  scope :recent, order("created_at desc")

  has_many :users

end
