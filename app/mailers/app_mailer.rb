class AppMailer < ActionMailer::Base
  def notify_on_new_user_account(user)
    @user = user
    mail from: "admin@myflix.com", to: user.email, subject: "Welcome to MyFlix!, #{user.fullname}"
  end

  def notify_on_failed_charge(user)
    @user = user
    mail from: "admin@myflix.com", to: user.email, subject: "Your card was declined"
  end

  def notify_password_reset(user)
    @user = user
    mail from: "admin@myflix.com", to: user.email, subject: "Password Reset Request"
  end

  def notify_invitation(invitation)
    @invitation = invitation
    mail from: "admin@myflix.com", to: invitation.email, subject: "Invitation to join MyFlix"
  end

  def hardcoded_notify(from_email, to_email, subject, body)
    @body = body
    mail from: from_email, to: to_email, subject: subject
  end
end
