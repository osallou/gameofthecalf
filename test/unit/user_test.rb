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
  
  test "admin can manage all" do
    user = User.where(:email => Settings.admin[0]).first
    ability = Ability.new(user)
    otheruser = User.where(:email => "prof1@no-reply.org").first
    othergroup = Group.where(:name => "samplegroup1").first
    assert ability.can?(:create, Group)
    assert ability.can?(:create, User)
    assert ability.can?(:read, othergroup)
    assert ability.can?(:read, otheruser)
    assert ability.can?(:update, othergroup)
    assert ability.can?(:update, otheruser)
    assert ability.can?(:destroy, othergroup)
    assert ability.can?(:destroy, otheruser)
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
