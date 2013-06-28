# Base class for all users
class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable

  scope :recent, order("created_at desc")

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :locale, :usertype, :group_id, :fake, :nickname
  # attr_accessible :title, :body

  belongs_to :group
  
  has_many :games, :dependent => :destroy

  # Checks if user is a site administrator.
  # Administrators are defined in Settings.
  def self.admin?(user)
    return false unless user
    Settings.admin.include?(user.email)
  end

  def self.professor?(user)
    if self.admin?(user) or user[:usertype] = PROFESSOR
      return true
    else
      return false
    end
  end

  # Administrator role
  ADMIN=0
  # Professor role, can create students and groups
  PROFESSOR=1
  # Student role, i.e. player
  STUDENT=2
end
