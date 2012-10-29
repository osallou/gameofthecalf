# Group is used to group a set of Users.
# User is in one group only.
# Group can be seen as a classroom owner by a professor.
class Group < ActiveRecord::Base
  attr_accessible :description, :name, :email, :levels

  scope :recent, order("created_at desc")

  has_many :users

end
