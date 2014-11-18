class AppMailer < ActionMailer::Base
  def notify_on_new_user_account(user)
    @user = user
    mail from: "admin@myflix.com", to: user.email, subject: "Welcome to MyFlix!, #{user.fullname}"
  end

  def notify_password_reset(user)
    @user = user
    mail from: "admin@myflix.com", to: user.email, subject: "Password Reset Request"
  end

  def notify_invitation(invitation)
    @invitation = invitation
    mail from: "admin@myflix.com", to: invitation.email, subject: "Invitation to join MyFlix"
  end
end
