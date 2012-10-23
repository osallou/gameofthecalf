
# Creates an account for each admin user
Settings.admin.each do |admin|
    user = User.new(:email => admin)
    user.usertype = User::PROFESSOR
    user.password = SecureRandom.hex(16)
    user.password_confirmation =  user.password
    user.confirm!
    if user.save(:validate => false)
      UserMailer.welcome_email(user).deliver
    else
      puts user.errors
    end
end