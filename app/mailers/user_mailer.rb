class UserMailer < ActionMailer::Base
  default from: "gameofthecalf@no-reply.org"

  def welcome_email(user)
    @user = user
    mail(:to => user.email, :subject => t('accountcreated'))
  end

end
