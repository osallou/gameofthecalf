# Mailer used to send emails to the users.
class UserMailer < ActionMailer::Base
  default from: "gameofthecalf@no-reply.org"

  # Sends a welcome email to the user once account is created.
  def welcome_email(user)
    @user = user
    mail(:to => user.email, :subject => t('accountcreated'))
  end

  def users_created_email(group, users)
    @users =  users
    @group = group
    mail(:to => group.email, :subject => t('accountscreated'))
  end

end
