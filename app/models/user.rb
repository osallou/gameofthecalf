class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :locale
  # attr_accessible :title, :body

  def admin?
    return false unless current_user
    Settings.admin.include?(current_user.email)
  end

  # Roles  
  ADMIN=0
  PROFESSOR=1
  STUDENT=2
end
