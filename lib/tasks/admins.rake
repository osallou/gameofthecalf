namespace :gameadmin do

  desc "Creates and register all admins in settings"
  task :register  => :environment do
    Settings.admin.each do |admin|
      # If user does not exists
      if User.where(:email => admin).nil?
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
    end
  end

  desc "Creates an admin"
  task :create  => :environment do
    login = ENV["LOGIN"]
    password = ENV["PASSWORD"]
    if !login || !password
      puts "Login or password is empty, please specify those with LOGIN= or PASSWORD="
    else
      if User.where(:email => admin).nil?
        user = User.new(:email => login)
        user.usertype = User::PROFESSOR
        user.password = password
        user.password_confirmation =  user.password
        user.confirm!
        if ! user.save
          puts "Error while creating user: "+user.errors
        end
      else
        puts "User #{login} altrady exists in the database"
      end
    end
  end

end
