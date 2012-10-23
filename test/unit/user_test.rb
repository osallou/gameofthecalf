require 'test_helper'

class UserTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  
  test "user_is_admin" do
    user = User.where(:email => Settings.admin[0]).first
    assert !user.nil?
    assert User.admin?(user)
  end
  
  test "admin can create prof" do
    assert false
  end
  
  test "prof can create groups" do
    assert false
  end  
  
  test "prof can create students" do
    assert false
  end
  
  test "prof cannot create prof" do
    assert false
  end
  
  test "student cannot create student" do
    assert false
  end
  
  test "prof can change a student group" do
    assert false
  end
  
  
end
