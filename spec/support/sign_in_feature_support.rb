def sign_in_user_via_ui(email, password)
  visit sign_in_path
  fill_in "Email Address", with: email
  fill_in "Password", with: password
  click_button "Sign In"
end
