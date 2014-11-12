class AppMailer < ActionMailer::Base
  def notify_on_new_user_account(user)
    @user = user
    mail from: "admin@myflix.com", to: user.email, subject: "Welcome to MyFlix!, #{user.fullname}"
  end

end
