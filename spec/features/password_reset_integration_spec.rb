# password reset testing
require 'rails_helper'

feature "reset existing user password" do
  background do
    @user = Fabricate(:user, password: "forgotten_password", email: "elephant@jungle.org")
    clear_emails
  end

  scenario "user requests to reset a password when visiting signin page" do

    perform_forgotten_password_request(@user.email)
    open_email(@user.email)

    current_email.click_link "here to reset your password"

    expect(page).to have_content "Reset Your Password"
    fill_in "Password", with: "new_password"
    fill_in "Confirm Password", with: "new_password"
    click_button "Reset Password"

    expect(page).to have_content "Your password has been changed."

    # we should have been redirected to the sign in page

    # attempt to use old password should fail
    fill_in "Email Address", with: @user.email
    fill_in "Password", with: "forgotten_password"
    click_button "Sign In"
    expect(page).to have_content "Invalid email or password"

    # attempt to use new password will succeed
    fill_in "Email Address", with: @user.email
    fill_in "Password", with: "new_password"
    click_button "Sign In"
    expect(page).to have_content @user.fullname
    expect(page).not_to have_content "Invalid"    
  end

  scenario "user attempts to use an expired reset link" do
    perform_forgotten_password_request(@user.email)
    open_email(@user.email)

    # before we click on the link, let's issue ANOTHER forgotten password request
    # this should invalidate the first token
    perform_forgotten_password_request(@user.email)
    
    current_email.click_link "here to reset your password"
    expect(page).to have_content "Your reset password link has expired."

    # now get the latest email and the link should work
    open_email(@user.email)
    current_email.click_link "here to reset your password"
    expect(page).to have_content "Reset Your Password"
  end

end

def perform_forgotten_password_request(email)
  visit sign_in_path
  click_link "Forgot password"

  expect(page).to have_content "you can use to reset your password"
  fill_in "Email Address", with: email

  click_button "Send Email"
  expect(page).to have_content "We have sent an email with instructions to reset your password."
end
