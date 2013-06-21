require 'rails/test_help'

def signin 
        visit '/users/sign_in'
        fill_in "user_email", :with => @user[:email]
        fill_in "user_password", :with => @userpassword
        click_button "Sign in"
end


Given  /^a student$/ do
        @user = User.new(:email => 'student@fake.org')
        @user.usertype = User::STUDENT
        @user.password = SecureRandom.hex(16)
        @userpassword = @user.password
        @user.password_confirmation =  @user.password
        @user.confirm!
        @user.save(:validate => false)
        signin
end

Given /^a professor$/ do
        @user = User.new(:email => 'prof@fake.org')
        @user.usertype = User::PROFESSOR
        @user.password = SecureRandom.hex(16)
        @userpassword = @user.password
        @user.password_confirmation =  user.password
        @user.confirm!
        @user.save(:validate => false)
        signin
end

Given /^User is not logged in$/ do
  visit '/users/sign_out'
end

And /^user is not in a group$/ do
        @user[:group_id] = nil
        @user.save()
end
